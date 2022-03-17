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
// The Wind Calculation method is based on an algorithm by fiala
// Available at: https://github.com/fhorinek/SkyDrop/blob/master/skydrop/src/fc/wind.cpp

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
using Toybox.Math;
using Toybox.Position as Pos;
using Toybox.Sensor;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.WatchUi as Ui;

//
// CLASS
//

class MyProcessing {

  //
  // CONSTANTS
  //

  // Plot buffer
  public const PLOTBUFFER_SIZE = 300;  // 5 minutes = 300 seconds
  // Wind estimation sectors
  public const DIRECTION_NUM_OF_SECTORS = 8;

  //
  // VARIABLES
  //

  // Internal calculation objects
  private var fEnergyCineticLossFactor as Float = 0.25f;
  // ... we must calculate our own vertical speed
  private var iPreviousAltitudeEpoch as Number = -1;
  private var fPreviousAltitude as Float = 0.0f;
  // ... we must calculate our own potential energy "vertical speed"
  private var iPreviousEnergyGpoch as Number = -1;
  private var fPreviousEnergyTotal as Float = 0.0f;
  private var fPreviousEnergyCinetic as Float = 0.0f;
  // ... we must calculate our own rate of turn
  private var iPreviousHeadingGpoch as Number = -1;
  private var fPreviousHeading as Float = 0.0f;
  // ... we must estimate wind direction and speed (and estimate whether circling at the same time)
  private var aiAngle as Array<Number>;
  private var afSpeed as Array<Float>;
  private var fSpeed as Float = 0.0f;
  private var iAngle as Number = 0;
  private var iWindSectorCount as Number = 0;
  private var iWindOldSector as Number = 0;
  private var iWindSector as Number = 0;


  // Public objects
  // ... sensor values (fed by Toybox.Sensor)
  public var iSensorEpoch as Number = -1;
  // ... altimeter values (fed by Toybox.Activity, on Toybox.Sensor events)
  public var fAltitude as Float = NaN;
  public var fAltitude_filtered as Float = NaN;
  // ... altimeter calculated values
  public var fVariometer as Float = NaN;
  public var fVariometer_filtered as Float = NaN;
  // ... position values (fed by Toybox.Position)
  public var bPositionStateful as Boolean = false;
  public var iPositionEpoch as Number = -1;
  public var iPositionGpoch as Number = -1;
  public var iAccuracy as Number = Pos.QUALITY_NOT_AVAILABLE;
  public var oLocation as Pos.Location?;
  public var fGroundSpeed as Float = NaN;
  public var fGroundSpeed_filtered as Float = NaN;
  public var fHeading as Float = NaN;
  public var fHeading_filtered as Float = NaN;
  // ... position calculated values
  public var fEnergyTotal as Float = NaN;
  public var fEnergyCinetic as Float = NaN;
  // ... finesse
  public var bAscent as Boolean = true;
  public var fFinesse as Float = NaN;
  // ... wind
  public var fWindSpeed as Float = 0.0f;
  public var iWindDirection as Number = 0;
  public var bWindValid as Boolean = false;
  // ... circling
  public var bCirclingCount as Number = 0;
  public var bNotCirclingCount as Number = 0;
  public var bIsPreviousGeneral as Boolean = true;
  public var bAutoThermalTriggered as Boolean = false;
  // ... plot buffer (using integer-only operations!)
  public var iPlotIndex as Number = -1;
  public var aiPlotEpoch as Array<Number>;
  public var aiPlotLatitude as Array<Number>;
  public var aiPlotLongitude as Array<Number>;
  public var aiPlotVariometer as Array<Number>;


  //
  // FUNCTIONS: self
  //

  function initialize() {
    // Private objects
    // ... Wind sector and speed tracking
    aiAngle = new Array<Number>[self.DIRECTION_NUM_OF_SECTORS];
    for(var i=0; i<self.DIRECTION_NUM_OF_SECTORS; i++) { self.aiAngle[i] = 0; }
    afSpeed = new Array<Float>[self.DIRECTION_NUM_OF_SECTORS];
    for(var i=0; i<self.DIRECTION_NUM_OF_SECTORS; i++) { self.afSpeed[i] = 0.0f; }

    // Public objects
    // ... plot buffer
    aiPlotEpoch = new Array<Number>[self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotEpoch[i] = -1; }
    aiPlotLatitude = new Array<Number>[self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotLatitude[i] = 0; }
    aiPlotLongitude = new Array<Number>[self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotLongitude[i] = 0; }
    aiPlotVariometer = new Array<Number>[self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPlotVariometer[i] = 0; }
  }

  function resetSensorData() as Void {
    //Sys.println("DEBUG: MyProcessing.resetSensorData()");

    // Reset
    // ... we must calculate our own vertical speed
    self.iPreviousAltitudeEpoch = -1;
    self.fPreviousAltitude = 0.0f;
    // ... sensor values
    self.iSensorEpoch = -1;
    // ... altimeter values
    self.fAltitude = NaN;
    self.fAltitude_filtered = NaN;
    // ... altimeter calculated values
    if($.oMySettings.iVariometerMode == 0) {
      self.fVariometer = NaN;
      self.fVariometer_filtered = NaN;
      $.oMyFilter.resetFilter(MyFilter.VARIOMETER);
    }
    // ... filters
  }

  function resetPositionData() as Void {
    //Sys.println("DEBUG: MyProcessing.resetPositionData()");

    // Reset
    // ... we must calculate our own potential energy "vertical speed"
    self.iPreviousEnergyGpoch = -1;
    self.fPreviousEnergyTotal = 0.0f;
    self.fPreviousEnergyCinetic = 0.0f;
    // ... we must calculate our own rate of turn
    self.iPreviousHeadingGpoch = -1;
    self.fPreviousHeading = 0.0f;
    // ... position values
    self.bPositionStateful = false;
    self.iPositionEpoch = -1;
    self.iPositionGpoch = -1;
    self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
    self.oLocation = null;
    self.fGroundSpeed = NaN;
    self.fGroundSpeed_filtered = NaN;
    self.fHeading = NaN;
    self.fHeading_filtered = NaN;
    // ... position calculated values
    if($.oMySettings.iVariometerMode == 1) {
      self.fVariometer = NaN;
      self.fVariometer_filtered = NaN;
      $.oMyFilter.resetFilter(MyFilter.VARIOMETER);
    }
    self.fEnergyTotal = NaN;
    self.fEnergyCinetic = NaN;
    // ... finesse
    self.fFinesse = NaN;
    // ... filters
    $.oMyFilter.resetFilter(MyFilter.GROUNDSPEED);
    $.oMyFilter.resetFilter(MyFilter.HEADING_X);
    $.oMyFilter.resetFilter(MyFilter.HEADING_Y);
  }

  function importSettings() as Void {
    // Energy compensation
    self.fEnergyCineticLossFactor = 1.0f - $.oMySettings.fVariometerEnergyEfficiency;
  }

  function processSensorInfo(_oInfo as Sensor.Info, _iEpoch as Number) as Void {
    //Sys.println("DEBUG: MyProcessing.processSensorInfo()");

    // Process sensor data

    // ... acceleration
    // if(_oInfo has :accel and _oInfo.accel != null) {
    //  self.fAcceleration = Math.sqrt((_oInfo.accel as Array<Number>)[0]*(_oInfo.accel as Array<Number>)[0]
    //                                 + (_oInfo.accel as Array<Number>)[1]*(_oInfo.accel as Array<Number>)[1]
    //                                 + (_oInfo.accel as Array<Number>)[2]*(_oInfo.accel as Array<Number>)[2]).toFloat()/1000.0f;
    //  self.fAcceleration_filtered = $.oMyFilter.filterValue(MyFilter.ACCELERATION, self.fAcceleration);
      //Sys.println(format("DEBUG: (Sensor.Info) acceleration = $1$ ~ $2$", [self.fAcceleration, self.fAcceleration_filtered]));
    //}
    //else {
    //  Sys.println("WARNING: Sensor data have no acceleration information (:accel)");
    //}

    // ... altitude
    if(LangUtils.notNaN($.oMyAltimeter.fAltitudeActual)) {  // ... the closest to the device's raw barometric sensor value
      self.fAltitude = $.oMyAltimeter.fAltitudeActual;
      self.fAltitude_filtered = $.oMyAltimeter.fAltitudeActual_filtered;
    }
    //else {
    //  Sys.println("WARNING: Internal altimeter has no altitude available");
    //}

    // Kalman Filter initialize
    if(LangUtils.notNaN(self.fPreviousAltitude) && self.fPreviousAltitude != null && !$.oMyKalmanFilter.bFilterReady) {
      $.oMyKalmanFilter.init(self.fPreviousAltitude, 0, self.iPreviousAltitudeEpoch);
    }

    // ... variometer
    if($.oMySettings.iVariometerMode == 0 and LangUtils.notNaN(self.fAltitude)) {  // ... altimetric variometer
      if(self.iPreviousAltitudeEpoch >= 0 and _iEpoch-self.iPreviousAltitudeEpoch != 0) {
        self.fVariometer = (self.fAltitude-self.fPreviousAltitude) / (_iEpoch-self.iPreviousAltitudeEpoch);
        if($.oMyKalmanFilter.bFilterReady) {
          $.oMyKalmanFilter.update(fAltitude, 0, _iEpoch);
          self.fVariometer_filtered = $.oMyKalmanFilter.fVelocity;
        }
        
        //var fVariometer_sma = $.oMyFilter.filterValue(MyFilter.VARIOMETER, self.fVariometer);
        //Sys.println(format("DEBUG: (Calculated) altimetric variometer = $1$ ~ $2$ ~ $3$", [self.fVariometer, self.fVariometer_filtered, fVariometer_sma]));
      }
      self.iPreviousAltitudeEpoch = _iEpoch;
      self.fPreviousAltitude = self.fAltitude;
      self.iPreviousEnergyGpoch = -1;  // ... prevent artefact when switching variometer mode
    }

    // Done
    self.iSensorEpoch = _iEpoch;
  }

  function processPositionInfo(_oInfo as Pos.Info, _iEpoch as Number) as Void {
    //Sys.println("DEBUG: MyProcessing.processPositionInfo()");

    // Process position data
    var fValue;
    var bStateful = true;

    // ... accuracy
    if(_oInfo has :accuracy and _oInfo.accuracy != null) {
      self.iAccuracy = _oInfo.accuracy as Number;
      //Sys.println(format("DEBUG: (Position.Info) accuracy = $1$", [self.iAccuracy]));
    }
    else {
      //Sys.println("WARNING: Position data have no accuracy information (:accuracy)");
      self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
      return;
    }
    if(self.iAccuracy == Pos.QUALITY_NOT_AVAILABLE or (self.iAccuracy == Pos.QUALITY_LAST_KNOWN and self.iPositionEpoch < 0)) {
      //Sys.println("WARNING: Position accuracy is not good enough to continue or start processing");
      self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
      return;
    }

    // ... timestamp
    // WARNING: the value of the position (GPS) timestamp is NOT the UTC epoch but the GPS timestamp (NOT translated to the proper year quadrant... BUG?)
    //          https://en.wikipedia.org/wiki/Global_Positioning_System#Timekeeping
    if(_oInfo has :when and _oInfo.when != null) {
      self.iPositionGpoch = (_oInfo.when as Time.Moment).value();
      //DEVEL:self.iPositionGpoch = _iEpoch;  // SDK 3.0.x BUG!!! (:when remains constant)
      //Sys.println(format("DEBUG: (Position.Info) when = $1$", [self.self.iPositionGpoch]));
    }
    else {
      //Sys.println("WARNING: Position data have no timestamp information (:when)");
      self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
      return;
    }

    // ... position
    self.bPositionStateful = false;
    if(_oInfo has :position and _oInfo.position != null) {
      self.oLocation = _oInfo.position;
      //Sys.println(format("DEBUG: (Position.Info) position = $1$, $2$", [self.oLocation.toDegrees()[0], self.oLocation.toDegrees()[1]]));
    }
    //else {
    //  Sys.println("WARNING: Position data have no position information (:position)");
    //}
    if(self.oLocation == null) {
      bStateful = false;
    }

    // ... altitude
    if(LangUtils.isNaN(self.fAltitude)) {  // ... derived by internal altimeter on sensor events
      bStateful = false;
    }

    // ... ground speed
    if(_oInfo has :speed and _oInfo.speed != null) {
      self.fGroundSpeed = _oInfo.speed as Float;
      self.fGroundSpeed_filtered = $.oMyFilter.filterValue(MyFilter.GROUNDSPEED, self.fGroundSpeed);
      //Sys.println(format("DEBUG: (Position.Info) ground speed = $1$ ~ $2$", [self.fGroundSpeed, self.fGroundSpeed_filtered]));
    }
    //else {
    //  Sys.println("WARNING: Position data have no speed information (:speed)");
    //}
    if(LangUtils.isNaN(self.fGroundSpeed)) {
      bStateful = false;
    }

    // ... variometer
    if($.oMySettings.iVariometerMode == 1 and LangUtils.notNaN(self.fAltitude) and LangUtils.notNaN(self.fGroundSpeed)) {  // ... energetic variometer
      self.fEnergyCinetic = 0.5f*self.fGroundSpeed*self.fGroundSpeed;
      self.fEnergyTotal = self.fEnergyCinetic + 9.80665f*self.fAltitude;
      //Sys.println(format("DEBUG: (Calculated) total energy = $1$", [self.fEnergyTotal]));
      if(self.iPreviousEnergyGpoch >= 0 and self.iPositionGpoch-self.iPreviousEnergyGpoch != 0) {
        self.fVariometer =
          (self.fEnergyTotal
           - self.fPreviousEnergyTotal
           - self.fEnergyCineticLossFactor*(self.fEnergyCinetic-self.fPreviousEnergyCinetic))
          / (self.iPositionGpoch-self.iPreviousEnergyGpoch) * 0.1019716213f;  // ... 1.0f / 9.80665f = 1.019716213f
        self.fVariometer_filtered = $.oMyFilter.filterValue(MyFilter.VARIOMETER, self.fVariometer);
        //Sys.println(format("DEBUG: (Calculated) energetic variometer = $1$ ~ $2$", [self.fVariometer, self.fVariometer_filtered]));
      }
      self.iPreviousEnergyGpoch = self.iPositionGpoch;
      self.fPreviousEnergyTotal = self.fEnergyTotal;
      self.fPreviousEnergyCinetic = self.fEnergyCinetic;
      self.iPreviousAltitudeEpoch = -1;  // ... prevent artefact when switching variometer mode
    }
    if(LangUtils.isNaN(self.fVariometer)) {
      bStateful = false;
    }

    // ... heading
    // NOTE: we consider heading meaningful only if ground speed is above 1.0 m/s
    if(self.fGroundSpeed >= 1.0f and _oInfo has :heading and _oInfo.heading != null) {
      fValue = _oInfo.heading as Float;
      if(fValue < 0.0f) {
        fValue += 6.28318530718f;
      }
      self.fHeading = fValue;
      fValue = $.oMyFilter.filterValue(MyFilter.HEADING_X, Math.cos(self.fHeading).toFloat());
      fValue = Math.atan2($.oMyFilter.filterValue(MyFilter.HEADING_Y, Math.sin(self.fHeading).toFloat()), fValue).toFloat();
      if(fValue < 0.0f) {
        fValue += 6.28318530718f;
      }
      self.fHeading_filtered = fValue;
    }
    else {
      //Sys.println("WARNING: Position data have no (meaningful) heading information (:heading)"); 
      self.fHeading = NaN;
      self.fHeading_filtered = NaN;
    }
    if(LangUtils.notNaN(self.fHeading)) {
      //Sys.println(format("DEBUG: (Position.Info) heading = $1$ ~ $2$", [self.fHeading, self.fHeading_filtered]));

      self.iPreviousHeadingGpoch = self.iPositionGpoch;
      self.fPreviousHeading = self.fHeading;
    }
    else {
      //Sys.println("WARNING: No heading available");
      self.iPreviousHeadingGpoch = -1;
    }
    // NOTE: heading and rate-of-turn data are not required for processing finalization

    // Finalize
    if(bStateful) {
      self.bPositionStateful = true;
      if(self.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
        self.iPositionEpoch = _iEpoch;

        // Plot buffer
        self.iPlotIndex = (self.iPlotIndex+1) % self.PLOTBUFFER_SIZE;
        self.aiPlotEpoch[self.iPlotIndex] = self.iPositionEpoch;
        // ... location as (integer) milliseconds of arc
        var adPositionDegrees = (self.oLocation as Pos.Location).toDegrees();
        self.aiPlotLatitude[self.iPlotIndex] = (adPositionDegrees[0]*3600000.0f).toNumber();
        self.aiPlotLongitude[self.iPlotIndex] = (adPositionDegrees[1]*3600000.0f).toNumber();
        // ... vertical speed as (integer) millimeter-per-second
        self.aiPlotVariometer[self.iPlotIndex] = (self.fVariometer*1000.0f).toNumber();
      }
    }

    // ... finesse
    self.processFinesse();
    
    // ... wind
    self.windStep();
    
    // ... circling Auto Switch
    if($.oMySettings.bVariometerAutoThermal && !self.bAutoThermalTriggered && self.bCirclingCount >=10) {
      self.bAutoThermalTriggered = true;
      Ui.switchToView(new MyViewVarioplot(),
                new MyViewVarioplotDelegate(),
                Ui.SLIDE_IMMEDIATE);
    }
    if($.oMySettings.bVariometerAutoThermal && self.bAutoThermalTriggered && self.bNotCirclingCount >=25) {
      self.bAutoThermalTriggered = false;
      if(self.bIsPreviousGeneral) {
        Ui.switchToView(new MyViewGeneral(),
                  new MyViewGeneralDelegate(),
                  Ui.SLIDE_IMMEDIATE);
      } else {
        Ui.switchToView(new MyViewVariometer(),
                      new MyViewVariometerDelegate(),
                      Ui.SLIDE_IMMEDIATE);
      }
    }
  }

  function processFinesse() as Void {
    self.fFinesse = NaN;
    self.bAscent = true;
    // Ascent/finesse

    // ... ascending ?
    if(self.fVariometer_filtered >= -0.005f * self.fGroundSpeed_filtered) {  // climbing (quite... finesse >= 200)
      self.bAscent = true;
    }
    else {  // descending (really!)
      self.bAscent = false;
    }
    //Sys.println(format("DEBUG: (Calculated) ascent = $1$", [self.bAscent]));

    // ... finesse
    if(LangUtils.notNaN(self.fGroundSpeed_filtered) && LangUtils.notNaN(self.fVariometer_filtered) && self.fVariometer_filtered != null && self.fHeading_filtered != null && self.fVariometer_filtered != 0){
      self.fFinesse = - self.fGroundSpeed_filtered / self.fVariometer_filtered;
      //Sys.println(format("DEBUG: (Calculated) average finesse ~ $1$", [self.fFinesse]));
    }
  }

  function convertDirection(_fValue as Number) as String {
    if(_fValue<0) {
      _fValue = 0;
    }
    else if(_fValue>360) {
      _fValue = 360;
    }
    var iSector = (_fValue + (360 / self.DIRECTION_NUM_OF_SECTORS / 2)) % 360 / (360 / self.DIRECTION_NUM_OF_SECTORS);
    switch(iSector) {
      case 0: return "N";
      case 1: return "NE";
      case 2: return "E";
      case 3: return "SE";
      case 4: return "S";
      case 5: return "SW";
      case 6: return "W";
      case 7: return "NW";
      default: return "N";
    }
  }

  function windStep() as Void {
    if($.oMySettings.iGeneralDisplayFilter >= 1 && LangUtils.notNaN(self.fHeading_filtered) && LangUtils.notNaN(self.fGroundSpeed_filtered) && self.fHeading_filtered != null && self.fGroundSpeed_filtered !=null) {
      self.iAngle = ((self.fHeading_filtered * 57.2957795131f).toNumber()) % 360;
      self.fSpeed = self.fGroundSpeed_filtered;
    }
    else if($.oMySettings.iGeneralDisplayFilter < 1 && LangUtils.notNaN(self.fHeading) && LangUtils.notNaN(self.fGroundSpeed) && self.fHeading != null && self.fGroundSpeed != null) {
      self.iAngle = ((self.fHeading * 57.2957795131f).toNumber()) % 360;
      self.fSpeed = self.fGroundSpeed;      
    } else {
      return;
    }

    self.iWindSector = (self.iAngle + (360 / self.DIRECTION_NUM_OF_SECTORS / 2)) % 360 / (360 / self.DIRECTION_NUM_OF_SECTORS);
    self.aiAngle[self.iWindSector] = self.iAngle;
    self.afSpeed[self.iWindSector] = self.fSpeed;
    if(self.iWindSector == (self.iWindOldSector + 1) % self.DIRECTION_NUM_OF_SECTORS) {
      //Clockwise move
      if(self.iWindSectorCount >= 0) {
        self.iWindSectorCount += 1;
      }
      else {
        self.iWindSectorCount = 0;
      }
    }
    else {
      if(self.iWindOldSector == (self.iWindSector +1) % self.DIRECTION_NUM_OF_SECTORS) {
        //Counterclockwise move
        if(self.iWindSectorCount <= 0) {
          self.iWindSectorCount -= 1;
        }
        else {
          self.iWindSectorCount = 0;
        }
      }
      else {
        if(self.iWindOldSector == self.iWindSector) {
          //Same sector
          self.bNotCirclingCount += 1;
        }
        else {
          //More than 360/num of sectors, discard data
          self.iWindSectorCount = 0;
        }
      }
    }
    self.iWindOldSector = self.iWindSector;

    var iMin as Number = 0;
    var iMax as Number = 0;
    // Sys.println(format("DEBUG: Number of wind sectors ~ $1$", [self.iWindSectorCount]));
    if(self.iWindSectorCount.abs() >= self.DIRECTION_NUM_OF_SECTORS) {
      if(self.bCirclingCount >= 10) { self.bNotCirclingCount = 0; } //Definitely circling
      self.bCirclingCount += 1;
      for(var i = 1; i < self.DIRECTION_NUM_OF_SECTORS; i++) {
        if(self.afSpeed[i] > self.afSpeed[iMax]) { iMax = i; }
        if(self.afSpeed[i] < self.afSpeed[iMin]) { iMin = i; }
      }

      var iSectorDiff as Number = (iMax - iMin).abs();
      if((iSectorDiff >= ( self.DIRECTION_NUM_OF_SECTORS / 2 - 1)) and (iSectorDiff <= ( self.DIRECTION_NUM_OF_SECTORS / 2 + 1))) {
        self.fWindSpeed = (self.afSpeed[iMax] - self.afSpeed[iMin]) / 2;
        self.iWindDirection = self.aiAngle[iMin];
        self.bWindValid = true;
      }
    }
    else {
      if(self.bNotCirclingCount >= 25) { self.bCirclingCount = 0; } //No longer circling
      bNotCirclingCount += 1;
    }
  }

}
