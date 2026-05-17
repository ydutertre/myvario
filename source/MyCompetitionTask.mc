// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (c) 2025 Yannick Dutertre <https://yannickd9.wixsite.com/myvario>
//
// My Vario is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// My Vario is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

import Toybox.Lang;
using Toybox.Application as App;
using Toybox.Communications as Comms;
using Toybox.Math;
using Toybox.Position as Pos;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

class MyCompetitionTask {

  public const STATE_EMPTY = 0;
  public const STATE_LOADING = 1;
  public const STATE_READY = 2;
  public const STATE_ERROR = 3;
  public const STATE_DONE = 4;
  public const EVENT_NONE = 0;
  public const EVENT_WAYPOINT = 1;
  public const EVENT_GOAL = 2;
  public const EVENT_START = 3;
  public const EVENT_ESS = 4;
  public const TASK_WAITING = 0;
  public const TASK_STARTED = 1;
  public const TASK_EXPIRED = 2;
  public const TASK_COMPLETE = 3;

  private const EARTH_RADIUS as Float = 6371007.2f;

  public var bEnabled as Boolean = false;
  public var sSource as String = "";
  public var iState as Number = STATE_EMPTY;
  public var sStatus as String = "";
  public var iActiveIndex as Number = 0;
  public var iTaskState as Number = TASK_WAITING;
  public var iStartIndex as Number = -1;
  public var iEssIndex as Number = -1;
  public var iGoalIndex as Number = -1;
  public var iStartSeconds as Number = -1;
  public var iDeadlineSeconds as Number = -1;
  public var iLastUtcSeconds as Number = -1;
  public var bEssReached as Boolean = false;

  public var asNames as Array<String>;
  public var afLatitude as Array<Float>;
  public var afLongitude as Array<Float>;
  public var afAltitude as Array<Float>;
  public var afRadius as Array<Float>;
  public var aiType as Array<Number>;

  public var sActiveName as String = "";
  public var fActiveAltitude as Float = NaN;
  public var fDistanceNext as Float = NaN;
  public var fDistanceRemaining as Float = NaN;
  public var fTotalCenterDistance as Float = NaN;
  public var fOptimalTaskDistance as Float = NaN;
  public var fBearing as Float = NaN;
  public var fExpectedAltitudeNext as Float = NaN;
  public var fAltitudeMarginNext as Float = NaN;
  public var bInsideNext as Boolean = false;
  public var iPendingEvent as Number = EVENT_NONE;

  function initialize() {
    self.clearTask();
  }

  function init(_bEnabled as Boolean, _sSource as String) as Void {
    _sSource = LangUtils.readKeyString(_sSource, "");
    if(_bEnabled != self.bEnabled || !_sSource.equals(self.sSource)) {
      self.bEnabled = _bEnabled;
      self.sSource = _sSource;
      self.clearTask();
      if(!self.bEnabled) {
        self.sStatus = "Off";
      }
      else if(self.sSource.length() == 0) {
        self.sStatus = "No task";
      }
      else {
        self.load();
      }
    }
    else if(!self.bEnabled && self.sStatus.length() == 0) {
      self.sStatus = "Off";
    }
  }

  function clearTask() as Void {
    self.iState = STATE_EMPTY;
    self.sStatus = "";
    self.iActiveIndex = 0;
    self.iTaskState = TASK_WAITING;
    self.iStartIndex = -1;
    self.iEssIndex = -1;
    self.iGoalIndex = -1;
    self.iStartSeconds = -1;
    self.iDeadlineSeconds = -1;
    self.iLastUtcSeconds = -1;
    self.bEssReached = false;
    self.asNames = [];
    self.afLatitude = [];
    self.afLongitude = [];
    self.afAltitude = [];
    self.afRadius = [];
    self.aiType = [];
    self.sActiveName = "";
    self.fActiveAltitude = NaN;
    self.fDistanceNext = NaN;
    self.fDistanceRemaining = NaN;
    self.fTotalCenterDistance = NaN;
    self.fOptimalTaskDistance = NaN;
    self.fBearing = NaN;
    self.fExpectedAltitudeNext = NaN;
    self.fAltitudeMarginNext = NaN;
    self.bInsideNext = false;
    self.iPendingEvent = EVENT_NONE;
  }

  function load() as Void {
    if(self.loadCached()) {
      return;
    }
    self.reload();
  }

  function reload() as Void {
    self.clearTask();
    if(!self.bEnabled) {
      self.sStatus = "Off";
      return;
    }
    if(self.sSource.length() == 0) {
      self.sStatus = "No task";
      return;
    }

    var sUrl = self.getLoadUrl(self.sSource);
    if(sUrl.length() == 0) {
      self.fail("No task URL");
      return;
    }

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :headers => {"Accept" => "application/json, application/xctsk"}
    };

    self.iState = STATE_LOADING;
    self.sStatus = "Loading";
    Comms.makeWebRequest(sUrl, {}, options, method(:onReceiveTask));
  }

  function resetProgress() as Void {
    self.iPendingEvent = EVENT_NONE;
    self.fDistanceNext = NaN;
    self.fDistanceRemaining = NaN;
    self.fBearing = NaN;
    self.fExpectedAltitudeNext = NaN;
    self.fAltitudeMarginNext = NaN;
    if(self.iState == STATE_DONE) {
      self.iState = STATE_READY;
    }
    if(self.iStartIndex >= 0) {
      self.iActiveIndex = self.iStartIndex;
      self.iTaskState = TASK_WAITING;
      self.bEssReached = false;
      self.sStatus = "Reset";
    }
    else {
      self.iActiveIndex = self.nextNavigableIndex(-1);
      self.iTaskState = TASK_STARTED;
      self.bEssReached = self.iEssIndex < 0;
      self.sStatus = "Reset";
    }
  }

  function clearCache() as Void {
    try {
      App.Storage.deleteValue("competitionTaskSource");
      App.Storage.deleteValue("competitionTaskData");
    } catch(e) {
    }
  }

  function loadCached() as Boolean {
    try {
      var sCachedSource = LangUtils.readKeyString(App.Storage.getValue("competitionTaskSource"), "");
      if(!sCachedSource.equals(self.sSource)) {
        return false;
      }
      var cachedTask = App.Storage.getValue("competitionTaskData");
      if(cachedTask == null || !(cachedTask instanceof Lang.Dictionary)) {
        return false;
      }
      if(self.parse(cachedTask as Dictionary)) {
        self.iState = STATE_READY;
        self.sStatus = "Ready " + self.asNames.size().format("%d") + " WP";
        return true;
      }
    } catch(e) {
    }
    return false;
  }

  function getLoadUrl(_sSource as String) as String {
    var s = _sSource;
    var iTaskCode = s.find("taskCode=");
    if(iTaskCode != null && iTaskCode >= 0) {
      var sCode = s.substring(iTaskCode + 9, s.length());
      var iAmp = sCode.find("&");
      if(iAmp != null && iAmp >= 0) {
        sCode = sCode.substring(0, iAmp);
      }
      return "https://tools.xcontest.org/api/xctsk/load/" + sCode;
    }
    if(s.find("http://") == 0 || s.find("https://") == 0) {
      return s;
    }
    return "https://tools.xcontest.org/api/xctsk/load/" + s;
  }

  function onReceiveTask(_responseCode, _data) as Void {
    if(_responseCode != 200 || _data == null) {
      self.fail("Load failed");
      return;
    }
    if(!(_data instanceof Lang.Dictionary)) {
      self.fail("Bad task");
      return;
    }
    if(self.parse(_data as Dictionary)) {
      self.iState = STATE_READY;
      self.sStatus = "Ready " + self.asNames.size().format("%d") + " WP";
      try {
        App.Storage.setValue("competitionTaskSource", self.sSource as App.PropertyValueType);
        App.Storage.setValue("competitionTaskData", _data as App.PropertyValueType);
      } catch(e) {
      }
    }
    else {
      self.fail("Parse failed");
    }
  }

  function fail(_sStatus as String) as Void {
    self.iState = STATE_ERROR;
    self.sStatus = _sStatus;
  }

  function parse(_task as Dictionary) as Boolean {
    self.clearTask();

    var version = _task.get("version");
    if(version == null) {
      version = _task.get("V");
    }
    if(version == 2) {
      return self.parseV2(_task);
    }
    return self.parseV1(_task);
  }

  function parseV1(_task as Dictionary) as Boolean {
    var turnpoints = _task.get("turnpoints");
    if(turnpoints == null || !(turnpoints instanceof Lang.Array)) {
      return false;
    }
    var aTurnpoints = turnpoints as Array;
    for(var i=0; i<aTurnpoints.size(); i++) {
      var tp = aTurnpoints[i];
      if(tp == null || !(tp instanceof Lang.Dictionary)) {
        continue;
      }
      var dTp = tp as Dictionary;
      var wp = dTp.get("waypoint");
      if(wp == null || !(wp instanceof Lang.Dictionary)) {
        continue;
      }
      var dWp = wp as Dictionary;
      var name = LangUtils.readKeyString(dWp.get("name"), "TP " + (i+1).format("%d"));
      var lat = LangUtils.readKeyFloat(dWp.get("lat"), NaN);
      var lon = LangUtils.readKeyFloat(dWp.get("lon"), NaN);
      var altitude = LangUtils.readKeyFloat(dWp.get("altSmoothed"), NaN);
      var radius = LangUtils.readKeyFloat(dTp.get("radius"), 400.0f);
      var type = self.typeFromName(LangUtils.readKeyString(dTp.get("type"), ""));
      self.addTurnpoint(name, lat, lon, altitude, radius, type);
    }
    self.parseTimingV1(_task);
    self.finalizeParsedTask();
    return self.asNames.size() > 0;
  }

  function parseV2(_task as Dictionary) as Boolean {
    var turnpoints = _task.get("t");
    if(turnpoints == null || !(turnpoints instanceof Lang.Array)) {
      return false;
    }
    var aTurnpoints = turnpoints as Array;
    for(var i=0; i<aTurnpoints.size(); i++) {
      var tp = aTurnpoints[i];
      if(tp == null || !(tp instanceof Lang.Dictionary)) {
        continue;
      }
      var dTp = tp as Dictionary;
      var values = self.decodePolyline(LangUtils.readKeyString(dTp.get("z"), ""));
      if(values.size() < 4) {
        continue;
      }
      var name = LangUtils.readKeyString(dTp.get("n"), "TP " + (i+1).format("%d"));
      var type = LangUtils.readKeyNumber(dTp.get("t"), 0);
      self.addTurnpoint(name, values[1] as Float, values[0] as Float, values[2] as Float, values[3] as Float, type);
    }
    self.parseTimingV2(_task);
    self.finalizeParsedTask();
    return self.asNames.size() > 0;
  }

  function addTurnpoint(_sName as String, _fLat as Float, _fLon as Float, _fAltitude as Float, _fRadius as Float, _iType as Number) as Void {
    if(!LangUtils.notNaN(_fLat) || !LangUtils.notNaN(_fLon)) {
      return;
    }
    if(!LangUtils.notNaN(_fRadius) || _fRadius < 0.0f) {
      _fRadius = 400.0f;
    }
    self.asNames.add(_sName);
    self.afLatitude.add(_fLat);
    self.afLongitude.add(_fLon);
    self.afAltitude.add(_fAltitude);
    self.afRadius.add(_fRadius);
    self.aiType.add(_iType);
  }

  function finalizeParsedTask() as Void {
    for(var i=0; i<self.aiType.size(); i++) {
      var iType = self.aiType[i] as Number;
      if(iType == 2 && self.iStartIndex < 0) {
        self.iStartIndex = i;
      }
      if(iType == 3) {
        self.iEssIndex = i;
      }
      if(iType == 4) {
        self.iGoalIndex = i;
      }
    }
    if(self.iGoalIndex < 0 && self.asNames.size() > 0) {
      self.iGoalIndex = self.asNames.size() - 1;
    }
    if(self.iStartIndex >= 0) {
      self.iActiveIndex = self.iStartIndex;
      self.iTaskState = TASK_WAITING;
    }
    else {
      self.iActiveIndex = self.nextNavigableIndex(-1);
      self.iTaskState = TASK_STARTED;
      self.bEssReached = self.iEssIndex < 0;
    }
    self.computeTaskDistances();
  }

  function parseTimingV1(_task as Dictionary) as Void {
    var sss = _task.get("sss");
    if(sss != null && sss instanceof Lang.Dictionary) {
      var gates = (sss as Dictionary).get("timeGates");
      if(gates != null && gates instanceof Lang.Array && (gates as Array).size() > 0) {
        self.iStartSeconds = self.parseUtcSeconds((gates as Array)[0]);
      }
    }
    var goal = _task.get("goal");
    if(goal != null && goal instanceof Lang.Dictionary) {
      self.iDeadlineSeconds = self.parseUtcSeconds((goal as Dictionary).get("deadline"));
    }
  }

  function parseTimingV2(_task as Dictionary) as Void {
    var s = _task.get("s");
    if(s != null && s instanceof Lang.Dictionary) {
      var gates = (s as Dictionary).get("g");
      if(gates != null && gates instanceof Lang.Array && (gates as Array).size() > 0) {
        self.iStartSeconds = self.parseUtcSeconds((gates as Array)[0]);
      }
    }
    var g = _task.get("g");
    if(g != null && g instanceof Lang.Dictionary) {
      self.iDeadlineSeconds = self.parseUtcSeconds((g as Dictionary).get("d"));
    }
  }

  function parseUtcSeconds(_value as Object) as Number {
    var sValue = LangUtils.readKeyString(_value, "");
    if(sValue.length() < 5) {
      return -1;
    }
    try {
      var parts = LangUtils.split(sValue.substring(0, sValue.length() - (sValue.substring(sValue.length()-1, sValue.length()).equals("Z") ? 1 : 0)), ":");
      if(parts.size() < 2) {
        return -1;
      }
      var h = (parts[0] as String).toNumber();
      var m = (parts[1] as String).toNumber();
      var sec = parts.size() > 2 ? (parts[2] as String).toNumber() : 0;
      return h * 3600 + m * 60 + sec;
    } catch(e) {
      return -1;
    }
  }

  function nextNavigableIndex(_iIndex as Number) as Number {
    var i = _iIndex + 1;
    while(i < self.aiType.size() - 1 && (self.aiType[i] as Number) == 1) {
      i++;
    }
    return i;
  }

  function currentUtcSeconds() as Number {
    var info = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
    return info.hour * 3600 + info.min * 60 + info.sec;
  }

  function isAfterStart(_iSeconds as Number) as Boolean {
    return self.iStartSeconds < 0 || _iSeconds >= self.iStartSeconds;
  }

  function isBeforeDeadline(_iSeconds as Number) as Boolean {
    return self.iDeadlineSeconds < 0 || _iSeconds <= self.iDeadlineSeconds;
  }

  function getStatusText() as String {
    if(!self.bEnabled) {
      return "Off";
    }
    if(self.iState == STATE_LOADING || self.iState == STATE_ERROR || self.iState == STATE_EMPTY) {
      return self.sStatus;
    }
    switch(self.iTaskState) {
    case TASK_WAITING:
      return self.isAfterStart(self.currentUtcSeconds()) ? "Start Open" : "Wait";
    case TASK_STARTED:
      return "On Course";
    case TASK_EXPIRED:
      return "Expired";
    case TASK_COMPLETE:
      return "Done";
    default:
      return self.sStatus;
    }
  }

  function formatClock(_iSeconds as Number) as String {
    if(_iSeconds < 0) {
      return "--:--";
    }
    var iLocalSeconds = self.utcToLocalSeconds(_iSeconds);
    var h = (iLocalSeconds / 3600).toNumber();
    var m = ((iLocalSeconds % 3600) / 60).toNumber();
    return Lang.format("$1$:$2$", [h.format("%02d"), m.format("%02d")]);
  }

  function utcToLocalSeconds(_iSeconds as Number) as Number {
    var utc = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
    var local = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var iUtcNow = utc.hour * 3600 + utc.min * 60 + utc.sec;
    var iLocalNow = local.hour * 3600 + local.min * 60 + local.sec;
    var iOffset = iLocalNow - iUtcNow;
    if(iOffset > 43200) {
      iOffset -= 86400;
    }
    else if(iOffset < -43200) {
      iOffset += 86400;
    }
    var iLocalSeconds = _iSeconds + iOffset;
    while(iLocalSeconds < 0) {
      iLocalSeconds += 86400;
    }
    while(iLocalSeconds >= 86400) {
      iLocalSeconds -= 86400;
    }
    return iLocalSeconds;
  }

  function formatRemaining(_iTargetSeconds as Number) as String {
    if(_iTargetSeconds < 0) {
      return "--:--";
    }
    var remaining = _iTargetSeconds - self.currentUtcSeconds();
    if(remaining < 0) {
      remaining = 0;
    }
    var h = (remaining / 3600).toNumber();
    var m = ((remaining % 3600) / 60).toNumber();
    return Lang.format("$1$:$2$", [h.format("%01d"), m.format("%02d")]);
  }

  function getStartText() as String {
    return self.formatClock(self.iStartSeconds);
  }

  function getStartInText() as String {
    if(self.iTaskState == TASK_WAITING && !self.isAfterStart(self.currentUtcSeconds())) {
      return self.formatRemaining(self.iStartSeconds);
    }
    return "0:00";
  }

  function getTaskLeftText() as String {
    return self.formatRemaining(self.iDeadlineSeconds);
  }

  function formatTaskDistance(_fDistance as Float) as String {
    if(!LangUtils.notNaN(_fDistance)) {
      return "---";
    }
    return (_fDistance * $.oMySettings.fUnitDistanceCoefficient).format("%.0f") + " " + $.oMySettings.sUnitDistance;
  }

  function getTurnpointTypeLabel(_iIndex as Number) as String {
    if(_iIndex < 0 || _iIndex >= self.aiType.size()) {
      return "WP";
    }
    if(_iIndex == self.iGoalIndex && _iIndex == self.iEssIndex) {
      return "ESS/Goal";
    }
    if(_iIndex == self.iGoalIndex) {
      return "Goal";
    }
    switch(self.aiType[_iIndex] as Number) {
    case 1:
      return "TO";
    case 2:
      return "SSS";
    case 3:
      return "ESS";
    case 4:
      return "Goal";
    default:
      return "WP";
    }
  }

  function getTurnpointReviewLabel(_iIndex as Number) as String {
    return Lang.format("$1$ $2$", [(_iIndex + 1).format("%d"), self.getTurnpointTypeLabel(_iIndex)]);
  }

  function getTurnpointReviewValue(_iIndex as Number) as String {
    if(_iIndex < 0 || _iIndex >= self.asNames.size()) {
      return "---";
    }
    var sName = self.asNames[_iIndex] as String;
    if(sName.length() > 10) {
      sName = sName.substring(0, 10);
    }
    var sValue = Lang.format("$1$ $2$m", [sName, (self.afRadius[_iIndex] as Float).format("%.0f")]);
    var fAltitude = self.afAltitude[_iIndex] as Float;
    if(LangUtils.notNaN(fAltitude)) {
      sValue += Lang.format(" $1$m", [fAltitude.format("%.0f")]);
    }
    return sValue;
  }

  function typeFromName(_sType as String) as Number {
    if(_sType.equals("SSS")) {
      return 2;
    }
    if(_sType.equals("ESS")) {
      return 3;
    }
    if(_sType.equals("GOAL") || _sType.equals("GOAL_LINE")) {
      return 4;
    }
    if(_sType.equals("TAKEOFF")) {
      return 1;
    }
    return 0;
  }

  function decodePolyline(_sText as String) as Array<Float> {
    var values = [];
    var index = 0;
    var value = 0;
    while(index < _sText.length() && values.size() < 4) {
      var result = 0;
      var shift = 0;
      var b = 0;
      do {
        b = _sText.substring(index, index + 1).toCharArray()[0] - 63;
        index++;
        result = result | ((b & 0x1f) << shift);
        shift += 5;
      } while(b >= 0x20 && index < _sText.length());
      var delta = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      value += delta;
      if(values.size() < 2) {
        values.add(value.toFloat() / 100000.0f);
      }
      else {
        values.add(value.toFloat());
      }
    }
    return values;
  }

  function processPosition(_oLocation as Pos.Location, _fAltitude as Float, _fFinesse as Float, _bAscent as Boolean) as Void {
    if(!self.bEnabled || self.iState != STATE_READY || self.asNames.size() == 0) {
      return;
    }
    if(self.iActiveIndex >= self.asNames.size()) {
      self.iState = STATE_DONE;
      self.sStatus = "Done";
      return;
    }

    var current = _oLocation.toDegrees();
    var fLat = current[0].toFloat();
    var fLon = current[1].toFloat();
    var fCenterDistance = self.distanceMeters(fLat, fLon, self.afLatitude[self.iActiveIndex], self.afLongitude[self.iActiveIndex]);
    var fRadius = self.afRadius[self.iActiveIndex] as Float;
    self.bInsideNext = fCenterDistance <= fRadius;

    var iNow = self.currentUtcSeconds();
    self.iLastUtcSeconds = iNow;
    var bWasWaiting = self.iTaskState == TASK_WAITING;
    if(bWasWaiting) {
      self.sStatus = self.isAfterStart(iNow) ? "Start open" : "Wait";
      if(self.bInsideNext && self.isAfterStart(iNow)) {
        self.iTaskState = TASK_STARTED;
        self.bEssReached = self.iEssIndex < 0;
        self.iPendingEvent = EVENT_START;
        self.iActiveIndex = self.nextNavigableIndex(self.iStartIndex);
        if(self.iActiveIndex >= self.asNames.size()) {
          self.iActiveIndex = self.asNames.size() - 1;
        }
        fCenterDistance = self.distanceMeters(fLat, fLon, self.afLatitude[self.iActiveIndex], self.afLongitude[self.iActiveIndex]);
        fRadius = self.afRadius[self.iActiveIndex] as Float;
        self.bInsideNext = fCenterDistance <= fRadius;
      }
    }
    else if(self.iTaskState == TASK_STARTED && !self.isBeforeDeadline(iNow)) {
      self.iTaskState = TASK_EXPIRED;
      self.sStatus = "Expired";
    }

    if(!bWasWaiting && self.iTaskState != TASK_WAITING && self.bInsideNext && self.iActiveIndex < self.iGoalIndex) {
      var iReached = self.iActiveIndex;
      self.iActiveIndex = self.nextNavigableIndex(self.iActiveIndex);
      if(iReached == self.iEssIndex) {
        self.bEssReached = true;
        self.iPendingEvent = EVENT_ESS;
      }
      else if(iReached != self.iStartIndex) {
        self.iPendingEvent = EVENT_WAYPOINT;
      }
      fCenterDistance = self.distanceMeters(fLat, fLon, self.afLatitude[self.iActiveIndex], self.afLongitude[self.iActiveIndex]);
      fRadius = self.afRadius[self.iActiveIndex] as Float;
      self.bInsideNext = fCenterDistance <= fRadius;
    }
    else if(!bWasWaiting && self.iTaskState != TASK_WAITING && self.bInsideNext && self.iActiveIndex >= self.iGoalIndex) {
      if(self.iActiveIndex == self.iEssIndex) {
        self.bEssReached = true;
      }
      if(self.iTaskState == TASK_STARTED && self.isBeforeDeadline(iNow) && self.bEssReached) {
        self.iTaskState = TASK_COMPLETE;
        self.iState = STATE_DONE;
        self.sStatus = "Done";
        self.iPendingEvent = EVENT_GOAL;
      }
    }

    self.sActiveName = self.asNames[self.iActiveIndex] as String;
    self.fActiveAltitude = self.afAltitude[self.iActiveIndex] as Float;
    var target = self.getTargetPoint(fLat, fLon, self.iActiveIndex);
    self.fDistanceNext = self.distanceMeters(fLat, fLon, target[0] as Float, target[1] as Float);
    self.fBearing = self.bearingRadians(fLat, fLon, target[0] as Float, target[1] as Float);
    self.fDistanceRemaining = self.computeRemainingDistance(fLat, fLon);
    self.computeArrivalAltitude(_fAltitude, _fFinesse, _bAscent);
  }

  function consumeEvent() as Number {
    var iEvent = self.iPendingEvent;
    self.iPendingEvent = EVENT_NONE;
    return iEvent;
  }

  function computeArrivalAltitude(_fAltitude as Float, _fFinesse as Float, _bAscent as Boolean) as Void {
    self.fExpectedAltitudeNext = NaN;
    self.fAltitudeMarginNext = NaN;
    if(_bAscent || !LangUtils.notNaN(_fAltitude) || !LangUtils.notNaN(_fFinesse) || _fFinesse <= 0.0f) {
      return;
    }
    self.fExpectedAltitudeNext = _fAltitude - (self.fDistanceNext / _fFinesse);
    if(LangUtils.notNaN(self.fActiveAltitude)) {
      self.fAltitudeMarginNext = self.fExpectedAltitudeNext - self.fActiveAltitude;
    }
  }

  function getTargetPoint(_fLat as Float, _fLon as Float, _iIndex as Number) as Array<Float> {
    var iNext = self.nextNavigableIndex(_iIndex);
    if(iNext < self.asNames.size() && iNext <= self.iGoalIndex) {
      return self.getOptimizedCylinderPoint(_fLat, _fLon, _iIndex, iNext);
    }
    var fNearestBearing = self.bearingRadians(self.afLatitude[_iIndex], self.afLongitude[_iIndex], _fLat, _fLon);
    return self.destination(self.afLatitude[_iIndex], self.afLongitude[_iIndex], fNearestBearing, self.afRadius[_iIndex]);
  }

  function getOptimizedCylinderPoint(_fLat as Float, _fLon as Float, _iIndex as Number, _iNext as Number) as Array<Float> {
    var fLatCenter = self.afLatitude[_iIndex] as Float;
    var fLonCenter = self.afLongitude[_iIndex] as Float;
    var fRadius = self.afRadius[_iIndex] as Float;
    var fNextRadius = self.afRadius[_iNext] as Float;

    var aCurrent = self.toLocalMeters(_fLat, _fLon, fLatCenter, fLonCenter);
    var aNext = self.toLocalMeters(self.afLatitude[_iNext], self.afLongitude[_iNext], fLatCenter, fLonCenter);
    var cx = aCurrent[0] as Float;
    var cy = aCurrent[1] as Float;
    var nx = aNext[0] as Float;
    var ny = aNext[1] as Float;
    var dx = nx - cx;
    var dy = ny - cy;
    var len2 = dx*dx + dy*dy;
    if(len2 <= 0.0001f) {
      return [fLatCenter, fLonCenter];
    }

    var t = -(cx*dx + cy*dy) / len2;
    if(t < 0.0f) {
      t = 0.0f;
    }
    else if(t > 1.0f) {
      t = 1.0f;
    }
    var px = cx + t*dx;
    var py = cy + t*dy;
    var closest = Math.sqrt(px*px + py*py);
    if(closest <= fRadius || self.distanceMeters(fLatCenter, fLonCenter, self.afLatitude[_iNext], self.afLongitude[_iNext]) <= fRadius + fNextRadius) {
      var ix = px;
      var iy = py;
      var iLen = Math.sqrt(ix*ix + iy*iy);
      if(iLen <= 0.0001f) {
        iLen = Math.sqrt(cx*cx + cy*cy);
        ix = cx;
        iy = cy;
      }
      if(iLen > 0.0001f) {
        return self.fromLocalMeters(fLatCenter, fLonCenter, ix * fRadius / iLen, iy * fRadius / iLen);
      }
    }

    var fBearingToNext = self.bearingRadians(fLatCenter, fLonCenter, self.afLatitude[_iNext], self.afLongitude[_iNext]);
    return self.destination(fLatCenter, fLonCenter, fBearingToNext, fRadius);
  }

  function computeRemainingDistance(_fLat as Float, _fLon as Float) as Float {
    var total = self.fDistanceNext;
    var i = self.iActiveIndex;
    while(i < self.iGoalIndex) {
      var next = self.nextNavigableIndex(i);
      if(next >= self.asNames.size() || next > self.iGoalIndex) {
        break;
      }
      var leg = self.distanceMeters(self.afLatitude[i], self.afLongitude[i], self.afLatitude[next], self.afLongitude[next]);
      leg -= (self.afRadius[i] as Float) + (self.afRadius[next] as Float);
      total += leg > 0.0f ? leg : 0.0f;
      i = next;
    }
    return total;
  }

  function computeTaskDistances() as Void {
    self.fTotalCenterDistance = NaN;
    self.fOptimalTaskDistance = NaN;
    if(self.asNames.size() < 2 || self.iGoalIndex < 0) {
      return;
    }

    var iStart = self.iStartIndex >= 0 ? self.iStartIndex : self.nextNavigableIndex(-1);
    if(iStart < 0 || iStart >= self.asNames.size()) {
      return;
    }

    var fCenterTotal = 0.0f;
    var iCurrent = iStart;
    var iNext = self.nextNavigableIndex(iCurrent);
    while(iNext < self.asNames.size() && iNext <= self.iGoalIndex) {
      fCenterTotal += self.distanceMeters(self.afLatitude[iCurrent], self.afLongitude[iCurrent], self.afLatitude[iNext], self.afLongitude[iNext]);
      iCurrent = iNext;
      iNext = self.nextNavigableIndex(iCurrent);
    }
    self.fTotalCenterDistance = fCenterTotal;

    self.fOptimalTaskDistance = self.computeOptimizedDiskPathDistance(iStart);
  }

  function computeOptimizedDiskPathDistance(_iStart as Number) as Float {
    var aiIndices = [];
    var iCurrent = _iStart;
    aiIndices.add(iCurrent);
    var iNext = self.nextNavigableIndex(iCurrent);
    while(iNext < self.asNames.size() && iNext <= self.iGoalIndex) {
      aiIndices.add(iNext);
      iCurrent = iNext;
      iNext = self.nextNavigableIndex(iCurrent);
    }
    if(aiIndices.size() < 2) {
      return 0.0f;
    }

    var fRefLat = self.afLatitude[aiIndices[0] as Number] as Float;
    var fRefLon = self.afLongitude[aiIndices[0] as Number] as Float;
    var aaCenters = [];
    var aaPoints = [];
    for(var i=0; i<aiIndices.size(); i++) {
      var iIndex = aiIndices[i] as Number;
      var aCenter = self.toLocalMeters(self.afLatitude[iIndex] as Float, self.afLongitude[iIndex] as Float, fRefLat, fRefLon);
      aaCenters.add(aCenter);
      aaPoints.add([aCenter[0] as Float, aCenter[1] as Float]);
    }

    for(var iteration=0; iteration<12; iteration++) {
      var iLast = aiIndices.size() - 1;
      // XCTSK task distance starts at the SSS center; do not shorten by the start cylinder radius.
      for(var j=1; j<iLast; j++) {
        aaPoints[j] = self.bestPointInDiskBetween(aaCenters[j] as Array, self.afRadius[aiIndices[j] as Number] as Float, aaPoints[j-1] as Array, aaPoints[j+1] as Array);
      }
      aaPoints[iLast] = self.nearestPointOnDisk(aaCenters[iLast] as Array, self.afRadius[aiIndices[iLast] as Number] as Float, aaPoints[iLast-1] as Array);
    }

    var fTotal = 0.0f;
    for(var k=0; k<aaPoints.size()-1; k++) {
      fTotal += self.localDistance(aaPoints[k] as Array, aaPoints[k+1] as Array);
    }
    return fTotal;
  }

  function nearestPointOnDisk(_aCenter as Array, _fRadius as Float, _aTarget as Array) as Array<Float> {
    var dx = (_aTarget[0] as Float) - (_aCenter[0] as Float);
    var dy = (_aTarget[1] as Float) - (_aCenter[1] as Float);
    var len = Math.sqrt(dx*dx + dy*dy);
    if(len <= 0.0001f) {
      return [_aCenter[0] as Float, _aCenter[1] as Float];
    }
    return [((_aCenter[0] as Float) + dx * _fRadius / len).toFloat(), ((_aCenter[1] as Float) + dy * _fRadius / len).toFloat()];
  }

  function bestPointInDiskBetween(_aCenter as Array, _fRadius as Float, _aPrev as Array, _aNext as Array) as Array<Float> {
    var ax = _aPrev[0] as Float;
    var ay = _aPrev[1] as Float;
    var bx = _aNext[0] as Float;
    var by = _aNext[1] as Float;
    var cx = _aCenter[0] as Float;
    var cy = _aCenter[1] as Float;
    var dx = bx - ax;
    var dy = by - ay;
    var len2 = dx*dx + dy*dy;
    if(len2 <= 0.0001f) {
      return self.nearestPointOnDisk(_aCenter, _fRadius, _aPrev);
    }
    var t = ((cx - ax)*dx + (cy - ay)*dy) / len2;
    if(t < 0.0f) {
      t = 0.0f;
    }
    else if(t > 1.0f) {
      t = 1.0f;
    }
    var px = ax + t*dx;
    var py = ay + t*dy;
    var cdx = px - cx;
    var cdy = py - cy;
    var dist = Math.sqrt(cdx*cdx + cdy*cdy);
    if(dist <= _fRadius) {
      return [px.toFloat(), py.toFloat()];
    }
    return [(cx + cdx * _fRadius / dist).toFloat(), (cy + cdy * _fRadius / dist).toFloat()];
  }

  function localDistance(_aPoint1 as Array, _aPoint2 as Array) as Float {
    var dx = (_aPoint2[0] as Float) - (_aPoint1[0] as Float);
    var dy = (_aPoint2[1] as Float) - (_aPoint1[1] as Float);
    return Math.sqrt(dx*dx + dy*dy).toFloat();
  }

  function toLocalMeters(_fLat as Float, _fLon as Float, _fRefLat as Float, _fRefLon as Float) as Array<Float> {
    var refLatRad = Math.toRadians(_fRefLat);
    var x = Math.toRadians(_fLon - _fRefLon) * Math.cos(refLatRad) * EARTH_RADIUS;
    var y = Math.toRadians(_fLat - _fRefLat) * EARTH_RADIUS;
    return [x.toFloat(), y.toFloat()];
  }

  function fromLocalMeters(_fRefLat as Float, _fRefLon as Float, _fX as Float, _fY as Float) as Array<Float> {
    var refLatRad = Math.toRadians(_fRefLat);
    var lat = _fRefLat + Math.toDegrees(_fY / EARTH_RADIUS);
    var lon = _fRefLon + Math.toDegrees(_fX / (EARTH_RADIUS * Math.cos(refLatRad)));
    return [lat.toFloat(), lon.toFloat()];
  }

  function distanceMeters(_fLat1 as Float, _fLon1 as Float, _fLat2 as Float, _fLon2 as Float) as Float {
    return LangUtils.distance([Math.toRadians(_fLat1), Math.toRadians(_fLon1)], [Math.toRadians(_fLat2), Math.toRadians(_fLon2)]);
  }

  function bearingRadians(_fLat1 as Float, _fLon1 as Float, _fLat2 as Float, _fLon2 as Float) as Float {
    return LangUtils.bearing([Math.toRadians(_fLat1), Math.toRadians(_fLon1)], [Math.toRadians(_fLat2), Math.toRadians(_fLon2)]);
  }

  function destination(_fLat as Float, _fLon as Float, _fBearing as Float, _fDistance as Float) as Array<Float> {
    var lat1 = Math.toRadians(_fLat);
    var lon1 = Math.toRadians(_fLon);
    var d = _fDistance / EARTH_RADIUS;
    var lat2 = Math.asin(Math.sin(lat1) * Math.cos(d) + Math.cos(lat1) * Math.sin(d) * Math.cos(_fBearing));
    var lon2 = lon1 + Math.atan2(Math.sin(_fBearing) * Math.sin(d) * Math.cos(lat1), Math.cos(d) - Math.sin(lat1) * Math.sin(lat2));
    return [Math.toDegrees(lat2).toFloat(), Math.toDegrees(lon2).toFloat()];
  }
}
