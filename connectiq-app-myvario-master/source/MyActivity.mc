// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (C) 2022 Yannick Dutertre <https://yannickd9.wixsite.com/>
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
// My Vario is based on Glider's Swiss Knife (GliderSK) by Cedric Dufour

// Glider's Swiss Knife (GliderSK)
// Copyright (C) 2017-2022 Cedric Dufour <http://cedric.dufour.name>
//
// Glider's Swiss Knife (GliderSK) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Glider's Swiss Knife (GliderSK) is distributed in the hope that it will be
// useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

import Toybox.Lang;
using Toybox.Activity;
using Toybox.ActivityRecording as AR;
using Toybox.Application as App;
using Toybox.Attention as Attn;
using Toybox.FitContributor as FC;
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.System as Sys;

//
// CLASS
//

class MyActivity {

  //
  // CONSTANTS
  //

  // FIT fields (as per resources/fit.xml)
  // ... record
  public const FITFIELD_VERTICALSPEED = 0;
  public const FITFIELD_RATEOFTURN = 1;
  public const FITFIELD_ACCELERATION = 2;
  public const FITFIELD_BAROMETRICALTITUDE = 3;
  // ... lap
  public const FITFIELD_DISTANCE = 10;
  public const FITFIELD_ASCENT = 11;
  public const FITFIELD_ELAPSEDASCENT = 12;
  public const FITFIELD_ALTITUDEMIN = 13;
  public const FITFIELD_TIMEALTITUDEMIN = 14;
  public const FITFIELD_ALTITUDEMAX = 15;
  public const FITFIELD_TIMEALTITUDEMAX = 16;
  // ... session
  public const FITFIELD_GLOBALDISTANCE = 80;
  public const FITFIELD_GLOBALASCENT = 81;
  public const FITFIELD_GLOBALELAPSEDASCENT = 82;
  public const FITFIELD_GLOBALALTITUDEMIN = 83;
  public const FITFIELD_GLOBALTIMEALTITUDEMIN = 84;
  public const FITFIELD_GLOBALALTITUDEMAX = 85;
  public const FITFIELD_GLOBALTIMEALTITUDEMAX = 86;


  //
  // VARIABLES
  //

  // Session
  // ... recording
  private var oSession as AR.Session;
  public var oTimeStart as Time.Moment?;
  public var oTimeLap as Time.Moment?;
  public var iCountLaps as Number = -1;
  public var oTimeStop as Time.Moment?;
  // ... lap
  public var fDistance as Float = 0.0f;
  public var fAscent as Float = 0.0f;
  public var iElapsedAscent as Number = 0;
  public var fAltitudeMin as Float = NaN;
  public var oTimeAltitudeMin as Time.Moment?;
  public var fAltitudeMax as Float = NaN;
  public var oTimeAltitudeMax as Time.Moment?;
  // ... session
  public var fGlobalDistance as Float = 0.0f;
  public var fGlobalAscent as Float = 0.0f;
  public var iGlobalElapsedAscent as Number = 0;
  public var fGlobalAltitudeMin as Float = NaN;
  public var oGlobalTimeAltitudeMin as Time.Moment?;
  public var fGlobalAltitudeMax as Float = NaN;
  public var oGlobalTimeAltitudeMax as Time.Moment?;
  // ... internals
  private var iEpochLast as Number = -1;
  private var adPositionRadiansLast as Array<Double>?;
  private var fAltitudeLast as Float = NaN;

  // FIT fields
  // ... (unit conversion) coefficients
  private var bUnitCoefficient_TimeUTC as Boolean = false;
  private var fUnitCoefficient_Distance as Float = 1.0f;
  private var fUnitCoefficient_Altitude as Float = 1.0f;
  private var fUnitCoefficient_VerticalSpeed as Float = 1.0f;
  private var fUnitCoefficient_RateOfTurn as Float = 1.0f;
  // ... record
  private var oFitField_BarometricAltitude as FC.Field;
  private var oFitField_VerticalSpeed as FC.Field;
  private var oFitField_RateOfTurn as FC.Field;
  private var oFitField_Acceleration as FC.Field;
  // ... lap
  private var oFitField_Distance as FC.Field;
  private var oFitField_Ascent as FC.Field;
  private var oFitField_ElapsedAscent as FC.Field;
  private var oFitField_AltitudeMin as FC.Field;
  private var oFitField_TimeAltitudeMin as FC.Field;
  private var oFitField_AltitudeMax as FC.Field;
  private var oFitField_TimeAltitudeMax as FC.Field;
  // ... session
  private var oFitField_GlobalDistance as FC.Field;
  private var oFitField_GlobalAscent as FC.Field;
  private var oFitField_GlobalElapsedAscent as FC.Field;
  private var oFitField_GlobalAltitudeMin as FC.Field;
  private var oFitField_GlobalTimeAltitudeMin as FC.Field;
  private var oFitField_GlobalAltitudeMax as FC.Field;
  private var oFitField_GlobalTimeAltitudeMax as FC.Field;

  // Log fields


  //
  // FUNCTIONS: self
  //

  function initialize() {
    //Sys.println("DEBUG: MyActivity.initialize()");

    // Session (recording)
    // SPORT_FLYING = 20 (since API 3.0.10)
    oSession = AR.createSession({
        :name => "GliderSK",
        :sport => 20 as AR.Sport2,
        :subSport => AR.SUB_SPORT_GENERIC});

    // FIT fields

    // ... (unit conversion) coefficients
    bUnitCoefficient_TimeUTC = $.oMySettings.bUnitTimeUTC;
    fUnitCoefficient_Distance = $.oMySettings.fUnitDistanceCoefficient;
    fUnitCoefficient_Altitude = $.oMySettings.fUnitElevationCoefficient;
    fUnitCoefficient_VerticalSpeed = $.oMySettings.fUnitVerticalSpeedCoefficient;
    fUnitCoefficient_RateOfTurn = $.oMySettings.fUnitRateOfTurnCoefficient;

    // ... record
    oFitField_BarometricAltitude =
      oSession.createField("BarometricAltitude",
                           MyActivity.FITFIELD_BAROMETRICALTITUDE,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_RECORD, :units => $.oMySettings.sUnitElevation});
    oFitField_VerticalSpeed =
      oSession.createField("VerticalSpeed",
                           MyActivity.FITFIELD_VERTICALSPEED,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_RECORD, :units => $.oMySettings.sUnitVerticalSpeed});
    oFitField_RateOfTurn =
      oSession.createField("RateOfTurn",
                           MyApp.FITFIELD_RATEOFTURN,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_RECORD, :units => $.oMySettings.sUnitRateOfTurn});
    oFitField_Acceleration =
      oSession.createField("Acceleration",
                           MyApp.FITFIELD_ACCELERATION,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_RECORD, :units => "g"});

    // ... lap
    oFitField_Distance =
      oSession.createField("Distance",
                           MyActivity.FITFIELD_DISTANCE,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_LAP, :units => $.oMySettings.sUnitDistance});
    oFitField_Ascent =
      oSession.createField("Ascent",
                           MyActivity.FITFIELD_ASCENT,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_LAP, :units => $.oMySettings.sUnitElevation});
    oFitField_ElapsedAscent =
      oSession.createField("ElapsedAscent",
                           MyActivity.FITFIELD_ELAPSEDASCENT,
                           FC.DATA_TYPE_STRING,
                           {:mesgType => FC.MESG_TYPE_LAP, :count => 9});
    oFitField_AltitudeMin =
      oSession.createField("AltitudeMin",
                           MyActivity.FITFIELD_ALTITUDEMIN,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_LAP, :units => $.oMySettings.sUnitElevation});
    oFitField_TimeAltitudeMin =
      oSession.createField("TimeAltitudeMin",
                           MyActivity.FITFIELD_TIMEALTITUDEMIN,
                           FC.DATA_TYPE_STRING,
                           {:mesgType => FC.MESG_TYPE_LAP, :count => 9, :units => $.oMySettings.sUnitTime});
    oFitField_AltitudeMax =
      oSession.createField("AltitudeMax",
                           MyActivity.FITFIELD_ALTITUDEMAX,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_LAP, :units => $.oMySettings.sUnitElevation});
    oFitField_TimeAltitudeMax =
      oSession.createField("TimeAltitudeMax",
                           MyActivity.FITFIELD_TIMEALTITUDEMAX,
                           FC.DATA_TYPE_STRING,
                           {:mesgType => FC.MESG_TYPE_LAP, :count => 9, :units => $.oMySettings.sUnitTime});
    self.resetLapFields();

    // ... session
    oFitField_GlobalDistance =
      oSession.createField("Distance",
                           MyActivity.FITFIELD_GLOBALDISTANCE,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_SESSION, :units => $.oMySettings.sUnitDistance});
    oFitField_GlobalAscent =
      oSession.createField("Ascent",
                           MyActivity.FITFIELD_GLOBALASCENT,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_SESSION, :units => $.oMySettings.sUnitElevation});
    oFitField_GlobalElapsedAscent =
      oSession.createField("ElapsedAscent",
                           MyActivity.FITFIELD_GLOBALELAPSEDASCENT,
                           FC.DATA_TYPE_STRING,
                           {:mesgType => FC.MESG_TYPE_SESSION, :count => 9});
    oFitField_GlobalAltitudeMin =
      oSession.createField("AltitudeMin",
                           MyActivity.FITFIELD_GLOBALALTITUDEMIN,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_SESSION, :units => $.oMySettings.sUnitElevation});
    oFitField_GlobalTimeAltitudeMin =
      oSession.createField("TimeAltitudeMin",
                           MyActivity.FITFIELD_GLOBALTIMEALTITUDEMIN,
                           FC.DATA_TYPE_STRING,
                           {:mesgType => FC.MESG_TYPE_SESSION, :count => 9, :units => $.oMySettings.sUnitTime});
    oFitField_GlobalAltitudeMax =
      oSession.createField("AltitudeMax",
                           MyActivity.FITFIELD_GLOBALALTITUDEMAX,
                           FC.DATA_TYPE_FLOAT,
                           {:mesgType => FC.MESG_TYPE_SESSION, :units => $.oMySettings.sUnitElevation});
    oFitField_GlobalTimeAltitudeMax =
      oSession.createField("TimeAltitudeMax",
                           MyActivity.FITFIELD_GLOBALTIMEALTITUDEMAX,
                           FC.DATA_TYPE_STRING,
                           {:mesgType => FC.MESG_TYPE_SESSION, :count => 9, :units => $.oMySettings.sUnitTime});

  }


  //
  // FUNCTIONS: self (session)
  //

  function start() as Void {
    //Sys.println("DEBUG: MyActivity.start()");

    self.resetLog(true);
    self.oSession.start();
    self.oTimeStart = Time.now();
    self.oTimeLap = Time.now();
    self.iCountLaps = 1;
    if(Toybox.Attention has :playTone) {
      Attn.playTone(Attn.TONE_START);
    }
  }

  function isRecording() as Boolean {
    //Sys.println("DEBUG: MyActivity.isRecording()");

    return self.oSession.isRecording();
  }

  function addLap() as Void {
    //Sys.println("DEBUG: MyActivity.lap()");

    self.saveLog(false);
    self.oSession.addLap();
    self.oTimeLap = Time.now();
    self.iCountLaps += 1;
    if(Toybox.Attention has :playTone) {
      Attn.playTone(Attn.TONE_LAP);
    }
    self.resetLapFields();
    self.resetLog(false);
  }

  function pause() as Void {
    //Sys.println("DEBUG: MyActivity.pause()");

    if(!self.oSession.isRecording()) {
      return;
    }
    self.oSession.stop();
    if(Toybox.Attention has :playTone) {
      Attn.playTone(Attn.TONE_STOP);
    }
  }

  function resume() as Void {
    //Sys.println("DEBUG: MyActivity.resume()");

    if(self.oSession.isRecording()) {
      return;
    }
    self.oSession.start();
    if(Toybox.Attention has :playTone) {
      Attn.playTone(Attn.TONE_START);
    }
  }

  function stop(_bSave as Boolean) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.stop($1$)", [_bSave]));

    if(self.oSession.isRecording()) {
      self.oSession.stop();
    }
    if(_bSave) {
      self.oTimeStop = Time.now();
      self.saveLog(true);
      self.oSession.save();
      if(Toybox.Attention has :playTone) {
        Attn.playTone(Attn.TONE_STOP);
      }
    }
    else {
      self.oSession.discard();
      if(Toybox.Attention has :playTone) {
        Attn.playTone(Attn.TONE_RESET);
      }
    }
    self.oTimeStart = null;
    self.oTimeLap = null;
    self.iCountLaps = -1;
    self.oTimeStop = null;
  }


  //
  // FUNCTIONS: self (log)
  //

  function resetLog(_bSession as Boolean) as Void {
    self.iEpochLast = -1;
    self.adPositionRadiansLast = null;
    self.fAltitudeLast = NaN;
    // ... lap
    self.fDistance = 0.0f;
    self.fAscent = 0.0f;
    self.iElapsedAscent = 0;
    self.fAltitudeMin = NaN;
    self.oTimeAltitudeMin = null;
    self.fAltitudeMax = NaN;
    self.oTimeAltitudeMax = null;
    // ... session
    if(_bSession) {
      self.fGlobalDistance = 0.0f;
      self.fGlobalAscent = 0.0f;
      self.iGlobalElapsedAscent = 0;
      self.fGlobalAltitudeMin = NaN;
      self.oGlobalTimeAltitudeMin = null;
      self.fGlobalAltitudeMax = NaN;
      self.oGlobalTimeAltitudeMax = null;
    }
  }

  function processPositionInfo(_oInfo as Pos.Info, _iEpoch as Number, _oTimeNow as Time.Moment) as Void {
    //Sys.println("DEBUG: MyActivity.processPositionInfo()");

    // NOTE: We use Pos.Info.altitude to remain consistent with other (internal) Activity position/altitude data
    if(!self.oSession.isRecording()
       or !(_oInfo has :accuracy) or _oInfo.accuracy < Pos.QUALITY_GOOD
       or !(_oInfo has :position) or _oInfo.position == null
       or !(_oInfo has :altitude) or _oInfo.altitude == null
       or _iEpoch - self.iEpochLast < $.oMySettings.iGeneralTimeConstant) {
      return;
    }

    // Distance (non-thermalling)
    var adPositionRadians = (_oInfo.position as Pos.Location).toRadians();
    if(self.adPositionRadiansLast != null) {
      var fLegLength = LangUtils.distanceEstimate(self.adPositionRadiansLast, adPositionRadians);
      if(fLegLength > 1000.0f) {  // # 1000m = 1km should be bigger than thermalling diameter
        self.adPositionRadiansLast = adPositionRadians;
        // ... lap
        self.fDistance += fLegLength;
        // ... session
        self.fGlobalDistance += fLegLength;
      }
    }
    else {
      self.adPositionRadiansLast = adPositionRadians;
    }

    // Ascent
    if(self.iEpochLast >= 0 and (_oInfo.altitude as Float) > self.fAltitudeLast) {
      // ... lap
      self.fAscent += ((_oInfo.altitude as Float) - self.fAltitudeLast);
      self.iElapsedAscent += (_iEpoch - self.iEpochLast);
      // ... session
      self.fGlobalAscent += ((_oInfo.altitude as Float) - self.fAltitudeLast);
      self.iGlobalElapsedAscent += (_iEpoch - self.iEpochLast);
    }
    self.fAltitudeLast = _oInfo.altitude as Float;

    // Altitude
    // ... lap
    if(!((_oInfo.altitude as Float) >= self.fAltitudeMin)) {  // NB: ... >= NaN is always false
      self.fAltitudeMin = _oInfo.altitude as Float;
      self.oTimeAltitudeMin = _oTimeNow;
    }
    if(!((_oInfo.altitude as Float) <= self.fAltitudeMax)) {  // NB: ... <= NaN is always false
      self.fAltitudeMax = _oInfo.altitude as Float;
      self.oTimeAltitudeMax = _oTimeNow;
    }
    // ... session
    if(!((_oInfo.altitude as Float) >= self.fGlobalAltitudeMin)) {  // NB: ... >= NaN is always false
      self.fGlobalAltitudeMin = _oInfo.altitude as Float;
      self.oGlobalTimeAltitudeMin = _oTimeNow;
    }
    if(!((_oInfo.altitude as Float) <= self.fGlobalAltitudeMax)) {  // NB: ... <= NaN is always false
      self.fGlobalAltitudeMax = _oInfo.altitude as Float;
      self.oGlobalTimeAltitudeMax = _oTimeNow;
    }

    // Epoch
    self.iEpochLast = _iEpoch;
  }

  function saveLog(_bSession as Boolean) as Void {
    // FIT fields
    // ... lap
    self.setDistance(self.fDistance);
    self.setAscent(self.fAscent);
    self.setElapsedAscent(self.iElapsedAscent);
    self.setAltitudeMin(self.fAltitudeMin);
    self.setTimeAltitudeMin(self.oTimeAltitudeMin);
    self.setAltitudeMax(self.fAltitudeMax);
    self.setTimeAltitudeMax(self.oTimeAltitudeMax);
    // ... session
    if(_bSession) {
      self.setGlobalDistance(self.fGlobalDistance);
      self.setGlobalAscent(self.fGlobalAscent);
      self.setGlobalElapsedAscent(self.iGlobalElapsedAscent);
      self.setGlobalAltitudeMin(self.fGlobalAltitudeMin);
      self.setGlobalTimeAltitudeMin(self.oGlobalTimeAltitudeMin);
      self.setGlobalAltitudeMax(self.fGlobalAltitudeMax);
      self.setGlobalTimeAltitudeMax(self.oGlobalTimeAltitudeMax);
    }

    // Log entry
    if(_bSession) {
      var dictLog = {
        "timeStart" => self.oTimeStart != null ? (self.oTimeStart as Time.Moment).value() : null,
        "timeStop" => self.oTimeStop != null ? (self.oTimeStop as Time.Moment).value() : null,
        "distance" => LangUtils.notNaN(self.fGlobalDistance) ? self.fGlobalDistance : null,
        "ascent" => LangUtils.notNaN(self.fGlobalAscent) ? self.fGlobalAscent : null,
        "elapsedAscent" => LangUtils.notNaN(self.iGlobalElapsedAscent) ? self.iGlobalElapsedAscent : null,
        "altitudeMin" => LangUtils.notNaN(self.fGlobalAltitudeMin) ? self.fGlobalAltitudeMin : null,
        "timeAltitudeMin" => self.oGlobalTimeAltitudeMin != null ? (self.oGlobalTimeAltitudeMin as Time.Moment).value() : null,
        "altitudeMax" => LangUtils.notNaN(self.fGlobalAltitudeMax) ? self.fGlobalAltitudeMax : null,
        "timeAltitudeMax" => self.oGlobalTimeAltitudeMax != null ? (self.oGlobalTimeAltitudeMax as Time.Moment).value() : null,
      };
      $.iMyLogIndex = ($.iMyLogIndex + 1) % $.MY_STORAGE_SLOTS;
      var s = $.iMyLogIndex.format("%02d");
      App.Storage.setValue(Lang.format("storLog$1$", [s]), dictLog as App.PropertyValueType);
      App.Storage.setValue("storLogIndex", $.iMyLogIndex as App.PropertyValueType);
    }
  }


  //
  // FUNCTIONS: self (fields)
  //

  // Record

  function setBarometricAltitude(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setBarometricAltitude($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_BarometricAltitude.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setVerticalSpeed(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setVerticalSpeed($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_VerticalSpeed.setData(_fValue * self.fUnitCoefficient_VerticalSpeed);
    }
  }

  function setRateOfTurn(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setRateOfTurn($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_RateOfTurn.setData(_fValue * self.fUnitCoefficient_RateOfTurn);
    }
  }

  function setAcceleration(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setAcceleration($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_Acceleration.setData(_fValue);
    }
  }

  // Lap

  function resetLapFields() as Void {
    self.setDistance(null);
    self.setAscent(null);
    self.setElapsedAscent(null);
    self.setAltitudeMin(null);
    self.setTimeAltitudeMin(null);
    self.setAltitudeMax(null);
    self.setTimeAltitudeMax(null);
  }

  function setDistance(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setDistance($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_Distance.setData(_fValue * self.fUnitCoefficient_Distance);
    }
  }

  function setAscent(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setAscent($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_Ascent.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setElapsedAscent(_iElapsed as Number?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setElapsedAscent($1$)", [_iElapsed]));
    self.oFitField_ElapsedAscent.setData(LangUtils.formatElapsed(_iElapsed, true));
  }

  function setAltitudeMin(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setAltitudeMin($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_AltitudeMin.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setTimeAltitudeMin(_oTime as Time.Moment?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setTimeAltitudeMin($1$)", [_oTime.value()]));
    self.oFitField_TimeAltitudeMin.setData(LangUtils.formatTime(_oTime, self.bUnitCoefficient_TimeUTC, true));
  }

  function setAltitudeMax(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setAltitudeMax($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_AltitudeMax.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setTimeAltitudeMax(_oTime as Time.Moment?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setTimeAltitudeMax($1$)", [_oTime.value()]));
    self.oFitField_TimeAltitudeMax.setData(LangUtils.formatTime(_oTime, self.bUnitCoefficient_TimeUTC, true));
  }

  // Session

  function setGlobalDistance(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalDistance($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_GlobalDistance.setData(_fValue * self.fUnitCoefficient_Distance);
    }
  }

  function setGlobalAscent(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalAscent($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_GlobalAscent.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setGlobalElapsedAscent(_iElapsed as Number?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalElapsedAscent($1$)", [_iElapsed]));
    self.oFitField_GlobalElapsedAscent.setData(LangUtils.formatElapsed(_iElapsed, true));
  }

  function setGlobalAltitudeMin(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalAltitudeMin($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_GlobalAltitudeMin.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setGlobalTimeAltitudeMin(_oTime as Time.Moment?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalTimeAltitudeMin($1$)", [_oTime.value()]));
    self.oFitField_GlobalTimeAltitudeMin.setData(LangUtils.formatTime(_oTime, self.bUnitCoefficient_TimeUTC, true));
  }

  function setGlobalAltitudeMax(_fValue as Float?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalAltitudeMax($1$)", [_fValue]));
    if(_fValue != null and LangUtils.notNaN(_fValue)) {
      self.oFitField_GlobalAltitudeMax.setData(_fValue * self.fUnitCoefficient_Altitude);
    }
  }

  function setGlobalTimeAltitudeMax(_oTime as Time.Moment?) as Void {
    //Sys.println(Lang.format("DEBUG: MyActivity.setGlobalTimeAltitudeMax($1$)", [_oTime.value()]));
    self.oFitField_GlobalTimeAltitudeMax.setData(LangUtils.formatTime(_oTime, self.bUnitCoefficient_TimeUTC, true));
  }

}
