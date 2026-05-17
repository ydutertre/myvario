// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (c) 2025 Yannick Dutertre <https://yannickd9.wixsite.com/myvario>
// Amended using code from fork "GlideApp" by Pablo Castro
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
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MySettings {

  //
  // VARIABLES
  //

  // Settings
  // ... altimeter
  public var fAltimeterCalibrationQNH as Float = 101325.0f;
  // ... variometer
  public var iVariometerRange as Number = 0;
  public var bVariometerAutoThermal as Boolean = true;
  public var bVariometerThermalDetect as Boolean = true;
  public var iVariometerSmoothing as Number = 1;
  public var iVariometerPlotRange as Number = 2;
  public var iVariometerPlotZoom as Number = 9;
  public var iMapViewZoom as Number = 8;
  // ... sounds
  public var bSoundsVariometerTones as Boolean = true;
  public var bVariometerVibrations as Boolean = true;
  public var iSoundsToneDriver as Number = 0; // 0: buzzer, 1: speaker
  public var iMinimumClimb as Number = 2; // Default value of 0.2m/s climb threshold before sounds and vibrations are triggered
  public var iMinimumSink as Number = 1;
  // ... activity
  public var bActivityAutoStart as Boolean = true; //Auto-start recording after launch
  public var fActivityAutoSpeedStart as Float = 3.0f;
  public var iActivityType as Number = 2; // Activity type 0 flight, 1 hike, 2 hg, 3 kitesurfing
  // ... general
  public var iGeneralBackgroundColor as Number = Gfx.COLOR_WHITE;
  public var bActiveLook as Boolean = false;
  public var bVectorVario as Boolean = false;
  public var iGPS as Number = 0; // 0: full, 1: GPS
  public var bMapDisplay as Boolean = false;
  public var bCompetitionMode as Boolean = false;
  public var sCompetitionTaskDefinition as String = "";
  public var sCompetitionTaskUrl as String = "";
  public var sCompetitionTaskCode as String = "";
  public var sCompetitionTaskSource as String = "";
  // ... units
  public var iUnitDistance as Number = -1;
  public var iUnitElevation as Number = -1;
  public var iUnitPressure as Number = -1;
  public var iUnitDirection as Number = 1;
  public var iUnitWindSpeed as Number = -1;
  public var bUnitTimeUTC as Boolean = false;
  // ... livetrack
  public var iLivetrack24Frequency = 0;
  public var iSportsTrackLiveFrequency = 0;
  public var iFlySafeLivetrackFrequency = 0;

  // Units
  // ... symbols
  public var sUnitDistance as String = "km";
  public var sUnitHorizontalSpeed as String = "km/h";
  public var sUnitElevation as String = "m";
  public var sUnitVerticalSpeed as String = "m/s";
  public var sUnitPressure as String = "mb";
  public var sUnitDirection as String = "txt";
  public var sUnitWindSpeed as String = "km/h";
  public var sUnitTime as String = "LT";
  // ... conversion coefficients
  public var fUnitDistanceCoefficient as Float = 0.001f;
  public var fUnitHorizontalSpeedCoefficient as Float = 3.6f;
  public var fUnitElevationCoefficient as Float = 1.0f;
  public var fUnitVerticalSpeedCoefficient as Float = 1.0f;
  public var fUnitPressureCoefficient as Float = 0.01f;
  public var fUnitWindSpeedCoefficient as Float = 3.6f;

  // General view page customization
  public const GENERAL_VIEW_PAGE_COUNT as Number = 7;
  public const GENERAL_VIEW_PAGE_SLOT_UNUSED as Number = -1;
  public const GENERAL_VIEW_PAGE_LAYOUT_2 as Number = 2;
  public const GENERAL_VIEW_PAGE_LAYOUT_4 as Number = 4;
  public const GENERAL_VIEW_PAGE_LAYOUT_7 as Number = 7;
  public const GENERAL_VIEW_INDICATOR_COUNT as Number = 23;
  public var iGeneralViewActivePageIndex as Number = 0;
  public var iGeneralViewEditingPageIndex as Number = -1;
  public var aGeneralViewPageNames as Array = [];
  public var aGeneralViewPageLayouts as Array = [];
  public var aaGeneralViewPageFields as Array = [];

  // Other
  public var fVariometerRange as Float = 3.0f;
  public var iVariometerPlotOrientation as Number = 0;
  public var fVariometerPlotZoom as Float = 0.0308666666667f;
  public var fMapViewZoom as Float = 0.0f;
  public var fVariometerPlotScale as Float = 1.0f;
  public var fMapViewScale as Float = 1.0f;
  public var fMinimumClimb as Float = 0.2;
  public var fMinimumSink as Float = 2.0;
  public var fVariometerSmoothing as Float = 0.5; //Standard deviation of altitude measurement at fixed altitude
  public var iLivetrack24FrequencySeconds as Number = 0;
  public var iSportsTrackLiveFrequencySeconds as Number = 0;
  public var iFlySafeLivetrackFrequencySeconds as Number = 0;
  public var sVariometerSmoothingName as String = "";
  public var sActivityType as String ="";

  //
  // FUNCTIONS: self
  //

  function load() as Void {
    // Settings
    // ... altimeter
    self.setAltimeterCalibrationQNH(self.loadAltimeterCalibrationQNH());
    // ... variometer
    self.setVariometerRange(self.loadVariometerRange());
    self.setVariometerPlotOrientation(self.loadVariometerPlotOrientation());
    self.setVariometerAutoThermal(self.loadVariometerAutoThermal());
    self.setVariometerThermalDetect(self.loadVariometerThermalDetect());
    self.setVariometerSmoothing(self.loadVariometerSmoothing());
    self.setVariometerPlotRange(self.loadVariometerPlotRange());
    self.setVariometerPlotZoom(self.loadVariometerPlotZoom());
    self.setMapViewZoom(self.loadMapViewZoom());
    // ... sounds and vibration
    self.setSoundsVariometerTones(self.loadSoundsVariometerTones());
    self.setVariometerVibrations(self.loadVariometerVibrations());
    self.setSoundsToneDriver(self.loadSoundsToneDriver());
    self.setMinimumClimb(self.loadMinimumClimb());
    self.setMinimumSink(self.loadMinimumSink());
    // ... activity
    self.setActivityAutoStart(self.loadActivityAutoStart());
    self.setActivityAutoSpeedStart(self.loadActivityAutoSpeedStart());
    self.setActivityType(self.loadActivityType());
    // ... general
    self.setGeneralBackgroundColor(self.loadGeneralBackgroundColor());
    self.setActiveLook(self.loadActiveLook());
    self.setVectorVario(self.loadVectorVario());
    self.setGPS(self.loadGPS());
    self.setMapDisplay(self.loadMapDisplay());
    self.setCompetitionMode(self.loadCompetitionMode());
    self.setCompetitionTaskDefinition(self.loadCompetitionTaskDefinition());
    self.setCompetitionTaskUrl(self.loadCompetitionTaskUrl());
    self.setCompetitionTaskCode(self.loadCompetitionTaskCode());
    self.setCompetitionTaskSource(self.resolveCompetitionTaskSource());
    self.loadGeneralViewPages();
    // ... units
    self.setUnitDistance(self.loadUnitDistance());
    self.setUnitElevation(self.loadUnitElevation());
    self.setUnitPressure(self.loadUnitPressure());
    self.setUnitDirection(self.loadUnitDirection());
    self.setUnitWindSpeed(self.loadUnitWindSpeed());
    self.setUnitTimeUTC(self.loadUnitTimeUTC());
    // ... livetrack
    self.setLivetrack24Frequency(self.loadLivetrack24Frequency());
    self.setSportsTrackLiveFrequency(self.loadSportsTrackLiveFrequency());
    self.setFlySafeLivetrackFrequency(self.loadFlySafeLivetrackFrequency());
  }

  function loadAltimeterCalibrationQNH() as Float {  // [Pa]
    try {
      return LangUtils.readKeyFloat(App.Storage.getValue("userAltimeterCalibrationQNH"), 101325.0f);
    } catch (e) {
      try {
        return LangUtils.readKeyFloat(App.Properties.getValue("userAltimeterCalibrationQNH"), 101325.0f);
      } catch (e2) {
        return 101325.0f;
      }
    }
  }
  function saveAltimeterCalibrationQNH(_fValue as Float) as Void {  // [Pa]
    App.Storage.setValue("userAltimeterCalibrationQNH", _fValue as App.PropertyValueType);
  }
  function setAltimeterCalibrationQNH(_fValue as Float) as Void {  // [Pa]
    // REF: https://en.wikipedia.org/wiki/Atmospheric_pressure#Records
    if(_fValue > 110000.0f) {
      _fValue = 110000.0f;
    }
    else if(_fValue < 85000.0f) {
      _fValue = 85000.0f;
    }
    self.fAltimeterCalibrationQNH = _fValue;
  }


  function loadVariometerRange() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userVariometerRange"), 0);
  }
  function saveVariometerRange(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerRange", _iValue as App.PropertyValueType);
  }
  function setVariometerRange(_iValue as Number) as Void {
    if(_iValue > 2) {
      _iValue = 2;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerRange = _iValue;
    switch(self.iVariometerRange) {
    case 0: self.fVariometerRange = 3.0f; break;
    case 1: self.fVariometerRange = 6.0f; break;
    case 2: self.fVariometerRange = 9.0f; break;
    }
  }

  function loadVariometerPlotOrientation () as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userVariometerPlotOrientation"), 0);
  }
  function saveVariometerPlotOrientation (_iValue as Number) as Void {
    App.Properties.setValue("userVariometerPlotOrientation", _iValue as App.PropertyValueType);
  }
  function setVariometerPlotOrientation (_iValue as Number) as Void {
    if(_iValue > 1) {
      _iValue = 1;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerPlotOrientation = _iValue;
  }

  function loadVariometerPlotRange() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userVariometerPlotRange"), 1);
  }
  function saveVariometerPlotRange(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerPlotRange", _iValue as App.PropertyValueType);
  }
  function setVariometerPlotRange(_iValue as Number) as Void {
    if(_iValue > 3) {
      _iValue = 3;
    }
    else if(_iValue < 1) {
      _iValue = 1;
    }
    self.iVariometerPlotRange = _iValue;
  }

  function loadVariometerAutoThermal() as Boolean {
    return LangUtils.readKeyBoolean(App.Properties.getValue("userVariometerAutoThermal"), true);
  }
  function saveVariometerAutoThermal(_bValue as Boolean) as Void {
    App.Properties.setValue("userVariometerAutoThermal", _bValue as App.PropertyValueType);
  }
  function setVariometerAutoThermal(_bValue as Boolean) as Void {
    self.bVariometerAutoThermal = _bValue;
  }

  function loadVariometerThermalDetect() as Boolean {
    return LangUtils.readKeyBoolean(App.Properties.getValue("userVariometerThermalDetect"), true);
  }
  function saveVariometerThermalDetect(_bValue as Boolean) as Void {
    App.Properties.setValue("userVariometerThermalDetect", _bValue as App.PropertyValueType);
  }
  function setVariometerThermalDetect(_bValue as Boolean) as Void {
    self.bVariometerThermalDetect = _bValue;
  }

  function loadVariometerSmoothing() as Number { 
    return LangUtils.readKeyNumber(App.Properties.getValue("userVariometerSmoothing"), 1);
  }
  function saveVariometerSmoothing(_iValue as Number) as Void { 
    App.Properties.setValue("userVariometerSmoothing", _iValue as App.PropertyValueType);
  }
  function setVariometerSmoothing(_iValue as Number) as Void {
    if(_iValue > 3) {
      _iValue = 3;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerSmoothing = _iValue;
    switch(self.iVariometerSmoothing) {
    case 0: self.fVariometerSmoothing = 0.2f; self.sVariometerSmoothingName = Ui.loadResource(Rez.Strings.valueVariometerSmoothingLow); break;
    case 1: self.fVariometerSmoothing = 0.5f; self.sVariometerSmoothingName = Ui.loadResource(Rez.Strings.valueVariometerSmoothingMedium); break;
    case 2: self.fVariometerSmoothing = 0.7f; self.sVariometerSmoothingName = Ui.loadResource(Rez.Strings.valueVariometerSmoothingHigh); break;
    case 3: self.fVariometerSmoothing = 1.0f; self.sVariometerSmoothingName = Ui.loadResource(Rez.Strings.valueVariometerSmoothingUltra); break;
    }
  }

  function loadVariometerPlotZoom() as Number {
    try {
      return LangUtils.readKeyNumber(App.Storage.getValue("userVariometerPlotZoom"), 9);
    } catch (e) {
      try {
        return LangUtils.readKeyNumber(App.Properties.getValue("userVariometerPlotZoom"), 9);
      } catch (e2) {
        return 9;
      }
    }
  }
  function saveVariometerPlotZoom(_iValue as Number) as Void {
    App.Storage.setValue("userVariometerPlotZoom", _iValue as App.PropertyValueType);
  }
  function setVariometerPlotZoom(_iValue as Number) as Void {
    if(_iValue > 11) {
      _iValue = 11;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iVariometerPlotZoom = _iValue;
    switch(self.iVariometerPlotZoom) {
    case 0: self.fVariometerPlotZoom = 0.0000308666667f; self.fVariometerPlotScale = 1000.0f; break;  // 1000m/px
    case 1: self.fVariometerPlotZoom = 0.0000617333333f; self.fVariometerPlotScale = 500.0f; break;  // 500m/px
    case 2: self.fVariometerPlotZoom = 0.0001543333333f; self.fVariometerPlotScale = 200.0f; break;  // 200m/px
    case 3: self.fVariometerPlotZoom = 0.0003086666667f; self.fVariometerPlotScale = 100.0f; break;  // 100m/px
    case 4: self.fVariometerPlotZoom = 0.0006173333333f; self.fVariometerPlotScale = 50.0f; break;  // 50m/px
    case 5: self.fVariometerPlotZoom = 0.0015433333333f; self.fVariometerPlotScale = 20.0f; break;  // 20m/px
    case 6: self.fVariometerPlotZoom = 0.0030866666667f; self.fVariometerPlotScale = 10.0f; break;  // 10m/px
    case 7: self.fVariometerPlotZoom = 0.0061733333333f; self.fVariometerPlotScale = 5.0f; break;  // 5m/px
    case 8: self.fVariometerPlotZoom = 0.0154333333333f; self.fVariometerPlotScale = 2.0f; break;  // 2m/px
    case 9: self.fVariometerPlotZoom = 0.0308666666667f; self.fVariometerPlotScale = 1.0f; break;  // 1m/px
    case 10: self.fVariometerPlotZoom = 0.0617333333334f; self.fVariometerPlotScale = 0.5f; break;  // 0.5m/px
    case 11: self.fVariometerPlotZoom = 0.1234666666668f; self.fVariometerPlotScale = 0.25f; break;  // 0.25m/px
    }
  }

  function loadMapViewZoom() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userMapViewZoom"), 9);
  }
  function saveMapViewZoom(_iValue as Number) as Void {
    App.Properties.setValue("userMapViewZoom", _iValue as App.PropertyValueType);
  }
  function setMapViewZoom(_iValue as Number) as Void {
    if(_iValue > 9) {
      _iValue = 9;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iMapViewZoom = _iValue;
    switch(self.iMapViewZoom) {
    case 0: self.fMapViewZoom = 0.00899321605f; self.fMapViewScale = 1000.0f; break;  // 1000m/px
    case 1: self.fMapViewZoom = 0.00449660802f; self.fMapViewScale = 500.0f; break;  // 500m/px
    case 2: self.fMapViewZoom = 0.00179864321f; self.fMapViewScale = 200.0f; break;  // 200m/px
    case 3: self.fMapViewZoom = 0.0008993216f; self.fMapViewScale = 100.0f; break;  // 100m/px
    case 4: self.fMapViewZoom = 0.0004496608f; self.fMapViewScale = 50.0f; break;  // 50m/px
    case 5: self.fMapViewZoom = 0.00017986432f; self.fMapViewScale = 20.0f; break;  // 20m/px
    case 6: self.fMapViewZoom = 0.00008993216f; self.fMapViewScale = 10.0f; break;  // 10m/px
    case 7: self.fMapViewZoom = 0.00004496608f; self.fMapViewScale = 5.0f; break;  // 5m/px
    case 8: self.fMapViewZoom = 0.00001798643f; self.fMapViewScale = 2.0f; break;  // 2m/px
    case 9: self.fMapViewZoom = 0.00000899321f; self.fMapViewScale = 1.0f; break;  // 1m/px
    }
  }

  function loadSoundsVariometerTones() as Boolean {
    return LangUtils.readKeyBoolean(App.Properties.getValue("userSoundsVariometerTones"), true);
  }
  function saveSoundsVariometerTones(_bValue as Boolean) as Void {
    App.Properties.setValue("userSoundsVariometerTones", _bValue as App.PropertyValueType);
  }
  function setSoundsVariometerTones(_bValue as Boolean) as Void {
    self.bSoundsVariometerTones = _bValue;
  }

  function loadVariometerVibrations() as Boolean {
    return LangUtils.readKeyBoolean(App.Properties.getValue("userVariometerVibrations"), true);
  }
  function saveVariometerVibrations(_bValue as Boolean) as Void {
    App.Properties.setValue("userVariometerVibrations", _bValue as App.PropertyValueType);
  }
  function setVariometerVibrations(_bValue as Boolean) as Void {
    self.bVariometerVibrations = _bValue;
  }

  function loadSoundsToneDriver() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userSoundsToneDriver"), 0);
  }
  function saveSoundsToneDriver(_iValue as Number) as Void {
    App.Properties.setValue("userSoundsToneDriver", _iValue as App.PropertyValueType);
  }
  function setSoundsToneDriver(_iValue as Number) as Void {
    if(_iValue > 1) {
      _iValue = 1;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iSoundsToneDriver = _iValue;
  }

  function loadMinimumClimb() as Number { 
    return LangUtils.readKeyNumber(App.Properties.getValue("userMinimumClimb"), 2);
  }
  function saveMinimumClimb(_iValue as Number) as Void {  // [m/s]
    App.Properties.setValue("userMinimumClimb", _iValue as App.PropertyValueType);
  }
  function setMinimumClimb(_iValue as Number) as Void {
    if(_iValue > 5) {
      _iValue = 5;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iMinimumClimb = _iValue;
    switch(self.iMinimumClimb) {
    case 0: self.fMinimumClimb = 0.0f; break;
    case 1: self.fMinimumClimb = 0.1f; break;
    case 2: self.fMinimumClimb = 0.2f; break;
    case 3: self.fMinimumClimb = 0.3f; break;
    case 4: self.fMinimumClimb = 0.4f; break;
    case 5: self.fMinimumClimb = 0.5f; break;
    }
  }

  function loadMinimumSink() as Number { 
    return LangUtils.readKeyNumber(App.Properties.getValue("userMinimumSink"), 1);
  }
  function saveMinimumSink(_iValue as Number) as Void {  // [m/s]
    App.Properties.setValue("userMinimumSink", _iValue as App.PropertyValueType);
  }
  function setMinimumSink(_iValue as Number) as Void {
    if(_iValue > 5) {
      _iValue = 5;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iMinimumSink = _iValue;
    switch(self.iMinimumSink) {
    case 0: self.fMinimumSink = -1.0f; break;
    case 1: self.fMinimumSink = -2.0f; break;
    case 2: self.fMinimumSink = -3.0f; break;
    case 3: self.fMinimumSink = -4.0f; break;
    case 4: self.fMinimumSink = -6.0f; break;
    case 5: self.fMinimumSink = -10.0f; break;
    }
  }

  function loadActivityAutoStart() as Boolean {
    return LangUtils.readKeyBoolean(App.Properties.getValue("userActivityAutoStart"), true);
  }
  function saveActivityAutoStart(_bValue as Boolean) as Void {
    App.Properties.setValue("userActivityAutoStart", _bValue as App.PropertyValueType);
  }
  function setActivityAutoStart(_bValue as Boolean) as Void {
    self.bActivityAutoStart = _bValue;
  }

  function loadActivityAutoSpeedStart() as Float {  // [m/s]
    return LangUtils.readKeyFloat(App.Properties.getValue("userActivityAutoSpeedStart"), 3.0f);
  }
  function saveActivityAutoSpeedStart(_fValue as Float) as Void {  // [m/s]
    App.Properties.setValue("userActivityAutoSpeedStart", _fValue as App.PropertyValueType);
  }
  function setActivityAutoSpeedStart(_fValue as Float) as Void {  // [m/s]
    if(_fValue > 99.9f) {
      _fValue = 99.9f;
    }
    else if(_fValue < 0.0f) {
      _fValue = 0.0f;
    }
    self.fActivityAutoSpeedStart = _fValue;
  }

  function loadActivityType() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userActivityType"), 2);
  }
  function saveActivityType(_iValue as Number) as Void {
    App.Properties.setValue("userActivityType", _iValue as App.PropertyValueType);
  }
  function setActivityType(_iValue as Number) as Void {
    self.iActivityType = _iValue;
    switch(self.iActivityType) {
      case 0: self.sActivityType = Ui.loadResource(Rez.Strings.valueActivityTypeFlight); break;
      case 1: self.sActivityType = Ui.loadResource(Rez.Strings.valueActivityTypeHike); break;
      case 2: self.sActivityType = Ui.loadResource(Rez.Strings.valueActivityTypeHG); break;
      case 3: self.sActivityType = Ui.loadResource(Rez.Strings.valueActivityTypeKitesurf); break;
    }
  }

  function loadGeneralBackgroundColor() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userGeneralBackgroundColor"), Gfx.COLOR_WHITE);
  }
  function saveGeneralBackgroundColor(_iValue as Number) as Void {
    App.Properties.setValue("userGeneralBackgroundColor", _iValue as App.PropertyValueType);
  }
  function setGeneralBackgroundColor(_iValue as Number) as Void {
    if(_iValue==0) {
      self.iGeneralBackgroundColor = Gfx.COLOR_BLACK;
    }
    else {
      self.iGeneralBackgroundColor = Gfx.COLOR_WHITE;
    }
  }

  function loadActiveLook() as Boolean {
    return LangUtils.readKeyBoolean(App.Properties.getValue("userActiveLook"), false);
  }
  function saveActiveLook(_bValue as Boolean) as Void {
    App.Properties.setValue("userActiveLook", _bValue as App.PropertyValueType);
  }
  function setActiveLook(_bValue as Boolean) as Void {
    self.bActiveLook = _bValue;
  }

  function loadVectorVario() as Boolean {
    return LangUtils.readKeyBoolean(App.Properties.getValue("userVectorVario"), false);
  }
  function saveVectorVario(_bValue as Boolean) as Void {
    App.Properties.setValue("userVectorVario", _bValue as App.PropertyValueType);
  }
  function setVectorVario(_bValue as Boolean) as Void {
    self.bVectorVario = _bValue;
  }


  function loadGPS() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userGPS"), 0);
  }
  function saveGPS(_iValue as Number) as Void {
    App.Properties.setValue("userGPS", _iValue as App.PropertyValueType);
  }
  function setGPS(_iValue as Number) as Void {
    if(_iValue > 1) {
      _iValue = 1;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iGPS = _iValue;
  }

  function loadGeneralViewActivePageIndex() as Number {
    try {
      return LangUtils.readKeyNumber(App.Storage.getValue("userGeneralViewActivePageIndex"), 0);
    } catch (e) {
      try {
        return LangUtils.readKeyNumber(App.Properties.getValue("userGeneralViewActivePageIndex"), 0);
      } catch (e2) {
        return 0;
      }
    }
  }
  function saveGeneralViewActivePageIndex(_iValue as Number) as Void {
    try {
      App.Storage.setValue("userGeneralViewActivePageIndex", _iValue as App.PropertyValueType);
    } catch (e) {
      // Ignore persistence failure silently.
    }
  }
  function setGeneralViewActivePageIndex(_iValue as Number) as Void {
    if(_iValue < 0) {
      _iValue = 0;
    }
    else if(_iValue >= self.aGeneralViewPageNames.size()) {
      _iValue = self.aGeneralViewPageNames.size() - 1;
    }
    self.iGeneralViewActivePageIndex = _iValue;
  }

  function nextGeneralViewPage() as Boolean {
    var iPageCount = self.getGeneralViewPageCount();
    if(iPageCount <= 1) {
      return false;
    }
    var iCurrentPage = self.iGeneralViewActivePageIndex;
    if(iCurrentPage < iPageCount - 1) {
      var iNextPage = iCurrentPage + 1;
      self.setGeneralViewActivePageIndex(iNextPage);
      self.saveGeneralViewActivePageIndex(iNextPage);
      return true;
    }
    return false;
  }

  function previousGeneralViewPage() as Boolean {
    var iPageCount = self.getGeneralViewPageCount();
    if(iPageCount <= 1) {
      return false;
    }
    var iCurrentPage = self.iGeneralViewActivePageIndex;
    if(iCurrentPage > 0) {
      var iPreviousPage = iCurrentPage - 1;
      self.setGeneralViewActivePageIndex(iPreviousPage);
      self.saveGeneralViewActivePageIndex(iPreviousPage);
      return true;
    }
    return false;
  }

  function selectFirstGeneralViewPage() as Void {
    if(self.getGeneralViewPageCount() > 0) {
      self.setGeneralViewActivePageIndex(0);
      self.saveGeneralViewActivePageIndex(self.iGeneralViewActivePageIndex);
    }
  }

  function selectLastGeneralViewPage() as Void {
    var iPageCount = self.getGeneralViewPageCount();
    if(iPageCount > 0) {
      self.setGeneralViewActivePageIndex(iPageCount - 1);
      self.saveGeneralViewActivePageIndex(self.iGeneralViewActivePageIndex);
    }
  }

  function saveGeneralViewPageData(_sValue as String) as Void {
    if(_sValue == null) {
      _sValue = "";
    }
    //// Sys.println("DEBUG: saveGeneralViewPageData() - Saving: '" + _sValue + "'");
    try {
      App.Storage.setValue("userGeneralViewPageData", _sValue as App.PropertyValueType);
      // Sys.println("DEBUG: saveGeneralViewPageData() - Saved to Storage");
    } catch (e) {
      // Ignore persistence failure silently.
      // Sys.println("DEBUG: saveGeneralViewPageData() - Storage failed!");
    }
  }

  function loadGeneralViewPageData() as String {
    try {
      var sValue = LangUtils.readKeyString(App.Storage.getValue("userGeneralViewPageData"), "");
      // Sys.println("DEBUG: loadGeneralViewPageData() - Loaded from Storage: '" + sValue + "'");
      return sValue;
    } catch (e) {
      // Sys.println("DEBUG: loadGeneralViewPageData() - Storage failed, trying legacy Properties");
      try {
        var sValue2 = LangUtils.readKeyString(App.Properties.getValue("userGeneralViewPageData"), "");
        // Sys.println("DEBUG: loadGeneralViewPageData() - Loaded from legacy Properties: '" + sValue2 + "'");
        return sValue2;
      } catch (e2) {
        // Sys.println("DEBUG: loadGeneralViewPageData() - Legacy Properties also failed, returning empty");
        return "";
      }
    }
  }

  function loadGeneralViewPages() as Void {
    self.aGeneralViewPageNames = [];
    self.aGeneralViewPageLayouts = [];
    self.aaGeneralViewPageFields = [];
    self.iGeneralViewActivePageIndex = self.loadGeneralViewActivePageIndex();

    var sPageData = self.loadGeneralViewPageData();
    // Sys.println("DEBUG: loadGeneralViewPages() - sPageData = '" + (sPageData as String) + "'");
    if(sPageData == null || sPageData == "") {
      self.createDefaultGeneralViewPages();
      // Sys.println("DEBUG: loadGeneralViewPages() - Created default pages");
      return;
    }

    var asPageStrings = LangUtils.split(sPageData, ";");
    for(var i=0; i<asPageStrings.size(); i++) {
      var sPageEntry = asPageStrings[i];
      if(sPageEntry == null || sPageEntry == "") {
        continue;
      }
      var asParts = LangUtils.split(sPageEntry, "|");
      if(asParts.size() < 3) {
        continue;
      }
      var sName = LangUtils.replace(asParts[0], "|", "_");
      sName = LangUtils.replace(sName, ";", "_");
      var iLayout = asParts[1].toNumber();
      var sFields = asParts[2];
      var aFields = [];
      if(sFields != null && sFields != "") {
        var asFieldTokens = LangUtils.split(sFields, ",");
        for(var j=0; j<asFieldTokens.size(); j++) {
          aFields.add(asFieldTokens[j].toNumber());
        }
      }
      while(aFields.size() < self.GENERAL_VIEW_PAGE_COUNT) {
        aFields.add(self.GENERAL_VIEW_PAGE_SLOT_UNUSED);
      }
      self.aGeneralViewPageNames.add(sName);
      self.aGeneralViewPageLayouts.add(iLayout);
      self.aaGeneralViewPageFields.add(aFields);
    }

    if(self.aGeneralViewPageNames.size() == 0) {
      self.createDefaultGeneralViewPages();
    }
    if(self.iGeneralViewActivePageIndex < 0 || self.iGeneralViewActivePageIndex >= self.aGeneralViewPageNames.size()) {
      self.iGeneralViewActivePageIndex = 0;
    }
    // Sys.println("DEBUG: loadGeneralViewPages() - Loaded " + self.aGeneralViewPageNames.size() + " pages");
    for(var i=0; i<self.aGeneralViewPageNames.size(); i++) {
      // Sys.println("DEBUG:   Page " + i + ": name='" + self.aGeneralViewPageNames[i] + "' layout=" + self.aGeneralViewPageLayouts[i]);
    }
  }

  function createGeneralViewPage(_sName as String, _iLayout as Number) as Void {
    if(self.aGeneralViewPageNames.size() >= 10) {
      // Sys.println("DEBUG: createGeneralViewPage() - Page limit reached, cannot add more pages.");
      return;
    }
    // Sys.println("DEBUG: createGeneralViewPage() - Adding page: name='" + _sName + "' layout=" + _iLayout);
    if(_sName == null || _sName == "") {
      _sName = "Page " + (self.aGeneralViewPageNames.size() + 1).format("%d");
    }
    if(_iLayout != self.GENERAL_VIEW_PAGE_LAYOUT_2 && _iLayout != self.GENERAL_VIEW_PAGE_LAYOUT_4) {
      _iLayout = self.GENERAL_VIEW_PAGE_LAYOUT_7;
    }
    var aFields = [];
    var iDefaultCount = _iLayout;
    for(var i=0; i<self.GENERAL_VIEW_PAGE_COUNT; i++) {
      if(i < iDefaultCount) {
        aFields.add(i);
      }
      else {
        aFields.add(self.GENERAL_VIEW_PAGE_SLOT_UNUSED);
      }
    }
    self.aGeneralViewPageNames.add(_sName);
    self.aGeneralViewPageLayouts.add(_iLayout);
    self.aaGeneralViewPageFields.add(aFields);
    self.iGeneralViewActivePageIndex = self.aGeneralViewPageNames.size() - 1;
    self.saveGeneralViewPages();
    self.saveGeneralViewActivePageIndex(self.iGeneralViewActivePageIndex);
  }

  function removeArrayIndex(_aArray as Array, _iIndex as Number) as Array {
    var aResult = [];
    for(var i=0; i<_aArray.size(); i++) {
      if(i != _iIndex) {
        aResult.add(_aArray[i]);
      }
    }
    return aResult;
  }

  function deleteGeneralViewPage(_iPageIndex as Number) as Boolean {
    // Sys.println("DEBUG: deleteGeneralViewPage() - Deleting page " + _iPageIndex + " from " + self.aGeneralViewPageNames.size() + " pages");
    // Prevent deletion of the last page; always keep at least one page
    if(self.aGeneralViewPageNames.size() <= 1) {
      // Sys.println("DEBUG: deleteGeneralViewPage() - Cannot delete last page");
      return false;
    }
    if(_iPageIndex < 0 || _iPageIndex >= self.aGeneralViewPageNames.size()) {
      // Sys.println("DEBUG: deleteGeneralViewPage() - Invalid page index");
      return false;
    }
    // Sys.println("DEBUG: deleteGeneralViewPage() - Removing page '" + (self.aGeneralViewPageNames[_iPageIndex] as String) + "'");
    self.aGeneralViewPageNames = self.removeArrayIndex(self.aGeneralViewPageNames, _iPageIndex);
    self.aGeneralViewPageLayouts = self.removeArrayIndex(self.aGeneralViewPageLayouts, _iPageIndex);
    self.aaGeneralViewPageFields = self.removeArrayIndex(self.aaGeneralViewPageFields, _iPageIndex);
    
    // Ensure arrays stay in sync
    while(self.aGeneralViewPageLayouts.size() > self.aGeneralViewPageNames.size()) {
      self.aGeneralViewPageLayouts = self.removeArrayIndex(self.aGeneralViewPageLayouts, self.aGeneralViewPageLayouts.size() - 1);
    }
    while(self.aaGeneralViewPageFields.size() > self.aGeneralViewPageNames.size()) {
      self.aaGeneralViewPageFields = self.removeArrayIndex(self.aaGeneralViewPageFields, self.aaGeneralViewPageFields.size() - 1);
    }
    
    // Adjust active page index if needed
    if(self.iGeneralViewActivePageIndex >= self.aGeneralViewPageNames.size()) {
      self.iGeneralViewActivePageIndex = self.aGeneralViewPageNames.size() - 1;
    }
    if(self.iGeneralViewActivePageIndex < 0) {
      self.iGeneralViewActivePageIndex = 0;
    }
    // Sys.println("DEBUG: deleteGeneralViewPage() - Now " + self.aGeneralViewPageNames.size() + " pages");
    self.saveGeneralViewPages();
    self.saveGeneralViewActivePageIndex(self.iGeneralViewActivePageIndex);
    return true;
  }

  function getGeneralViewPageCount() as Number {
    return self.aGeneralViewPageNames.size();
  }

  function getGeneralViewPageLayout(_iPageIndex as Number) as Number {
    if(_iPageIndex < 0 || _iPageIndex >= self.aGeneralViewPageLayouts.size()) {
      return self.GENERAL_VIEW_PAGE_LAYOUT_7;
    }
    return self.aGeneralViewPageLayouts[_iPageIndex] as Number;
  }

  function getGeneralViewPageFields(_iPageIndex as Number) as Array {
    if(_iPageIndex < 0 || _iPageIndex >= self.aaGeneralViewPageFields.size()) {
      return [];
    }
    return self.aaGeneralViewPageFields[_iPageIndex] as Array;
  }

  function setGeneralViewPageField(_iPageIndex as Number, _iFieldIndex as Number, _iIndicator as Number) as Void {
    if(_iPageIndex < 0 || _iPageIndex >= self.aaGeneralViewPageFields.size()) {
      return;
    }
    var aFields = self.aaGeneralViewPageFields[_iPageIndex] as Array;
    if(_iFieldIndex < 0 || _iFieldIndex >= aFields.size()) {
      return;
    }
    aFields[_iFieldIndex] = _iIndicator;
    self.saveGeneralViewPages();
  }

  function getGeneralViewPageName(_iPageIndex as Number) as String {
    if(_iPageIndex < 0 || _iPageIndex >= self.aGeneralViewPageNames.size()) {
      return "Unknown";
    }
    return self.aGeneralViewPageNames[_iPageIndex] as String;
  }

  function saveGeneralViewPages() as Void {
    // Sys.println("DEBUG: saveGeneralViewPages() - Saving " + self.aGeneralViewPageNames.size() + " pages");
    // Ensure all arrays are synchronized before saving
    var iCount = self.aGeneralViewPageNames.size();
    if(self.aGeneralViewPageLayouts.size() != iCount || self.aaGeneralViewPageFields.size() != iCount) {
      // Sys.println("DEBUG: saveGeneralViewPages() - Arrays out of sync, syncing...");
      // Arrays out of sync; attempt to truncate or extend to match
      while(self.aGeneralViewPageLayouts.size() < iCount) {
        self.aGeneralViewPageLayouts.add(self.GENERAL_VIEW_PAGE_LAYOUT_7);
      }
      while(self.aGeneralViewPageLayouts.size() > iCount) {
        self.aGeneralViewPageLayouts = self.removeArrayIndex(self.aGeneralViewPageLayouts, self.aGeneralViewPageLayouts.size() - 1);
      }
      while(self.aaGeneralViewPageFields.size() < iCount) {
        var aDefaultFields = [];
        for(var k=0; k<self.GENERAL_VIEW_PAGE_COUNT; k++) {
          aDefaultFields.add(self.GENERAL_VIEW_PAGE_SLOT_UNUSED);
        }
        self.aaGeneralViewPageFields.add(aDefaultFields);
      }
      while(self.aaGeneralViewPageFields.size() > iCount) {
        self.aaGeneralViewPageFields = self.removeArrayIndex(self.aaGeneralViewPageFields, self.aaGeneralViewPageFields.size() - 1);
      }
    }
    
    var sPageData = "";
    for(var i=0; i<self.aGeneralViewPageNames.size(); i++) {
      if(i > 0) {
        sPageData += ";";
      }
      var sName = self.aGeneralViewPageNames[i] as String;
      sName = LangUtils.replace(sName, "|", "_");
      sName = LangUtils.replace(sName, ";", "_");
      var iLayout = (i < self.aGeneralViewPageLayouts.size()) ? (self.aGeneralViewPageLayouts[i] as Number) : self.GENERAL_VIEW_PAGE_LAYOUT_7;
      var aFields = (i < self.aaGeneralViewPageFields.size()) ? (self.aaGeneralViewPageFields[i] as Array) : [];
      var sFields = "";
      for(var j=0; j<aFields.size(); j++) {
        if(j > 0) {
          sFields += ",";
        }
        sFields += (aFields[j] as Number).format("%d");
      }
      sPageData += sName + "|" + iLayout.format("%d") + "|" + sFields;
      // Sys.println("DEBUG:   Page " + i + ": '" + sName + "|" + iLayout.format("%d") + "|" + sFields + "'");
    }
    // Sys.println("DEBUG: saveGeneralViewPages() - Final data: '" + sPageData + "'");
    self.saveGeneralViewPageData(sPageData);
  }

  function createDefaultGeneralViewPages() as Void {
    self.aGeneralViewPageNames = ["General"];
    self.aGeneralViewPageLayouts = [self.GENERAL_VIEW_PAGE_LAYOUT_7];
    self.aaGeneralViewPageFields = [[0,1,2,3,4,5,6]];
    self.iGeneralViewActivePageIndex = 0;
    self.saveGeneralViewPages();
    self.saveGeneralViewActivePageIndex(self.iGeneralViewActivePageIndex);
  }

  function loadMapDisplay() as Boolean {
    return LangUtils.readKeyBoolean(App.Properties.getValue("userMapDisplay"), false);
  }
  function saveMapDisplay(_bValue as Boolean) as Void {
    App.Properties.setValue("userMapDisplay", _bValue as App.PropertyValueType);
  }
  function setMapDisplay(_bValue as Boolean) as Void {
    self.bMapDisplay = _bValue;
  }

  function loadCompetitionMode() as Boolean {
    return LangUtils.readKeyBoolean(App.Properties.getValue("userCompetitionMode"), false);
  }
  function saveCompetitionMode(_bValue as Boolean) as Void {
    App.Properties.setValue("userCompetitionMode", _bValue as App.PropertyValueType);
  }
  function setCompetitionMode(_bValue as Boolean) as Void {
    self.bCompetitionMode = _bValue;
  }

  function loadCompetitionTaskDefinition() as String {
    return LangUtils.readKeyString(App.Properties.getValue("userCompetitionTaskDefinition"), "");
  }
  function saveCompetitionTaskDefinition(_sValue as String) as Void {
    App.Properties.setValue("userCompetitionTaskDefinition", _sValue as App.PropertyValueType);
  }
  function setCompetitionTaskDefinition(_sValue as String) as Void {
    self.sCompetitionTaskDefinition = LangUtils.readKeyString(_sValue, "");
  }

  function loadCompetitionTaskUrl() as String {
    return LangUtils.readKeyString(App.Properties.getValue("userCompetitionTaskUrl"), "");
  }
  function saveCompetitionTaskUrl(_sValue as String) as Void {
    App.Properties.setValue("userCompetitionTaskUrl", _sValue as App.PropertyValueType);
  }
  function setCompetitionTaskUrl(_sValue as String) as Void {
    self.sCompetitionTaskUrl = LangUtils.readKeyString(_sValue, "");
  }

  function loadCompetitionTaskCode() as String {
    return LangUtils.readKeyString(App.Properties.getValue("userCompetitionTaskCode"), "");
  }
  function saveCompetitionTaskCode(_sValue as String) as Void {
    App.Properties.setValue("userCompetitionTaskCode", _sValue as App.PropertyValueType);
  }
  function setCompetitionTaskCode(_sValue as String) as Void {
    self.sCompetitionTaskCode = LangUtils.readKeyString(_sValue, "");
  }

  function loadCompetitionTaskSource() as String {
    return LangUtils.readKeyString(App.Properties.getValue("userCompetitionTaskSource"), "");
  }
  function saveCompetitionTaskSource(_sValue as String) as Void {
    App.Properties.setValue("userCompetitionTaskSource", _sValue as App.PropertyValueType);
  }
  function setCompetitionTaskSource(_sValue as String) as Void {
    self.sCompetitionTaskSource = LangUtils.readKeyString(_sValue, "");
  }

  function resolveCompetitionTaskSource() as String {
    if(self.sCompetitionTaskDefinition.length() > 0) {
      return self.sCompetitionTaskDefinition;
    }
    if(self.sCompetitionTaskUrl.length() > 0) {
      return self.sCompetitionTaskUrl;
    }
    if(self.sCompetitionTaskCode.length() > 0) {
      return self.sCompetitionTaskCode;
    }
    return self.loadCompetitionTaskSource();
  }
  

  function loadUnitDistance() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userUnitDistance"), -1);
  }
  function saveUnitDistance(_iValue as Number) as Void {
    App.Properties.setValue("userUnitDistance", _iValue as App.PropertyValueType);
  }
  function setUnitDistance(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 2) {
      _iValue = -1;
    }
    self.iUnitDistance = _iValue;
    if(self.iUnitDistance < 0) {  // ... auto
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :distanceUnits and oDeviceSettings.distanceUnits != null) {
        _iValue = oDeviceSettings.distanceUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == 2) {  // ... nautical
      // ... [nm]
      self.sUnitDistance = "nm";
      self.fUnitDistanceCoefficient = 0.000539956803456f;  // ... m -> nm
      // ... [kt]
      self.sUnitHorizontalSpeed = "kt";
      self.fUnitHorizontalSpeedCoefficient = 1.94384449244f;  // ... m/s -> kt
    }
    else if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
      // ... [sm]
      self.sUnitDistance = "sm";
      self.fUnitDistanceCoefficient = 0.000621371192237f;  // ... m -> sm
      // ... [mph]
      self.sUnitHorizontalSpeed = "mph";
      self.fUnitHorizontalSpeedCoefficient = 2.23693629205f;  // ... m/s -> mph
    }
    else {  // ... metric
      // ... [km]
      self.sUnitDistance = "km";
      self.fUnitDistanceCoefficient = 0.001f;  // ... m -> km
      // ... [km/h]
      self.sUnitHorizontalSpeed = "km/h";
      self.fUnitHorizontalSpeedCoefficient = 3.6f;  // ... m/s -> km/h
    }
  }

  function loadUnitElevation() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userUnitElevation"), -1);
  }
  function saveUnitElevation(_iValue as Number) as Void {
    App.Properties.setValue("userUnitElevation", _iValue as App.PropertyValueType);
  }
  function setUnitElevation(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = -1;
    }
    self.iUnitElevation = _iValue;
    if(self.iUnitElevation < 0) {  // ... auto
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :elevationUnits and oDeviceSettings.elevationUnits != null) {
        _iValue = oDeviceSettings.elevationUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
      // ... [ft]
      self.sUnitElevation = "ft";
      self.fUnitElevationCoefficient = 3.280839895f;  // ... m -> ft
      // ... [ft/min]
      self.sUnitVerticalSpeed = "ft/m";
      self.fUnitVerticalSpeedCoefficient = 196.8503937f;  // ... m/s -> ft/min
    }
    else {  // ... metric
      // ... [m]
      self.sUnitElevation = "m";
      self.fUnitElevationCoefficient = 1.0f;  // ... m -> m
      // ... [m/s]
      self.sUnitVerticalSpeed = "m/s";
      self.fUnitVerticalSpeedCoefficient = 1.0f;  // ... m/s -> m/s
    }
  }

  function loadUnitPressure() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userUnitPressure"), -1);
  }
  function saveUnitPressure(_iValue as Number) as Void {
    App.Properties.setValue("userUnitPressure", _iValue as App.PropertyValueType);
  }
  function setUnitPressure(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = -1;
    }
    self.iUnitPressure = _iValue;
    if(self.iUnitPressure < 0) {  // ... auto
      // NOTE: assume weight units are a good indicator of preferred pressure units
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :weightUnits and oDeviceSettings.weightUnits != null) {
        _iValue = oDeviceSettings.weightUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }
    if(_iValue == Sys.UNIT_STATUTE) {  // ... statute
      // ... [inHg]
      self.sUnitPressure = "inHg";
      self.fUnitPressureCoefficient = 0.0002953f;  // ... Pa -> inHg
    }
    else {  // ... metric
      // ... [mb/hPa]
      self.sUnitPressure = "mb";
      self.fUnitPressureCoefficient = 0.01f;  // ... Pa -> mb/hPa
    }
  }

  function loadUnitDirection() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userUnitDirection"), 1);
  }
  function saveUnitDirection(_iValue as Number) as Void {
    App.Properties.setValue("userUnitDirection", _iValue as App.PropertyValueType);
  }
  function setUnitDirection(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 1) {
      _iValue = 1;
    }
    self.iUnitDirection = _iValue;
    if(_iValue == 1) {  // ... Text
      // ... txt
      self.sUnitDirection = "txt";
    }
    else {  // ... Degrees
      self.sUnitDirection = "Deg";
    }
  }

  function loadUnitWindSpeed() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userUnitWindSpeed"), 1);
  }
  function saveUnitWindSpeed(_iValue as Number) as Void {
    App.Properties.setValue("userUnitWindSpeed", _iValue as App.PropertyValueType);
  }
  function setUnitWindSpeed(_iValue as Number) as Void {
    if(_iValue < 0 or _iValue > 3) {
      _iValue = -1;
    }
    self.iUnitDistance = _iValue;
    if(self.iUnitDistance < 0) {  // ... auto
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :distanceUnits and oDeviceSettings.distanceUnits != null) {
        _iValue = oDeviceSettings.distanceUnits;
      }
      else {
        _iValue = Sys.UNIT_METRIC;
      }
    }

    if (_iValue == Sys.UNIT_METRIC) {
      self.sUnitWindSpeed = "km/h";
      self.fUnitWindSpeedCoefficient = 3.6f;  // ... m/s -> km/h
    } else if (_iValue == Sys.UNIT_STATUTE) {
      self.sUnitWindSpeed = "mph";
      self.fUnitWindSpeedCoefficient = 2.23693629205f;  // ... m/s -> mph
    } else if (_iValue == 2) {
      self.sUnitWindSpeed = "kt";
      self.fUnitWindSpeedCoefficient = 1.94384449244f;  // ... m/s -> kt
    } else {
      self.sUnitWindSpeed = "m/s";
      self.fUnitWindSpeedCoefficient = 1.0f;  // ... m/s -> m/s
    }
  }
  function loadUnitTimeUTC() as Boolean {
    try {
      return LangUtils.readKeyBoolean(App.Storage.getValue("userUnitTimeUTC"), false);
    } catch (e) {
      try {
        return LangUtils.readKeyBoolean(App.Properties.getValue("userUnitTimeUTC"), false);
      } catch (e2) {
        return false;
      }
    }
  }
  function saveUnitTimeUTC(_bValue as Boolean) as Void {
    App.Storage.setValue("userUnitTimeUTC", _bValue as App.PropertyValueType);
  }
  function setUnitTimeUTC(_bValue as Boolean) as Void {
    self.bUnitTimeUTC = _bValue;
    if(_bValue) {
      self.sUnitTime = "Z";
    }
    else {
      self.sUnitTime = "LT";
    }
  }

  function loadLivetrack24Frequency() as Number { 
    return LangUtils.readKeyNumber(App.Properties.getValue("userLivetrack24Frequency"), 0);
  }
  function saveLivetrack24Frequency(_iValue as Number) as Void { 
    App.Properties.setValue("userLivetrack24Frequency", _iValue as App.PropertyValueType);
  }
  function setLivetrack24Frequency(_iValue as Number) as Void {
    if(_iValue > 8) {
      _iValue = 8;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iLivetrack24Frequency = _iValue;
    switch(self.iLivetrack24Frequency) {
    case 0: self.iLivetrack24FrequencySeconds = 0; break;
    case 1: self.iLivetrack24FrequencySeconds = 2; break;
    case 2: self.iLivetrack24FrequencySeconds = 5; break;
    case 3: self.iLivetrack24FrequencySeconds = 15; break;
    case 4: self.iLivetrack24FrequencySeconds = 30; break;
    case 5: self.iLivetrack24FrequencySeconds = 60; break;
    case 6: self.iLivetrack24FrequencySeconds = 120; break;
    case 7: self.iLivetrack24FrequencySeconds = 180; break;
    case 8: self.iLivetrack24FrequencySeconds = 300; break;
    }
  }

  function loadSportsTrackLiveFrequency() as Number { 
    return LangUtils.readKeyNumber(App.Properties.getValue("userSportsTrackLiveFrequency"), 0);
  }
  function saveSportsTrackLiveFrequency(_iValue as Number) as Void { 
    App.Properties.setValue("userSportsTrackLiveFrequency", _iValue as App.PropertyValueType);
  }
  function setSportsTrackLiveFrequency(_iValue as Number) as Void {
    if(_iValue > 8) {
      _iValue = 8;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iSportsTrackLiveFrequency = _iValue;
    switch(self.iSportsTrackLiveFrequency) {
    case 0: self.iSportsTrackLiveFrequencySeconds = 0; break;
    case 1: self.iSportsTrackLiveFrequencySeconds = 2; break;
    case 2: self.iSportsTrackLiveFrequencySeconds = 5; break;
    case 3: self.iSportsTrackLiveFrequencySeconds = 15; break;
    case 4: self.iSportsTrackLiveFrequencySeconds = 30; break;
    case 5: self.iSportsTrackLiveFrequencySeconds = 60; break;
    case 6: self.iSportsTrackLiveFrequencySeconds = 120; break;
    case 7: self.iSportsTrackLiveFrequencySeconds = 180; break;
    case 8: self.iSportsTrackLiveFrequencySeconds = 300; break;
    }
  }

  function loadFlySafeLivetrackFrequency() as Number { 
    return LangUtils.readKeyNumber(App.Properties.getValue("userFlySafeLivetrackFrequency"), 0);
  }
  function saveFlySafeLivetrackFrequency(_iValue as Number) as Void { 
    App.Properties.setValue("userFlySafeLivetrackFrequency", _iValue as App.PropertyValueType);
  }
  function setFlySafeLivetrackFrequency(_iValue as Number) as Void {
    if(_iValue > 8) {
      _iValue = 8;
    }
    else if(_iValue < 0) {
      _iValue = 0;
    }
    self.iFlySafeLivetrackFrequency = _iValue;
    switch(self.iFlySafeLivetrackFrequency) {
    case 0: self.iFlySafeLivetrackFrequencySeconds = 0; break;
    case 1: self.iFlySafeLivetrackFrequencySeconds = 10; break;
    case 2: self.iFlySafeLivetrackFrequencySeconds = 15; break;
    case 3: self.iFlySafeLivetrackFrequencySeconds = 20; break;
    case 4: self.iFlySafeLivetrackFrequencySeconds = 30; break;
    case 5: self.iFlySafeLivetrackFrequencySeconds = 60; break;
    case 6: self.iFlySafeLivetrackFrequencySeconds = 120; break;
    case 7: self.iFlySafeLivetrackFrequencySeconds = 180; break;
    case 8: self.iFlySafeLivetrackFrequencySeconds = 300; break;
    }
  }

}
