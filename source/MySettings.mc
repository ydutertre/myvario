// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (C) 2022 Yannick Dutertre <https://yannickd9.wixsite.com/myvario>
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
  public var fAltimeterCorrectionAbsolute as Float = 0.0f;
  public var fAltimeterCorrectionRelative as Float = 1.0f;
  // ... variometer
  public var iVariometerRange as Number = 0;
  public var bVariometerAutoThermal as Boolean = true;
  public var bVariometerThermalDetect as Boolean = true;
  public var iVariometerSmoothing as Number = 1;
  public var iVariometerPlotRange as Number = 2;
  public var iVariometerPlotZoom as Number = 9;
  // ... sounds
  public var bSoundsVariometerTones as Boolean = true;
  public var bVariometerVibrations as Boolean = true;
  public var iMinimumClimb as Number = 2; // Default value of 0.2m/s climb threshold before sounds and vibrations are triggered
  public var iMinimumSink as Number = 1;
  // ... activity
  public var bActivityAutoStart as Boolean = true; //Auto-start recording after launch
  public var fActivityAutoSpeedStart as Float = 3.0f;
  // ... general
  public var iGeneralBackgroundColor as Number = Gfx.COLOR_WHITE;
  public var bActiveLook as Boolean = false;
  // ... units
  public var iUnitDistance as Number = -1;
  public var iUnitElevation as Number = -1;
  public var iUnitPressure as Number = -1;
  public var iUnitDirection as Number = 1;
  public var bUnitTimeUTC as Boolean = false;
  // ... livetrack
  public var iLivetrack24Frequency = 0;
  public var iSportsTrackLiveFrequency = 0;

  // Units
  // ... symbols
  public var sUnitDistance as String = "km";
  public var sUnitHorizontalSpeed as String = "km/h";
  public var sUnitElevation as String = "m";
  public var sUnitVerticalSpeed as String = "m/s";
  public var sUnitPressure as String = "mb";
  public var sUnitDirection as String = "txt";
  public var sUnitTime as String = "LT";
  // ... conversion coefficients
  public var fUnitDistanceCoefficient as Float = 0.001f;
  public var fUnitHorizontalSpeedCoefficient as Float = 3.6f;
  public var fUnitElevationCoefficient as Float = 1.0f;
  public var fUnitVerticalSpeedCoefficient as Float = 1.0f;
  public var fUnitPressureCoefficient as Float = 0.01f;

  // Other
  public var fVariometerRange as Float = 3.0f;
  public var fVariometerPlotZoom as Float = 0.0308666666667f;
  public var fVariometerPlotScale as Number = 1.0f;
  public var fMinimumClimb as Float = 0.2;
  public var fMinimumSink as Float = 2.0;
  public var fVariometerSmoothing as Float = 0.5; //Standard deviation of altitude measurement at fixed altitude
  public var iLivetrack24FrequencySeconds as Number = 0;
  public var iSportsTrackLiveFrequencySeconds as Number = 0;

  //
  // FUNCTIONS: self
  //

  function load() as Void {
    // Settings
    // ... altimeter
    self.setAltimeterCalibrationQNH(self.loadAltimeterCalibrationQNH());
    self.setAltimeterCorrectionAbsolute(self.loadAltimeterCorrectionAbsolute());
    self.setAltimeterCorrectionRelative(self.loadAltimeterCorrectionRelative());
    // ... variometer
    self.setVariometerRange(self.loadVariometerRange());
    self.setVariometerAutoThermal(self.loadVariometerAutoThermal());
    self.setVariometerThermalDetect(self.loadVariometerThermalDetect());
    self.setVariometerSmoothing(self.loadVariometerSmoothing());
    self.setVariometerPlotRange(self.loadVariometerPlotRange());
    self.setVariometerPlotZoom(self.loadVariometerPlotZoom());
    // ... sounds and vibration
    self.setSoundsVariometerTones(self.loadSoundsVariometerTones());
    self.setVariometerVibrations(self.loadVariometerVibrations());
    self.setMinimumClimb(self.loadMinimumClimb());
    self.setMinimumSink(self.loadMinimumSink());
    // ... activity
    self.setActivityAutoStart(self.loadActivityAutoStart());
    self.setActivityAutoSpeedStart(self.loadActivityAutoSpeedStart());
    // ... general
    self.setGeneralBackgroundColor(self.loadGeneralBackgroundColor());
    self.setActiveLook(self.loadActiveLook());
    // ... units
    self.setUnitDistance(self.loadUnitDistance());
    self.setUnitElevation(self.loadUnitElevation());
    self.setUnitPressure(self.loadUnitPressure());
    self.setUnitDirection(self.loadUnitDirection());
    self.setUnitTimeUTC(self.loadUnitTimeUTC());
    // ... livetrack
    self.setLivetrack24Frequency(self.loadLivetrack24Frequency());
    self.setSportsTrackLiveFrequency(self.loadSportsTrackLiveFrequency());
  }

  function loadAltimeterCalibrationQNH() as Float {  // [Pa]
    return LangUtils.readKeyFloat(App.Properties.getValue("userAltimeterCalibrationQNH"), 101325.0f);
  }
  function saveAltimeterCalibrationQNH(_fValue as Float) as Void {  // [Pa]
    App.Properties.setValue("userAltimeterCalibrationQNH", _fValue as App.PropertyValueType);
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

  function loadAltimeterCorrectionAbsolute() as Float {  // [Pa]
    return LangUtils.readKeyFloat(App.Properties.getValue("userAltimeterCorrectionAbsolute"), 0.0f);
  }
  function saveAltimeterCorrectionAbsolute(_fValue as Float) as Void {  // [Pa]
    App.Properties.setValue("userAltimeterCorrectionAbsolute", _fValue as App.PropertyValueType);
  }
  function setAltimeterCorrectionAbsolute(_fValue as Float) as Void {  // [Pa]
    if(_fValue > 9999.0f) {
      _fValue = 9999.0f;
    }
    else if(_fValue < -9999.0f) {
      _fValue = -9999.0f;
    }
    self.fAltimeterCorrectionAbsolute = _fValue;
  }

  function loadAltimeterCorrectionRelative() as Float {
    return LangUtils.readKeyFloat(App.Properties.getValue("userAltimeterCorrectionRelative"), 1.0f);
  }
  function saveAltimeterCorrectionRelative(_fValue as Float) as Void {
    App.Properties.setValue("userAltimeterCorrectionRelative", _fValue as App.PropertyValueType);
  }
  function setAltimeterCorrectionRelative(_fValue as Float) as Void {
    if(_fValue > 1.9999f) {
      _fValue = 1.9999f;
    }
    else if(_fValue < 0.0001f) {
      _fValue = 0.0001f;
    }
    self.fAltimeterCorrectionRelative = _fValue;
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
    case 0: self.fVariometerSmoothing = 0.2f; break;
    case 1: self.fVariometerSmoothing = 0.5f; break;
    case 2: self.fVariometerSmoothing = 0.7f; break;
    case 3: self.fVariometerSmoothing = 1.0f; break;
    }
  }

  function loadVariometerPlotZoom() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userVariometerPlotZoom"), 9);
  }
  function saveVariometerPlotZoom(_iValue as Number) as Void {
    App.Properties.setValue("userVariometerPlotZoom", _iValue as App.PropertyValueType);
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

  function loadGeneralBackgroundColor() as Number {
    return LangUtils.readKeyNumber(App.Properties.getValue("userGeneralBackgroundColor"), Gfx.COLOR_WHITE);
  }
  function saveGeneralBackgroundColor(_iValue as Number) as Void {
    App.Properties.setValue("userGeneralBackgroundColor", _iValue as App.PropertyValueType);
  }
  function setGeneralBackgroundColor(_iValue as Number) as Void {
    self.iGeneralBackgroundColor = _iValue;
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
      self.sUnitDirection = "°";
    }
  }

  function loadUnitTimeUTC() as Boolean {
    return LangUtils.readKeyBoolean(App.Properties.getValue("userUnitTimeUTC"), false);
  }
  function saveUnitTimeUTC(_bValue as Boolean) as Void {
    App.Properties.setValue("userUnitTimeUTC", _bValue as App.PropertyValueType);
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

}
