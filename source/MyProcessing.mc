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
  public const PLOTBUFFER_SIZE = 180;  // 3 minutes = 180 seconds
  // Wind estimation sectors
  public const DIRECTION_NUM_OF_SECTORS = 8;

  //
  // VARIABLES
  //

  // Internal calculation objects
  // ... we must calculate our own vertical speed
  private var iPreviousAltitudeEpoch as Number = -1;
  private var fPreviousAltitude as Float = 0.0f;
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
  // ... altimeter calculated values
  public var fVariometer as Float = NaN;
  public var fVariometer_filtered as Float = NaN;
  // ... position values (fed by Toybox.Position)
  public var bPositionStateful as Boolean = false;
  public var iPositionEpoch as Number = -1;
  public var iAccuracy as Number = Pos.QUALITY_NOT_AVAILABLE;
  public var oLocation as Pos.Location?;
  public var fGroundSpeed as Float = NaN;
  public var fHeading as Float = NaN;
  public var iGpsTime as Number = NaN;
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
  // Thermal core calculation
  public var iCenterLongitude as Number = 0;
  public var iCenterLatitude as Number = 0;
  public var fCenterWindOffsetLongitude as Number = 0;
  public var fCenterWindOffsetLatitude as Number = 0;
  public var iStandardDev as Number = 0;
  public var aiPointAltitude as Array<Number>;


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
    aiPointAltitude = new Array<Number>[self.PLOTBUFFER_SIZE];
    for(var i=0; i<self.PLOTBUFFER_SIZE; i++) { self.aiPointAltitude[i] = 0; }
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
    // ... altimeter calculated values
    self.fVariometer = NaN;
    self.fVariometer_filtered = NaN;
    // ... filters
  }

  function resetPositionData() as Void {
    //Sys.println("DEBUG: MyProcessing.resetPositionData()");

    // Reset
    // ... position values
    self.bPositionStateful = false;
    self.iPositionEpoch = -1;
    self.iAccuracy = Pos.QUALITY_NOT_AVAILABLE;
    self.oLocation = null;
    self.fGroundSpeed = NaN;
    self.fHeading = NaN;

    // ... finesse
    self.fFinesse = NaN;
    // ... filters
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
    }
    //else {
    //  Sys.println("WARNING: Internal altimeter has no altitude available");
    //}

    // Kalman Filter initialize
    if(LangUtils.notNaN(self.fPreviousAltitude) && self.fPreviousAltitude != null && !$.oMyKalmanFilter.bFilterReady) {
      $.oMyKalmanFilter.init(self.fPreviousAltitude, 0, self.iPreviousAltitudeEpoch);
    }

    // ... variometer
    if(LangUtils.notNaN(self.fAltitude)) {  // ... altimetric variometer
      if(self.iPreviousAltitudeEpoch >= 0 and _iEpoch-self.iPreviousAltitudeEpoch != 0) {
        self.fVariometer = (self.fAltitude-self.fPreviousAltitude) / (_iEpoch-self.iPreviousAltitudeEpoch);
        if($.oMyKalmanFilter.bFilterReady) {
          $.oMyKalmanFilter.update(fAltitude, 0, _iEpoch);
          self.fVariometer_filtered = $.oMyKalmanFilter.fVelocity;
          self.fAltitude = $.oMyKalmanFilter.fPosition;
        //  Sys.println(format("DEBUG: (Calculated) altimetric variometer = $1$ ~ $2$", [self.fAltitude, $.oMyKalmanFilter.fPosition]));
        }

        //Sys.println(format("DEBUG: (Calculated) altimetric variometer = $1$ ~ $2$ ~ $3$", [self.fVariometer, self.fVariometer_filtered]));
        
      }
      self.iPreviousAltitudeEpoch = _iEpoch;
      self.fPreviousAltitude = self.fAltitude;
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
      self.iGpsTime = _oInfo.when.value();
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
      //Sys.println(format("DEBUG: (Position.Info) ground speed = $1$", [self.fGroundSpeed]));
    }
    //else {
    //  Sys.println("WARNING: Position data have no speed information (:speed)");
    //}
    if(LangUtils.isNaN(self.fGroundSpeed)) {
      bStateful = false;
    }

    // ... variometer

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
    }
    else {
      //Sys.println("WARNING: Position data have no (meaningful) heading information (:heading)"); 
      self.fHeading = NaN;
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
        self.aiPlotVariometer[self.iPlotIndex] = (self.fVariometer_filtered*1000.0f).toNumber();
        self.aiPointAltitude[self.iPlotIndex] = self.fAltitude.toNumber();

        //Livetracking
        if ($.oMyActivity != null && $.oMySettings.iLivetrackFrequencySeconds != 0) {
          //Attempt to get User Id and generate Session ID if not existent
          if($.oMyLivetrack.sLoginName.length() > 0 && $.oMyLivetrack.iUserId == 0 && $.oMyLivetrack.iSessionId == 1 && !$.oMyLivetrack.bWebRequestPending && !$.oMyLivetrack.bWrongCredentials) {
            $.oMyLivetrack.getUserId();
          }

          //Attempt to start the livetrack session
          if($.oMyLivetrack.iSessionId != 1 && !$.oMyLivetrack.bWebRequestPending && !$.oMyLivetrack.bWrongCredentials && !$.oMyLivetrack.bLivetrackStateful) {
            $.oMyLivetrack.startSession();
          }

          //Attempt to update position
          if($.oMyLivetrack.bLivetrackStateful && ($.oMyLivetrack.iCounter % $.oMySettings.iLivetrackFrequencySeconds) == 0) {
            var iLivetrackHeading = LangUtils.notNaN(fHeading) ? ((self.fHeading * 57.2957795131f).toNumber()) % 360 : 0;
            $.oMyLivetrack.updateSession(adPositionDegrees[0], adPositionDegrees[1], self.fAltitude.toNumber(), (self.fGroundSpeed * 3.6f).toNumber(), iLivetrackHeading, self.iGpsTime);
          }
          $.oMyLivetrack.iCounter++;
        }

        if($.oMySettings.bVariometerThermalDetect) {
          // Thermal core detector
          var iWeightedSum= 0 as Number;
          var fWeightedSumLongitude = 0.0f as Float;
          var fWeightedSumLatitude = 0.0f as Float;
          var fWeightedMeanLongitude = 0.0f as Float;
          var fWeightedMeanLongitudeOld = 0.0f as Float;
          var fWeightedSLongitude = 0.0f as Float;
          var fWeightedMeanLatitude = 0.0f as Float;
          var fWeightedMeanLatitudeOld = 0.0f as Float;
          var fWeightedSLatitude = 0.0f as Float;
          var fWeightedSumAltitude = 0.0f as Float;
          var fWeightedMeanAltitude = 0.0f as Float;
          var fWeightedMeanAltitudeOld = 0.0f as Float;
          var fWeightedSumClimb = 0.0f as Float;
          var fWeightedMeanClimb = 0.0f as Float;
          var fWeightedMeanClimbOld = 0.0f as Float;

          // Thermal detector uses 1 minute of data
          for(var i = 0; i<60; i++){
            var index = (self.iPlotIndex - i) >= 0 ? (self.iPlotIndex - i) : self.PLOTBUFFER_SIZE + (self.iPlotIndex - i);
            if(aiPlotLatitude[index] != 0 && aiPlotLongitude[index] != 0 && self.aiPlotVariometer[index] > $.oMySettings.fMinimumClimb * 1000.0f) {
              // Point weight is relative to climb rate
              var weight = self.aiPlotVariometer[index];
              // Point weight decreases as measurement altitude is farther from current altitude
              weight -= ((self.fAltitude.toNumber() - self.aiPointAltitude[index]) * 40).abs();
              // Point weight decreases with age of point
              weight -= i * 20;
              weight = (weight < 0) ? 0 : weight;
              // One pass weighted mean and weighted variance calculation
              iWeightedSum += weight;
              fWeightedMeanLongitudeOld = fWeightedMeanLongitude;
              fWeightedMeanLatitudeOld = fWeightedMeanLatitude;
              fWeightedMeanAltitudeOld = fWeightedMeanAltitude;
              fWeightedMeanClimbOld = fWeightedMeanClimb;
              if(iWeightedSum != 0) {
                fWeightedMeanLongitude = fWeightedMeanLongitudeOld + (weight.toFloat() / iWeightedSum.toFloat()) * (self.aiPlotLongitude[index].toFloat() - fWeightedMeanLongitudeOld);
                fWeightedMeanLatitude = fWeightedMeanLatitudeOld + (weight.toFloat() / iWeightedSum.toFloat()) * (self.aiPlotLatitude[index].toFloat() - fWeightedMeanLatitudeOld);
                fWeightedMeanAltitude = fWeightedMeanAltitudeOld + (weight.toFloat() / iWeightedSum.toFloat()) * (self.aiPointAltitude[index].toFloat() - fWeightedMeanAltitudeOld);
                fWeightedMeanClimb = fWeightedMeanClimbOld + (weight.toFloat() / iWeightedSum.toFloat()) * (self.aiPlotVariometer[index].toFloat() - fWeightedMeanClimbOld);
              }
              else {
                fWeightedMeanLongitude = fWeightedMeanLongitudeOld;
                fWeightedMeanLatitude = fWeightedMeanLatitudeOld;
                fWeightedMeanAltitude = fWeightedMeanAltitudeOld;
                fWeightedMeanClimb = fWeightedMeanClimbOld;
              }
              fWeightedSLongitude += weight * (self.aiPlotLongitude[index] - fWeightedMeanLongitudeOld) * (self.aiPlotLongitude[index] - fWeightedMeanLongitude);
              fWeightedSLatitude += weight * (self.aiPlotLatitude[index] - fWeightedMeanLatitudeOld) * (self.aiPlotLatitude[index] - fWeightedMeanLatitude);
            }
            
          }
          if(iWeightedSum != 1) {
            self.iCenterLongitude = fWeightedMeanLongitude.toNumber();
            self.iCenterLatitude = fWeightedMeanLatitude.toNumber();
            self.iStandardDev = Math.sqrt((fWeightedSLongitude + fWeightedSLatitude) / (2 * iWeightedSum - 2)).toNumber();
            if(self.bWindValid && self.fWindSpeed > 0 && self.iWindDirection != null && fWeightedMeanAltitude != 0 && fWeightedMeanClimb != 0 && self.fAltitude != 0) {
              var fThermalDrift =  (self.fAltitude - fWeightedMeanAltitude) * (self.fWindSpeed / (fWeightedMeanClimb / 1000.0)); // thermal drift in meters (positive with wind, negative against wind)
              var iDriftAngle = fThermalDrift >= 0 ? 90 - ((self.iWindDirection + 180) % 360) : (90 - self.iWindDirection); //push away from wind origin if drift positive, towards it if negative. Redirect angle so sin/cos operations can be used for lat/long
              self.fCenterWindOffsetLatitude = fThermalDrift.abs() * Math.sin( iDriftAngle / 57.2957795131f); //North-South drift in meters (North positive)
              self.fCenterWindOffsetLongitude = fThermalDrift.abs() * Math.cos( iDriftAngle / 57.2957795131f); //West-East drift in meters (East positive)
            }
          }
        }
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
    if(self.fVariometer_filtered >= -0.005f * self.fGroundSpeed) {  // climbing (quite... finesse >= 200)
      self.bAscent = true;
    }
    else {  // descending (really!)
      self.bAscent = false;
    }
    //Sys.println(format("DEBUG: (Calculated) ascent = $1$", [self.bAscent]));

    // ... finesse
    if(LangUtils.notNaN(self.fGroundSpeed) && LangUtils.notNaN(self.fVariometer_filtered) && self.fVariometer_filtered != null && self.fVariometer_filtered != 0){
      self.fFinesse = - self.fGroundSpeed / self.fVariometer_filtered;
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
    if(LangUtils.notNaN(self.fHeading) && LangUtils.notNaN(self.fGroundSpeed) && self.fHeading != null && self.fGroundSpeed != null) {
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
      if(self.bNotCirclingCount >= 10) { self.bCirclingCount = 0; } //No longer circling
      bNotCirclingCount += 1;
    }
  }

}
