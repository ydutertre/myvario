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
// This Kalman filter is based on the implementation for Arduino Variometer
// by Baptiste PELLEGRIN
// https://github.com/prunkdump/arduino-variometer/blob/master/libraries/kalmanvert/kalmanvert.cpp

import Toybox.Lang;
using Toybox.Math;
using Toybox.System as Sys;

//
// CLASS
//

class MyKalmanFilter {

  //
  // CONSTANTS
  //

  private const ACCELERATION_VARIANCE = 0.36; //Value 0.36 taken from Arduino-vario, when no accelerometer present (as of now, because gyro data isn't accessible, the watch accelerometer can't be used)
  

  //
  // VARIABLES
  //

  // Covariance matrix (as floats)
  private var p11 as Float = 0;
  private var p12 as Float = 0;
  private var p21 as Float = 0;
  private var p22 as Float = 0;

  // Position, velocity, acceleration, timestamp
  public var fPosition as Float = 0;
  public var fVelocity as Float = 0;
  public var fAcceleration as Float = 0;
  public var fTimestamp as Float = 0;

  // Filter ready?
  public var bFilterReady as Boolean = false;

  //
  // FUNCTIONS: self
  //

  function init(_fStartP as Float, _fStartA as Float, _fTimestamp as Number) as Void {
    self.fPosition = _fStartP;
    self.fVelocity = 0;
    self.fAcceleration = _fStartA;
    self.fTimestamp = _fTimestamp;

    self.p11 = 0;
    self.p12 = 0;
    self.p21 = 0;
    self.p22 = 0;

    self.bFilterReady = true;
  }

  function update(_fPosition as Float, _fAcceleration as Float, _fTimestamp as Number) as Void {
    
    // Delta time
    var deltaTime = _fTimestamp - fTimestamp;
    var dt = deltaTime.toFloat();
    self.fTimestamp = _fTimestamp;

    // Variance
    var fAltitudeVariance = $.oMySettings.fVariometerSmoothing * $.oMySettings.fVariometerSmoothing;

    //Prediction

    //values
    self.fAcceleration = _fAcceleration;
    var dtPower = dt * dt;
    self.fPosition += dt * self.fVelocity + dtPower * self.fAcceleration/2;
    self.fVelocity += dt * self.fAcceleration;

    //covariance
    var inc;
    dtPower *= dt;
    inc = dt * self.p22 + dtPower * self.ACCELERATION_VARIANCE/2;
    dtPower *= dt;
    self.p11 += dt * (self.p12 + self.p21 + inc) - (dtPower * self.ACCELERATION_VARIANCE/4);
    self.p21 += inc;
    self.p12 += inc;
    self.p22 += dt * dt * self.ACCELERATION_VARIANCE;

    //Gaussian Product

    //kalman gain
    var s = self.p11 + fAltitudeVariance;
    var k11 = self.p11 / s;
    var k12 = self.p12 / s;
    var y = _fPosition - self.fPosition;

    //update
    self.fPosition += k11 * y;
    self.fVelocity += k12 * y;
    self.p22 -= k12 * self.p21;
    self.p12 -= k12 * self.p11;
    self.p21 -= k11 * self.p21;
    self.p11 -= k11 * self.p11;
  }
}
