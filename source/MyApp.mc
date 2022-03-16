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
var oMySettings as MySettings = new MySettings() ;

// (Last) position location/altitude
var oMyPositionLocation as Pos.Location?;
var fMyPositionAltitude as Float = NaN;

// Sensors filter
var oMyFilter as MyFilter = new MyFilter();

// Internal altimeter
var oMyAltimeter as MyAltimeter = new MyAltimeter();

// Processing logic
var oMyProcessing as MyProcessing = new MyProcessing();
var oMyTimeStart as Time.Moment = Time.now();

// Log
var iMyLogIndex as Number = -1;

// Activity session (recording)
var oMyActivity as MyActivity?;

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

  // Tones
  private var iTones as Number = 0;
  private var iVibrations as Number =0;


  //
  // FUNCTIONS: App.AppBase (override/implement)
  //

  function initialize() {
    AppBase.initialize();

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
    Pos.enableLocationEvents(Pos.LOCATION_CONTINUOUS, method(:onLocationEvent));

    // Start UI update timer (every multiple of 5 seconds, to save energy)
    // NOTE: in normal circumstances, UI update will be triggered by position events (every ~1 second)
    self.oUpdateTimer = new Timer.Timer();
    var iUpdateTimerDelay = (60-Sys.getClockTime().sec)%5;
    if(iUpdateTimerDelay > 0) {
      (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer_init), 1000*iUpdateTimerDelay, false);
    }
    else {
      (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer), 5000, true);
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

    // Load settings
    $.oMySettings.load();

    // Apply settings
    $.oMyFilter.importSettings();
    $.oMyAltimeter.importSettings();
    $.oMyProcessing.importSettings();

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
      }
    }

    // Process sensor data
    $.oMyProcessing.processSensorInfo(_oInfo, Time.now().value());

    // Save FIT fields
    if($.oMyActivity != null) {
      ($.oMyActivity as MyActivity).setBarometricAltitude($.oMyProcessing.fAltitude);
      if($.oMySettings.iVariometerMode == 0) {
        ($.oMyActivity as MyActivity).setVerticalSpeed($.oMyProcessing.fVariometer);
      }
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

    // Save FIT fields
    if($.oMyActivity != null) {
      if($.oMySettings.iVariometerMode == 1) {
        ($.oMyActivity as MyActivity).setVerticalSpeed($.oMyProcessing.fVariometer);
      }
    }
  }

  function onUpdateTimer_init() as Void {
    //Sys.println("DEBUG: MyApp.onUpdateTimer_init()");
    self.onUpdateTimer();
    self.oUpdateTimer = new Timer.Timer();
    (self.oUpdateTimer as Timer.Timer).start(method(:onUpdateTimer), 5000, true);
  }

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
    if(self.iTones) {
      self.iTonesTick = 1000;
      self.iTonesLastTick = 0;
      self.oTonesTimer = new Timer.Timer();
      self.oTonesTimer.start(method(:onTonesTimer), 100, true);
    }
  }

  function playTones() as Void {
    //Sys.println(format("DEBUG: MyApp.playTones() @ $1$", [self.iTonesTick]));
    // Variometer
    // ALGO: Tones "tick" is 100ms; we work between 200ms (2 ticks) and 2000ms (20 ticks) pediod,
    //       depending on the ratio between the ascent speed and the variometer range.
    if(self.iTones || self.iVibrations) {
      var fValue = $.oMySettings.iGeneralDisplayFilter >= 1 ? $.oMyProcessing.fVariometer_filtered : $.oMyProcessing.fVariometer;
      if(fValue >= $.oMySettings.fMinimumClimb) {
        if(self.iTonesTick-self.iTonesLastTick >= 20.0f-18.0f*fValue/$.oMySettings.fVariometerRange) {
          //Sys.println(format("DEBUG: playTone: variometer @ $1$", [self.iTonesTick]));
          if(self.iTones) {
            Attn.playTone(Attn.TONE_KEY);
          }
          if(self.iVibrations) {
            var vibeData = [new Attn.VibeProfile(100, 75)];
            Attn.vibrate(vibeData);
          }
          self.iTonesLastTick = self.iTonesTick;
          return;
        }
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

}
