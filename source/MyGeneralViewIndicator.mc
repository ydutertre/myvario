// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (c) 2025 Yannick Dutertre <https://yannickd9.wixsite.com/myvario>
//
// My Vario is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

import Toybox.Lang;
using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi as Ui;

class MyGeneralViewIndicator {
  public const INDICATOR_CLOCK as Number = -2;
  public const INDICATOR_UNUSED as Number = -1;
  public const INDICATOR_WIND_DIRECTION as Number = 0;
  public const INDICATOR_WIND_SPEED as Number = 1;
  public const INDICATOR_ALTITUDE as Number = 2;
  public const INDICATOR_FINESSE as Number = 3;
  public const INDICATOR_HEADING as Number = 4;
  public const INDICATOR_VERTICAL_SPEED as Number = 5;
  public const INDICATOR_GROUND_SPEED as Number = 6;
  public const INDICATOR_ALTITUDE_CHART as Number = 7;
  public const INDICATOR_HEARTBEAT as Number = 8;
  public const INDICATOR_FLIGHT_TIME as Number = 9;
  public const INDICATOR_CLIMB_30S as Number = 10;
  public const INDICATOR_THERMAL_CLIMB as Number = 11;
  public const INDICATOR_COMPETITION_NEXT as Number = 12;
  public const INDICATOR_COMPETITION_DISTANCE as Number = 13;
  public const INDICATOR_COMPETITION_REMAINING as Number = 14;
  public const INDICATOR_COMPETITION_BEARING as Number = 15;
  public const INDICATOR_COMPETITION_WAYPOINT_ALTITUDE as Number = 16;
  public const INDICATOR_COMPETITION_EXPECTED_ALTITUDE as Number = 17;
  public const INDICATOR_COMPETITION_ALTITUDE_MARGIN as Number = 18;
  public const INDICATOR_COMPETITION_STATUS as Number = 19;
  public const INDICATOR_COMPETITION_START as Number = 20;
  public const INDICATOR_COMPETITION_TASK_LEFT as Number = 21;
  public const INDICATOR_COMPETITION_START_IN as Number = 22;
  public const INDICATOR_COUNT as Number = 23;

  function initialize() {
  }

  function isValidIndicator(_iIndicator as Number) as Boolean {
    return _iIndicator >= 0 && _iIndicator < INDICATOR_COUNT;
  }

  function getMenuLabel(_iIndicator as Number) as String {
    switch(_iIndicator) {
    case INDICATOR_CLOCK:
      return "Clock";
    case INDICATOR_UNUSED:
      return "None";
    case INDICATOR_WIND_DIRECTION:
      return "Wind Direction";
    case INDICATOR_WIND_SPEED:
      return "Wind Speed";
    case INDICATOR_ALTITUDE:
      return "Altitude";
    case INDICATOR_FINESSE:
      return "Finesse";
    case INDICATOR_HEADING:
      return "Heading";
    case INDICATOR_VERTICAL_SPEED:
      return "Vert. Speed";
    case INDICATOR_GROUND_SPEED:
      return "Ground Speed";
    case INDICATOR_ALTITUDE_CHART:
      return "Altitude Chart";
    case INDICATOR_HEARTBEAT:
      return "Heartbeat";
    case INDICATOR_FLIGHT_TIME:
      return "Flight Time";
    case INDICATOR_CLIMB_30S:
      return "30s Climb";
    case INDICATOR_THERMAL_CLIMB:
      return "Therm.Climb";
    case INDICATOR_COMPETITION_NEXT:
      return "Next WP";
    case INDICATOR_COMPETITION_DISTANCE:
      return "WP Dist.";
    case INDICATOR_COMPETITION_REMAINING:
      return "Task Dist.";
    case INDICATOR_COMPETITION_BEARING:
      return "WP Bearing";
    case INDICATOR_COMPETITION_WAYPOINT_ALTITUDE:
      return "WP Alt.";
    case INDICATOR_COMPETITION_EXPECTED_ALTITUDE:
      return "Arr Alt.";
    case INDICATOR_COMPETITION_ALTITUDE_MARGIN:
      return "Alt Margin";
    case INDICATOR_COMPETITION_STATUS:
      return "Comp";
    case INDICATOR_COMPETITION_START:
      return "Start";
    case INDICATOR_COMPETITION_TASK_LEFT:
      return "Task Left";
    case INDICATOR_COMPETITION_START_IN:
      return "Start In";
    default:
      return "";
    }
  }

  function addPickerEntries(_aKeys as Array, _aValues as Array, _bIncludeClock as Boolean, _bIncludeNone as Boolean, _bIncludeAltitudeChart as Boolean) as Void {
    if(_bIncludeClock) {
      _aKeys.add(INDICATOR_CLOCK);
      _aValues.add(self.getMenuLabel(INDICATOR_CLOCK));
    }
    _aKeys.add(INDICATOR_WIND_DIRECTION);
    _aValues.add(self.getMenuLabel(INDICATOR_WIND_DIRECTION));
    _aKeys.add(INDICATOR_WIND_SPEED);
    _aValues.add(self.getMenuLabel(INDICATOR_WIND_SPEED));
    _aKeys.add(INDICATOR_ALTITUDE);
    _aValues.add(self.getMenuLabel(INDICATOR_ALTITUDE));
    _aKeys.add(INDICATOR_FINESSE);
    _aValues.add("Finesse (Glide Ratio)");
    _aKeys.add(INDICATOR_HEADING);
    _aValues.add(self.getMenuLabel(INDICATOR_HEADING));
    _aKeys.add(INDICATOR_VERTICAL_SPEED);
    _aValues.add("Vertical Speed");
    _aKeys.add(INDICATOR_GROUND_SPEED);
    _aValues.add(self.getMenuLabel(INDICATOR_GROUND_SPEED));
    _aKeys.add(INDICATOR_FLIGHT_TIME);
    _aValues.add(self.getMenuLabel(INDICATOR_FLIGHT_TIME));
    _aKeys.add(INDICATOR_HEARTBEAT);
    _aValues.add(self.getMenuLabel(INDICATOR_HEARTBEAT));
    _aKeys.add(INDICATOR_CLIMB_30S);
    _aValues.add(self.getMenuLabel(INDICATOR_CLIMB_30S));
    _aKeys.add(INDICATOR_THERMAL_CLIMB);
    _aValues.add(self.getMenuLabel(INDICATOR_THERMAL_CLIMB));
    if(_bIncludeAltitudeChart) {
      _aKeys.add(INDICATOR_ALTITUDE_CHART);
      _aValues.add(self.getMenuLabel(INDICATOR_ALTITUDE_CHART));
    }
    if($.oMySettings.bCompetitionMode) {
      _aKeys.add(INDICATOR_COMPETITION_NEXT);
      _aValues.add(self.getMenuLabel(INDICATOR_COMPETITION_NEXT));
      _aKeys.add(INDICATOR_COMPETITION_DISTANCE);
      _aValues.add("WP Distance");
      _aKeys.add(INDICATOR_COMPETITION_REMAINING);
      _aValues.add("Task Distance");
      _aKeys.add(INDICATOR_COMPETITION_BEARING);
      _aValues.add(self.getMenuLabel(INDICATOR_COMPETITION_BEARING));
      _aKeys.add(INDICATOR_COMPETITION_WAYPOINT_ALTITUDE);
      _aValues.add("WP Altitude");
      _aKeys.add(INDICATOR_COMPETITION_EXPECTED_ALTITUDE);
      _aValues.add("Arrival Alt");
      _aKeys.add(INDICATOR_COMPETITION_ALTITUDE_MARGIN);
      _aValues.add(self.getMenuLabel(INDICATOR_COMPETITION_ALTITUDE_MARGIN));
      _aKeys.add(INDICATOR_COMPETITION_STATUS);
      _aValues.add("Comp Status");
      _aKeys.add(INDICATOR_COMPETITION_START);
      _aValues.add("Start Time");
      _aKeys.add(INDICATOR_COMPETITION_TASK_LEFT);
      _aValues.add(self.getMenuLabel(INDICATOR_COMPETITION_TASK_LEFT));
      _aKeys.add(INDICATOR_COMPETITION_START_IN);
      _aValues.add(self.getMenuLabel(INDICATOR_COMPETITION_START_IN));
    }
    if(_bIncludeNone) {
      _aKeys.add(INDICATOR_UNUSED);
      _aValues.add(self.getMenuLabel(INDICATOR_UNUSED));
    }
  }

  function getLabelText(_iIndicator as Number) as String {
    switch(_iIndicator) {
    case INDICATOR_CLOCK:
      return "Clock";
    case INDICATOR_WIND_DIRECTION:
      return Ui.loadResource(Rez.Strings.labelWindDirection) as String;
    case INDICATOR_WIND_SPEED:
      return Ui.loadResource(Rez.Strings.labelWindSpeed) as String;
    case INDICATOR_ALTITUDE:
      return Ui.loadResource(Rez.Strings.labelAltitude) as String;
    case INDICATOR_FINESSE:
      return Ui.loadResource(Rez.Strings.labelFinesse) as String;
    case INDICATOR_HEADING:
      return Ui.loadResource(Rez.Strings.labelHeading) as String;
    case INDICATOR_VERTICAL_SPEED:
      return Ui.loadResource(Rez.Strings.labelVerticalSpeed) as String;
    case INDICATOR_GROUND_SPEED:
      return Ui.loadResource(Rez.Strings.labelGroundSpeed) as String;
    case INDICATOR_ALTITUDE_CHART:
      return Ui.loadResource(Rez.Strings.labelAltitude) as String;
    case INDICATOR_HEARTBEAT:
      return "Heartbeat";
    case INDICATOR_FLIGHT_TIME:
      return Ui.loadResource(Rez.Strings.labelElapsed) as String;
    case INDICATOR_CLIMB_30S:
      return "30s Climb";
    case INDICATOR_THERMAL_CLIMB:
      return "Therm.Climb";
    case INDICATOR_COMPETITION_NEXT:
      return Ui.loadResource(Rez.Strings.labelCompetitionNext) as String;
    case INDICATOR_COMPETITION_DISTANCE:
      return Ui.loadResource(Rez.Strings.labelCompetitionDistance) as String;
    case INDICATOR_COMPETITION_REMAINING:
      return Ui.loadResource(Rez.Strings.labelCompetitionRemaining) as String;
    case INDICATOR_COMPETITION_BEARING:
      return Ui.loadResource(Rez.Strings.labelCompetitionBearing) as String;
    case INDICATOR_COMPETITION_WAYPOINT_ALTITUDE:
      return Ui.loadResource(Rez.Strings.labelCompetitionWaypointAltitude) as String;
    case INDICATOR_COMPETITION_EXPECTED_ALTITUDE:
      return Ui.loadResource(Rez.Strings.labelCompetitionExpectedAltitude) as String;
    case INDICATOR_COMPETITION_ALTITUDE_MARGIN:
      return Ui.loadResource(Rez.Strings.labelCompetitionAltitudeMargin) as String;
    case INDICATOR_COMPETITION_STATUS:
      return Ui.loadResource(Rez.Strings.labelCompetitionStatus) as String;
    case INDICATOR_COMPETITION_START:
      return Ui.loadResource(Rez.Strings.labelCompetitionStart) as String;
    case INDICATOR_COMPETITION_TASK_LEFT:
      return Ui.loadResource(Rez.Strings.labelCompetitionTaskLeft) as String;
    case INDICATOR_COMPETITION_START_IN:
      return Ui.loadResource(Rez.Strings.labelCompetitionStartIn) as String;
    default:
      return "";
    }
  }

  function getUnitText(_iIndicator as Number) as String {
    switch(_iIndicator) {
    case INDICATOR_CLOCK:
      return "";
    case INDICATOR_WIND_DIRECTION:
    case INDICATOR_HEADING:
      return ($.oMySettings.iUnitDirection == 0) ? "[Deg]" : "";
    case INDICATOR_WIND_SPEED:
      return Lang.format("[$1$]", [$.oMySettings.sUnitWindSpeed]);
    case INDICATOR_ALTITUDE:
    case INDICATOR_ALTITUDE_CHART:
      return Lang.format("[$1$]", [$.oMySettings.sUnitElevation]);
    case INDICATOR_VERTICAL_SPEED:
    case INDICATOR_CLIMB_30S:
    case INDICATOR_THERMAL_CLIMB:
      return Lang.format("[$1$]", [$.oMySettings.sUnitVerticalSpeed]);
    case INDICATOR_GROUND_SPEED:
      return Lang.format("[$1$]", [$.oMySettings.sUnitHorizontalSpeed]);
    case INDICATOR_HEARTBEAT:
      return "[bpm]";
    case INDICATOR_FLIGHT_TIME:
      return $.MY_NOVALUE_BLANK;
    case INDICATOR_COMPETITION_DISTANCE:
    case INDICATOR_COMPETITION_REMAINING:
      return Lang.format("[$1$]", [$.oMySettings.sUnitDistance]);
    case INDICATOR_COMPETITION_BEARING:
      return ($.oMySettings.iUnitDirection == 0) ? "[Deg]" : "";
    case INDICATOR_COMPETITION_NEXT:
      return $.MY_NOVALUE_BLANK;
    case INDICATOR_COMPETITION_WAYPOINT_ALTITUDE:
    case INDICATOR_COMPETITION_EXPECTED_ALTITUDE:
    case INDICATOR_COMPETITION_ALTITUDE_MARGIN:
      return Lang.format("[$1$]", [$.oMySettings.sUnitElevation]);
    case INDICATOR_COMPETITION_STATUS:
    case INDICATOR_COMPETITION_START:
    case INDICATOR_COMPETITION_TASK_LEFT:
    case INDICATOR_COMPETITION_START_IN:
      return $.MY_NOVALUE_BLANK;
    default:
      return "";
    }
  }

  function getPlainUnitText(_iIndicator as Number) as String {
    switch(_iIndicator) {
    case INDICATOR_WIND_DIRECTION:
    case INDICATOR_HEADING:
      return ($.oMySettings.iUnitDirection == 0) ? "deg" : "";
    case INDICATOR_WIND_SPEED:
      return $.oMySettings.sUnitWindSpeed;
    case INDICATOR_ALTITUDE:
      return $.oMySettings.sUnitElevation;
    case INDICATOR_VERTICAL_SPEED:
    case INDICATOR_CLIMB_30S:
    case INDICATOR_THERMAL_CLIMB:
      return $.oMySettings.sUnitVerticalSpeed;
    case INDICATOR_GROUND_SPEED:
      return $.oMySettings.sUnitHorizontalSpeed;
    case INDICATOR_HEARTBEAT:
      return "bpm";
    case INDICATOR_COMPETITION_DISTANCE:
    case INDICATOR_COMPETITION_REMAINING:
      return $.oMySettings.sUnitDistance;
    case INDICATOR_COMPETITION_BEARING:
      return ($.oMySettings.iUnitDirection == 0) ? "deg" : "";
    case INDICATOR_COMPETITION_WAYPOINT_ALTITUDE:
    case INDICATOR_COMPETITION_EXPECTED_ALTITUDE:
    case INDICATOR_COMPETITION_ALTITUDE_MARGIN:
      return $.oMySettings.sUnitElevation;
    default:
      return "";
    }
  }

  function getValueText(_iIndicator as Number) as String {
    var sValue = "";
    var fValue;
    var iValue;
    switch(_iIndicator) {
    case INDICATOR_CLOCK:
      var oTimeNow = Time.now();
      var oTimeInfo = $.oMySettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
      return Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.oMySettings.sUnitTime]);
    case INDICATOR_ALTITUDE:
      fValue = $.oMyProcessing.fAltitude;
      if(LangUtils.notNaN(fValue)) {
        fValue *= $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_VERTICAL_SPEED:
      fValue = $.oMyProcessing.fVariometer_filtered;
      if(LangUtils.notNaN(fValue)) {
        fValue *= $.oMySettings.fUnitVerticalSpeedCoefficient;
        sValue = $.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f ? fValue.format("%+.1f") : fValue.format("%+.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_WIND_DIRECTION:
      iValue = $.oMyProcessing.iWindDirection;
      if(LangUtils.notNaN(iValue) && $.oMyProcessing.bWindValid) {
        sValue = $.oMySettings.iUnitDirection == 1 ? $.oMyProcessing.convertDirection(iValue) : iValue.format("%d");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_WIND_SPEED:
      fValue = $.oMyProcessing.fWindSpeed;
      if(LangUtils.notNaN(fValue) && $.oMyProcessing.bWindValid) {
        fValue *= $.oMySettings.fUnitWindSpeedCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_FINESSE:
      sValue = (LangUtils.notNaN($.oMyProcessing.fFinesse) && !$.oMyProcessing.bAscent) ? $.oMyProcessing.fFinesse.format("%.0f") : $.MY_NOVALUE_LEN2;
      break;
    case INDICATOR_HEADING:
      fValue = $.oMyProcessing.fHeading;
      if(LangUtils.notNaN(fValue)) {
        fValue = ((fValue * 57.2957795131f).toNumber()) % 360;
        sValue = $.oMySettings.iUnitDirection == 1 ? $.oMyProcessing.convertDirection(fValue) : fValue.format("%d");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_GROUND_SPEED:
      fValue = $.oMyProcessing.fGroundSpeed;
      if(LangUtils.notNaN(fValue)) {
        fValue *= $.oMySettings.fUnitHorizontalSpeedCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_ALTITUDE_CHART:
      sValue = "";
      break;
    case INDICATOR_HEARTBEAT:
      sValue = LangUtils.notNaN($.oMyProcessing.iHR) ? ($.oMyProcessing.iHR as Number).format("%d") : $.MY_NOVALUE_LEN3;
      break;
    case INDICATOR_FLIGHT_TIME:
      sValue = $.oMyActivity != null ? ($.oMyActivity as MyActivity).getFlightTime() : "--:--";
      break;
    case INDICATOR_CLIMB_30S:
      sValue = self.formatClimbValue(self.getAverageClimb(30, -1));
      break;
    case INDICATOR_THERMAL_CLIMB:
      if($.oMyProcessing.bCirclingCount > 0) {
        sValue = self.formatClimbValue(self.getAverageClimb($.oMyProcessing.PLOTBUFFER_SIZE, $.oMyProcessing.iCirclingStartEpoch));
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_COMPETITION_NEXT:
      if($.oMyCompetitionTask != null && ($.oMyCompetitionTask.iState == $.oMyCompetitionTask.STATE_READY || $.oMyCompetitionTask.iState == $.oMyCompetitionTask.STATE_DONE)) {
        sValue = $.oMyCompetitionTask.sActiveName;
        if(sValue.length() > 8) {
          sValue = sValue.substring(0, 8);
        }
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_COMPETITION_DISTANCE:
      if($.oMyCompetitionTask != null && LangUtils.notNaN($.oMyCompetitionTask.fDistanceNext)) {
        fValue = $.oMyCompetitionTask.fDistanceNext * $.oMySettings.fUnitDistanceCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_COMPETITION_REMAINING:
      if($.oMyCompetitionTask != null && LangUtils.notNaN($.oMyCompetitionTask.fDistanceRemaining)) {
        fValue = $.oMyCompetitionTask.fDistanceRemaining * $.oMySettings.fUnitDistanceCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_COMPETITION_BEARING:
      if($.oMyCompetitionTask != null && LangUtils.notNaN($.oMyCompetitionTask.fBearing)) {
        fValue = (($.oMyCompetitionTask.fBearing * 57.2957795131f).toNumber()) % 360;
        sValue = $.oMySettings.iUnitDirection == 1 ? $.oMyProcessing.convertDirection(fValue) : fValue.format("%d");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_COMPETITION_WAYPOINT_ALTITUDE:
      if($.oMyCompetitionTask != null && LangUtils.notNaN($.oMyCompetitionTask.fActiveAltitude)) {
        fValue = $.oMyCompetitionTask.fActiveAltitude * $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_COMPETITION_EXPECTED_ALTITUDE:
      if($.oMyCompetitionTask != null && LangUtils.notNaN($.oMyCompetitionTask.fExpectedAltitudeNext)) {
        fValue = $.oMyCompetitionTask.fExpectedAltitudeNext * $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_COMPETITION_ALTITUDE_MARGIN:
      if($.oMyCompetitionTask != null && LangUtils.notNaN($.oMyCompetitionTask.fAltitudeMarginNext)) {
        fValue = $.oMyCompetitionTask.fAltitudeMarginNext * $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%+.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case INDICATOR_COMPETITION_STATUS:
      sValue = $.oMyCompetitionTask != null ? $.oMyCompetitionTask.getStatusText() : $.MY_NOVALUE_LEN3;
      break;
    case INDICATOR_COMPETITION_START:
      sValue = $.oMyCompetitionTask != null ? $.oMyCompetitionTask.getStartText() : "--:--";
      break;
    case INDICATOR_COMPETITION_TASK_LEFT:
      sValue = $.oMyCompetitionTask != null ? $.oMyCompetitionTask.getTaskLeftText() : "--:--";
      break;
    case INDICATOR_COMPETITION_START_IN:
      sValue = $.oMyCompetitionTask != null ? $.oMyCompetitionTask.getStartInText() : "--:--";
      break;
    default:
      sValue = "";
    }
    return sValue;
  }

  function isValueNumeric(_iIndicator as Number, _sText as String) as Boolean {
    if(_sText == "" or _sText == $.MY_NOVALUE_LEN2 or _sText == $.MY_NOVALUE_LEN3) {
      return false;
    }

    switch(_iIndicator) {
    case INDICATOR_WIND_DIRECTION:
    case INDICATOR_HEADING:
      return $.oMySettings.iUnitDirection != 1;
    case INDICATOR_ALTITUDE:
    case INDICATOR_VERTICAL_SPEED:
    case INDICATOR_CLIMB_30S:
    case INDICATOR_THERMAL_CLIMB:
    case INDICATOR_WIND_SPEED:
    case INDICATOR_FINESSE:
    case INDICATOR_GROUND_SPEED:
    case INDICATOR_HEARTBEAT:
    case INDICATOR_COMPETITION_DISTANCE:
    case INDICATOR_COMPETITION_REMAINING:
    case INDICATOR_COMPETITION_WAYPOINT_ALTITUDE:
    case INDICATOR_COMPETITION_EXPECTED_ALTITUDE:
    case INDICATOR_COMPETITION_ALTITUDE_MARGIN:
      return true;
    case INDICATOR_COMPETITION_BEARING:
      return $.oMySettings.iUnitDirection != 1;
    case INDICATOR_CLOCK:
    case INDICATOR_COMPETITION_STATUS:
    case INDICATOR_COMPETITION_START:
    case INDICATOR_COMPETITION_TASK_LEFT:
    case INDICATOR_COMPETITION_START_IN:
      return false;
    default:
      return false;
    }
  }

  function getValueColor(_iIndicator as Number, _bRecording as Boolean, _iDefaultColor as Number) as Number {
    var iColor = _iDefaultColor;
    var fValue;
    switch(_iIndicator) {
    case INDICATOR_CLOCK:
      break;
    case INDICATOR_VERTICAL_SPEED:
      fValue = $.oMyProcessing.fVariometer_filtered;
      iColor = self.getClimbValueColor(fValue, _iDefaultColor);
      break;
    case INDICATOR_CLIMB_30S:
      fValue = self.getAverageClimb(30, -1);
      iColor = self.getClimbValueColor(fValue, _iDefaultColor);
      break;
    case INDICATOR_THERMAL_CLIMB:
      if($.oMyProcessing.bCirclingCount > 0) {
        fValue = self.getAverageClimb($.oMyProcessing.PLOTBUFFER_SIZE, $.oMyProcessing.iCirclingStartEpoch);
        iColor = self.getClimbValueColor(fValue, _iDefaultColor);
      }
      else {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case INDICATOR_WIND_SPEED:
      if(!_bRecording) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case INDICATOR_WIND_DIRECTION:
      if(!($.oMyProcessing.bWindValid && LangUtils.notNaN($.oMyProcessing.iWindDirection))) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case INDICATOR_HEADING:
      if(!LangUtils.notNaN($.oMyProcessing.fHeading)) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case INDICATOR_ALTITUDE:
      if(!LangUtils.notNaN($.oMyProcessing.fAltitude)) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case INDICATOR_GROUND_SPEED:
      if(!LangUtils.notNaN($.oMyProcessing.fGroundSpeed)) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case INDICATOR_ALTITUDE_CHART:
      iColor = _iDefaultColor;
      break;
    case INDICATOR_HEARTBEAT:
      if(!LangUtils.notNaN($.oMyProcessing.iHR)) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case INDICATOR_FLIGHT_TIME:
      if($.oMyActivity == null or ($.oMyActivity as MyActivity).oTimeStart == null) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case INDICATOR_FINESSE:
      if(!(LangUtils.notNaN($.oMyProcessing.fFinesse) && !$.oMyProcessing.bAscent)) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case INDICATOR_COMPETITION_NEXT:
    case INDICATOR_COMPETITION_DISTANCE:
    case INDICATOR_COMPETITION_REMAINING:
    case INDICATOR_COMPETITION_BEARING:
    case INDICATOR_COMPETITION_WAYPOINT_ALTITUDE:
    case INDICATOR_COMPETITION_EXPECTED_ALTITUDE:
    case INDICATOR_COMPETITION_ALTITUDE_MARGIN:
    case INDICATOR_COMPETITION_STATUS:
    case INDICATOR_COMPETITION_START:
    case INDICATOR_COMPETITION_TASK_LEFT:
    case INDICATOR_COMPETITION_START_IN:
      if($.oMyCompetitionTask == null || $.oMyCompetitionTask.iState != $.oMyCompetitionTask.STATE_READY) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      else if(_iIndicator == INDICATOR_COMPETITION_ALTITUDE_MARGIN && LangUtils.notNaN($.oMyCompetitionTask.fAltitudeMarginNext)) {
        iColor = $.oMyCompetitionTask.fAltitudeMarginNext >= 0.0f ? Gfx.COLOR_DK_GREEN : Gfx.COLOR_RED;
      }
      break;
    default:
      iColor = Gfx.COLOR_LT_GRAY;
    }
    return iColor;
  }

  function formatClimbValue(_fValue as Float) as String {
    if(LangUtils.notNaN(_fValue)) {
      _fValue *= $.oMySettings.fUnitVerticalSpeedCoefficient;
      if($.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        return _fValue.format("%+.1f");
      }
      else {
        return _fValue.format("%+.0f");
      }
    }
    return $.MY_NOVALUE_LEN3;
  }

  function getClimbValueColor(_fValue as Float, _iDefaultColor as Number) as Number {
    if(LangUtils.notNaN(_fValue)) {
      _fValue *= $.oMySettings.fUnitVerticalSpeedCoefficient;
      if($.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        if(_fValue >= 0.05f) {
          return Gfx.COLOR_DK_GREEN;
        }
        else if(_fValue <= -0.05f) {
          return Gfx.COLOR_RED;
        }
      }
      else {
        if(_fValue >= 0.5f) {
          return Gfx.COLOR_DK_GREEN;
        }
        else if(_fValue <= -0.5f) {
          return Gfx.COLOR_RED;
        }
      }
      return _iDefaultColor;
    }
    return Gfx.COLOR_LT_GRAY;
  }

  function getAverageClimb(_iSeconds as Number, _iStartEpoch as Number) as Float {
    if($.oMyProcessing.iPlotIndex < 0) {
      return NaN;
    }

    var iCurrentEpoch = $.oMyProcessing.iPositionEpoch;
    var iSampleCount = 0;
    var iTotalClimb = 0;
    for(var i=0; i<$.oMyProcessing.PLOTBUFFER_SIZE; i++) {
      var iIndex = ($.oMyProcessing.iPlotIndex - i + $.oMyProcessing.PLOTBUFFER_SIZE) % $.oMyProcessing.PLOTBUFFER_SIZE;
      var iEpoch = $.oMyProcessing.aiPlotEpoch[iIndex] as Number;
      if(iEpoch < 0) {
        continue;
      }
      if(_iStartEpoch >= 0 && iEpoch < _iStartEpoch) {
        continue;
      }
      if(_iSeconds > 0 && iCurrentEpoch - iEpoch >= _iSeconds) {
        continue;
      }
      var iClimb = $.oMyProcessing.aiPlotVariometer[iIndex] as Number;
      if(!LangUtils.notNaN(iClimb)) {
        continue;
      }
      iTotalClimb += iClimb;
      iSampleCount++;
    }

    if(iSampleCount == 0) {
      return NaN;
    }
    return iTotalClimb.toFloat() / (iSampleCount.toFloat() * 1000.0f);
  }
}
