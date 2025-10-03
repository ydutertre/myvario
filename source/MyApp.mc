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
using Toybox.Application as App;
using Toybox.Attention as Attn;
using Toybox.Communications as Comm;
using Toybox.Position as Pos;
using Toybox.Sensor;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

//
// GLOBALS
//

// Application settings
var oMySettings as MySettings?;// = new MySettings() ;

// (Last) position location/altitude
var oMyPositionLocation as Pos.Location?;
var fMyPositionAltitude as Float = NaN;

// Sensors filter
var oMyKalmanFilter as MyKalmanFilter?;// = new MyKalmanFilter();

// Internal altimeter
var oMyAltimeter as MyAltimeter?;// = new MyAltimeter();

// Processing logic
var oMyProcessing as MyProcessing?;// = new MyProcessing();
var oMyTimeStart as Time.Moment?;// = Time.now();

// Log
var iMyLogIndex as Number = -1;

// Map
var bMHChange = false;

// Activity session (recording)
var oMyActivity as MyActivity?;

// Livetrack
var oMyLivetrack24 as MyLivetrack24?;// = new MyLivetrack24();
var oMySportsTrackLive as MySportsTrackLive?;// = new MySportsTrackLive();
var oMyFlySafeLivetrack as MyFlySafeLivetrack?;// = new MyFlySafeLivetrack();

//ActiveLook
var oMyActiveLook as MyActiveLook?;// = new MyActiveLook();

//Vector Vario
var oMyVectorVario as MyVectorVario?;

// Current view
var oMyView as MyView?;

//
// CONSTANTS
//

// Storage slots
const MY_STORAGE_SLOTS = 100;

// No-value strings
// NOTE: Those ought to be defined in the MyApp class like other constants but code then fails with an "Invalid Value" error when called upon; BUG?
const MY_NOVALUE_BLANK = "";
const MY_NOVALUE_LEN2 = "--";
const MY_NOVALUE_LEN3 = "---";
const MY_NOVALUE_LEN4 = "----";


//
// CLASS
//

class MyApp extends App.AppBase {

  //
  // CONSTANTS
  //

  // FIT fields (as per resources/fit.xml)
  public const FITFIELD_VERTICALSPEED = 0;
  public const FITFIELD_BAROMETRICALTITUDE = 1;

  //
  // VARIABLES
  //

  // Timers
  // ... UI update
  private var oUpdateTimer as Timer.Timer?;
  private var iUpdateLastEpoch as Number = 0;
  // ... tones
  private var oTonesTimer as Timer.Timer?;
  private var iTonesTick as Number = 1000;
  private var iTonesLastTick as Number = 0;
  private var iTonesSpeakerTick as Number = 0;

  // Tones
  private var iTones as Number = 0;
  private var iVibrations as Number =0;
  private var bSinkToneTriggered as Boolean = false;


  //
  // FUNCTIONS: App.AppBase (override/implement)
  //

  function initialize() {
    AppBase.initialize();
    oMySettings = new MySettings() ;
    oMyKalmanFilter = new MyKalmanFilter();
    oMyAltimeter = new MyAltimeter();
    oMyProcessing = new MyProcessing();
    oMyTimeStart = Time.now();
    oMyLivetrack24 = new MyLivetrack24();
    oMySportsTrackLive = new MySportsTrackLive();
    oMyFlySafeLivetrack = new MyFlySafeLivetrack();
    oMyActiveLook = new MyActiveLook();
    oMyVectorVario = new MyVectorVario();


    // Log
    // ... last entry index
    var iLogIndex = App.Storage.getValue("storLogIndex") as Number?;
    if(iLogIndex != null) {
      $.iMyLogIndex = iLogIndex;
    }
    else {
      // MIGRATION; TODO: Remove after 2022.12.31
      var iLogEpoch = 0;
      for(var n=0; n<$.MY_STORAGE_SLOTS; n++) {
        var s = n.format("%02d");
        var dictLog = App.Storage.getValue(format("storLog$1$", [s])) as Dictionary?;
        if(dictLog == null) {
          break;
        } else {
          var i = dictLog.get("timeStart") as Number?;
          if(i == null) {
            break;
          }
          else if(i > iLogEpoch) {
            $.iMyLogIndex = n;
            iLogEpoch = i;
          }
        }
      }
      if($.iMyLogIndex >= 0) {
        App.Storage.setValue("storLogIndex", $.iMyLogIndex as App.PropertyValueType);
      }
    }

    // Timers
    $.oMyTimeStart = Time.now();
  }

  function onStart(state) {
    //Sys.println("DEBUG: MyApp.onStart()");

    // Load settings
    self.loadSettings();

    // Enable sensor events
    Sensor.setEnabledSensors([] as Array<Sensor.SensorType>);  // ... we need just the acceleration
    Sensor.enableSensorEvents(method(:onSensorEvent));

    // Enable position events
    self.enablePositioning();

    // Start UI update timer (every multiple of 5 seconds, to save energy)
    // NOTE: in normal circumstances, UI update will be triggered by position events (every ~1 second)
    self.oUpdateTimer = new Timer.Timer();
    // var iUpdateTimerDelay = (60-Sys.getClockTime().sec)%5;
    // if(iUpdateTimerDelay > 0) {
    //   (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer_init), 1000*iUpdateTimerDelay, false);
    // }
    // else {
    (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer), 5000, true);
    // }

    //Initialize and search for ActiveLook glasses
    $.oMyActiveLook.init();
    if($.oMySettings.bActiveLook){
      $.oMyActiveLook.findAndPair();
    }

    $.oMyVectorVario.init();
    if($.oMySettings.bVectorVario) {
      $.oMyVectorVario.findAndPair();
    }
  }

  function onStop(state) {
    //Sys.println("DEBUG: MyApp.onStop()");

    // Stop timers
    // ... UI update
    if(self.oUpdateTimer != null) {
      (self.oUpdateTimer as Timer.Timer).stop();
      self.oUpdateTimer = null;
    }
    // ... tones
    if(self.oTonesTimer != null) {
      (self.oTonesTimer as Timer.Timer).stop();
      self.oTonesTimer = null;
    }

    // Disable position events
    Pos.enableLocationEvents(Pos.LOCATION_DISABLE, method(:onLocationEvent));

    // Disable sensor events
    Sensor.enableSensorEvents(null);

    // Disconnect ActiveLook
    if($.oMySettings.bActiveLook){
      $.oMyActiveLook.unPair();
    }
    $.oMyVectorVario.unPair();

  }

  function getInitialView() {
    //Sys.println("DEBUG: MyApp.getInitialView()");

    return [new MyViewGeneral(), new MyViewGeneralDelegate()] as Array<Ui.Views or Ui.InputDelegates>;
  }

  function onSettingsChanged() {
    //Sys.println("DEBUG: MyApp.onSettingsChanged()");
    self.loadSettings();
    self.updateUi(Time.now().value());
  }


  //
  // FUNCTIONS: self
  //

  function loadSettings() as Void {
    //Sys.println("DEBUG: MyApp.loadSettings()");

    //... Intialize and reset livetrack

    //Livetrack24
    var sLivetrack24UserName = LangUtils.readKeyString(App.Properties.getValue("userLivetrack24UserName"), "");
    var sLivetrack24Password = LangUtils.readKeyString(App.Properties.getValue("userLivetrack24Password"), "");
    var sLivetrack24Equipment = LangUtils.readKeyString(App.Properties.getValue("userLivetrack24EquipmentName"), "");
    if(!sLivetrack24UserName.equals($.oMyLivetrack24.sLoginName) || !sLivetrack24Password.equals($.oMyLivetrack24.sPassword) || !sLivetrack24Equipment.equals($.oMyLivetrack24.sEquipment)) {
      $.oMyLivetrack24.init(sLivetrack24UserName, sLivetrack24Password, sLivetrack24Equipment);
      $.oMyLivetrack24.reset();
    }

    //SportsTrackLive

    var sSportsTrackLiveEmail = LangUtils.readKeyString(App.Properties.getValue("userSportsTrackLiveEmail"), "");
    var sSportsTrackLivePassword = LangUtils.readKeyString(App.Properties.getValue("userSportsTrackLivePassword"), "");
    if(!sSportsTrackLiveEmail.equals($.oMySportsTrackLive.sLoginEmail) || !sSportsTrackLivePassword.equals($.oMySportsTrackLive.sPassword)) {
      $.oMySportsTrackLive.init(sSportsTrackLiveEmail, sSportsTrackLivePassword);
      $.oMySportsTrackLive.reset();
    }

    //FlySafeLivetrack
    var sFlySafeUserId = LangUtils.readKeyString(App.Properties.getValue("userFlySafeUserId"), "");
    var sFlySafeToken = LangUtils.readKeyString(App.Properties.getValue("userFlySafeToken"), "");
    $.oMyFlySafeLivetrack.init(sFlySafeUserId, sFlySafeToken);

    // Load settings
    $.oMySettings.load();

    // Apply settings

    $.oMyAltimeter.importSettings();
    //self.enablePositioning();

    // ... tones
    self.muteTones();
  }

  function onSensorEvent(_oInfo as Sensor.Info) as Void {
    //Sys.println("DEBUG: MyApp.onSensorEvent());

    // Process altimeter data
    var oActivityInfo = Activity.getActivityInfo();  // ... we need *raw ambient* pressure
    if(oActivityInfo != null) {
      if(oActivityInfo has :rawAmbientPressure and oActivityInfo.rawAmbientPressure != null) {
        $.oMyAltimeter.setQFE(oActivityInfo.rawAmbientPressure as Float);
        
        //Initial automated calibration based on watch altitude
        if($.oMyAltimeter.bFirstRun && _oInfo has :altitude && _oInfo.altitude != null) {
          $.oMyAltimeter.bFirstRun = false;
          $.oMyAltimeter.setAltitudeActual(_oInfo.altitude);
          $.oMySettings.saveAltimeterCalibrationQNH($.oMyAltimeter.fQNH);
        }
      }
    }

    // Process sensor data
    $.oMyProcessing.processSensorInfo(_oInfo, Time.now().value());

    // Save FIT fields
    if($.oMyActivity != null) {
      ($.oMyActivity as MyActivity).setBarometricAltitude($.oMyProcessing.fAltitude);
      ($.oMyActivity as MyActivity).setVerticalSpeed($.oMyProcessing.fVariometer);
    }
  }

  function onLocationEvent(_oInfo as Pos.Info) as Void {
    //Sys.println("DEBUG: MyApp.onLocationEvent()");
    var oTimeNow = Time.now();
    var iEpoch = oTimeNow.value();

    // Save location
    if(_oInfo has :position) {
      $.oMyPositionLocation = _oInfo.position;
    }

    // Save altitude
    if(_oInfo has :altitude and _oInfo.altitude != null) {
      $.fMyPositionAltitude = _oInfo.altitude as Float;
    }

    // Process position data
    $.oMyProcessing.processPositionInfo(_oInfo, iEpoch);
    if($.oMyActivity != null) {
      ($.oMyActivity as MyActivity).processPositionInfo(_oInfo, iEpoch, oTimeNow);
    }

    // Automatic Activity recording
    if($.oMySettings.bActivityAutoStart and LangUtils.notNaN($.oMyProcessing.fGroundSpeed)) {
      if($.oMyActivity == null) {
        if($.oMySettings.fActivityAutoSpeedStart > 0.0f
           and $.oMyProcessing.fGroundSpeed > $.oMySettings.fActivityAutoSpeedStart) {
          $.oMyActivity = new MyActivity();
          ($.oMyActivity as MyActivity).start();
        }
      }
    }

    // UI update
    self.updateUi(iEpoch);
  }

  // function onUpdateTimer_init() as Void {
  //   //Sys.println("DEBUG: MyApp.onUpdateTimer_init()");
  //   self.onUpdateTimer();
  //   self.oUpdateTimer = new Timer.Timer();
  //   (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer), 5000, true);
  // }

  function onUpdateTimer() as Void {
    //Sys.println("DEBUG: MyApp.onUpdateTimer()");
    var iEpoch = Time.now().value();
    if(iEpoch-self.iUpdateLastEpoch > 1) {
      self.updateUi(iEpoch);
    }
  }

  function onTonesTimer() as Void {
    //Sys.println("DEBUG: MyApp.onTonesTimer()");
    self.playTones();
    self.iTonesTick++;
  }

  function updateUi(_iEpoch as Number) as Void {
    //Sys.println("DEBUG: MyApp.updateUi()");

    // Check sensor data age
    if($.oMyProcessing.iSensorEpoch >= 0 and _iEpoch-$.oMyProcessing.iSensorEpoch > 10) {
      $.oMyProcessing.resetSensorData();
      $.oMyAltimeter.reset();
    }

    // Check position data age
    if($.oMyProcessing.iPositionEpoch >= 0 and _iEpoch-$.oMyProcessing.iPositionEpoch > 10) {
      $.oMyProcessing.resetPositionData();
    }

    // Update UI
    if($.oMyView != null) {
      ($.oMyView as MyView).updateUi();
      self.iUpdateLastEpoch = _iEpoch;
    }
  }

  function muteTones() as Void {
    // Stop tones timers
    if(self.oTonesTimer != null) {
      (self.oTonesTimer as Timer.Timer).stop();
      self.oTonesTimer = null;
    }
  }

  function unmuteTones() as Void {
    // Enable tones
    self.iTones = 0;
    if(Toybox.Attention has :playTone) {
      if($.oMySettings.bSoundsVariometerTones) {
        self.iTones = 1;
      }
    }

    if(Toybox.Attention has :vibrate) {
      if($.oMySettings.bVariometerVibrations) {
        self.iVibrations = 1;
      }
    }

    // Start tones timer
    // NOTE: For variometer tones, we need a 10Hz <-> 100ms resolution;
    if(self.iTones || self.iVibrations) {
      self.iTonesTick = 1000;
      self.iTonesLastTick = 0;
      self.oTonesTimer = new Timer.Timer();
      self.oTonesTimer.start(method(:onTonesTimer), 100, true);
    }
  }

  function playTones() as Void {
    //Sys.println(format("DEBUG: MyApp.playTones() @ $1$", [self.iTonesTick]));
    // Variometer
    // ALGO: Tones "tick" is 100ms; I try to do a curve that is similar to the Skybean vario
    // Medium curve in terms of tone length, pause, and one frequency.
    // Tones need to be more frequent than in GliderSK even at low climb rates to be able to
    // properly map thermals (especially broken up thermals)
    if(self.iTones || self.iVibrations) {
      var fValue = $.oMyProcessing.fVariometer_filtered;
      var bSpeaker = $.oMySettings.iSoundsToneDriver == 1;
      var iDeltaTick = (self.iTonesTick-self.iTonesLastTick) > 8 ? 8 : self.iTonesTick-self.iTonesLastTick;
      var bVarioDoTick = iDeltaTick >= 8.0f - fValue;
      if(fValue >= $.oMySettings.fMinimumClimb) {
        //Sys.println(format("DEBUG: playTone: variometer @ $1$", [self.iTonesTick]));
        var iToneLength = (iDeltaTick > 2) ? iDeltaTick * 50 - 100: 50;
        if(self.iTones) {
          if (!bSpeaker) { // Buzzer
            if (bVarioDoTick) {
              var iToneFrequency = (400 + fValue * 100) > 1100 ? 1100 : (400 + fValue * 100).toNumber();
              var toneProfile = [new Attn.ToneProfile(iToneFrequency, iToneLength)]; //contrary to Garmin API Doc, first parameter seems to be frequency, and second length
              Attn.playTone({:toneProfile=>toneProfile});
            }
          } else { // Speaker
            if (fValue > 3.0f) { fValue = 3.0f; }
            var iNextSound = 50 + (1.0f - (fValue / 3.0f)) * 1000;
            var iToneTick = Sys.getTimer();
            if (iToneTick - iNextSound  > self.iTonesSpeakerTick) {
              var iTone = fValue >= 2.9f ? Attn.TONE_MSG : Attn.TONE_LOUD_BEEP;
              Attn.playTone(iTone);
              self.iTonesSpeakerTick = iToneTick;
            }
          }
        }
        if(self.iVibrations && bVarioDoTick) {
          var vibeData = [new Attn.VibeProfile(100, (iToneLength > 200) ? iToneLength / 2 : 50)]; //Keeping vibration length shorter than tone for battery and wrist!
          Attn.vibrate(vibeData);
        }
        if (bVarioDoTick) {
          self.iTonesLastTick = self.iTonesTick;
        }
        return;
      }
      else if(fValue <= $.oMySettings.fMinimumSink && !self.bSinkToneTriggered && self.iTones) {
        if (!bSpeaker) { // Buzzer
          var toneProfile = [new Attn.ToneProfile(220, 2000)];
          Attn.playTone({:toneProfile=>toneProfile});
          self.bSinkToneTriggered = true;
        } else { // Speaker
          Attn.playTone(Attn.TONE_CANARY);
        }
      }
      //Reset minimum sink tone if we get significantly above it
      if(fValue >= $.oMySettings.fMinimumSink + 1.0f && self.bSinkToneTriggered) {
        self.bSinkToneTriggered = false;
      }
    }
  }

  function clearStorageLogs() as Void {
    //Sys.println("DEBUG: MyApp.clearStorageLogs()");
    for(var n=0; n<$.MY_STORAGE_SLOTS; n++) {
      var s = n.format("%02d");
      App.Storage.deleteValue(format("storLog$1$", [s]));
    }
    App.Storage.deleteValue("storLogIndex");
    $.iMyLogIndex = -1;
  }

  function enablePositioning() as Void {
    var options = {
        :acquisitionType => Pos.LOCATION_CONTINUOUS
    };

    if (Pos has :POSITIONING_MODE_AVIATION) {
        options[:mode] = Pos.POSITIONING_MODE_AVIATION;
    }

    if (Pos has :hasConfigurationSupport) {
        if ((Pos has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5) && (Pos.hasConfigurationSupport(Pos.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5)) && ($.oMySettings.iGPS == 0)) {
            options[:configuration] = Pos.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5;
        } else if ((Pos has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1) && (Pos.hasConfigurationSupport(Pos.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1)) && ($.oMySettings.iGPS == 0)) {
            options[:configuration] = Pos.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1;
        } else if ((Pos has :CONFIGURATION_GPS) && (Pos.hasConfigurationSupport(Pos.CONFIGURATION_GPS))) {
            options[:configuration] = Pos.CONFIGURATION_GPS;
        }
    } else {
        options = Pos.LOCATION_CONTINUOUS;
    }

    // Continuous location updates using selected options
    Pos.enableLocationEvents(options, method(:onLocationEvent));
  }

  function calculateScaleBar(iMaxBarSize as Lang.Number, fPlotScale as Lang.Float, sUnit as Lang.String, fUnitCoefficient as Lang.Float) as Void {
    var iMinBarSize = 10;
    var fMinBarScale = iMinBarSize * fUnitCoefficient * fPlotScale;
    var fMaxBarScale = iMaxBarSize * fUnitCoefficient * fPlotScale;

    var aiSizeSnap = [10, 5, 2, 1];

    // Try to find a nice size
    for (var i = 0; i < aiSizeSnap.size(); i++) {
      var iSize = aiSizeSnap[i];
      var iSizeSnap = (fMaxBarScale / iSize).toNumber() * iSize;
      if (iSizeSnap >= fMinBarScale && iSizeSnap <= fMaxBarScale) {
        var iBarSize = iMaxBarSize * iSizeSnap / fMaxBarScale;
        // return [iBarSize.toNumber(), iSizeSnap + sUnit];
        $.iScaleBarSize = iBarSize.toNumber();
        $.sScaleBarUnit = iSizeSnap + sUnit;
        return;
      }
    }

    // Failed, try smaller unit
    if ($.oMySettings.sUnitDistance.equals("nm") || $.oMySettings.sUnitDistance.equals("sm")) {
      sUnit = "ft";
      fUnitCoefficient = 3.280839895f;
    } else if ($.oMySettings.sUnitDistance.equals("km")) {
      sUnit = "m";
      fUnitCoefficient = 1.0f;
    } else {
      // "Unreachable" Unknown unit...
      // return [0, "ERR"];
      $.iScaleBarSize = 0;
      $.sScaleBarUnit = "ERR";
      return;
    }

    aiSizeSnap = [1000, 500, 200, 100, 50, 10];
    fMinBarScale = iMinBarSize * fUnitCoefficient * fPlotScale;
    fMaxBarScale = iMaxBarSize * fUnitCoefficient * fPlotScale;

    // Try to find a nice size with the smaller unit
    for (var i = 0; i < aiSizeSnap.size(); i++) {
      var iSize = aiSizeSnap[i];
      var iSizeSnap = (fMaxBarScale / iSize).toNumber() * iSize;
      if (iSizeSnap >= fMinBarScale && iSizeSnap <= fMaxBarScale) {
        var iBarSize = iMaxBarSize * iSizeSnap / fMaxBarScale;
        // return [iBarSize.toNumber(), iSizeSnap + sUnit];
        $.iScaleBarSize = iBarSize.toNumber();
        $.sScaleBarUnit = iSizeSnap + sUnit;
        return;
      }
    }

    // Failed again, do not try snapping
    // return [iMaxBarSize, fMaxBarScale.format("%.0f") + sUnit];
    $.iScaleBarSize = iMaxBarSize;
    $.sScaleBarUnit = fMaxBarScale.format("%.0f") + sUnit;
  }
}
