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

// We use Simple Moving Average (SMA) to smoothen the sensor values over
// the user-specified "time constant" or time period.

class MyKalmanFilter {

  //
  // CONSTANTS
  //

  private const ALTITUDE_VARIANCE = 0.0225; //Setting standard deviation to 0.15m
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
    fPosition = _fStartP;
    fVelocity = 0;
    fAcceleration = _fStartA;
    fTimestamp = _fTimestamp;

    p11 = 0;
    p12 = 0;
    p21 = 0;
    p22 = 0;

    bFilterReady = true;
  }

  function update(_fPosition as Float, _fAcceleration as Float, _fTimestamp as Number) as Void {
    
    // Delta time
    var deltaTime as Number = _fTimestamp - fTimestamp;
    var dt as Float = deltaTime.toFloat();
    fTimestamp = _fTimestamp;

    //Prediction

    //values
    fAcceleration = _fAcceleration;
    var dtPower as Float = dt * dt;
    fPosition += dt * fVelocity + dtPower * fAcceleration/2;
    fVelocity += dt * fAcceleration;

    //covariance
    var inc as Float;
    dtPower *= dt;
    inc = dt * p22 + dtPower * ACCELERATION_VARIANCE/2;
    dtPower *= dt;
    p11 += dt * (p12 + p21 + inc) - (dtPower * ACCELERATION_VARIANCE/4);
    p21 += inc;
    p12 += inc;
    p22 += dt * dt * ACCELERATION_VARIANCE;

    //Gaussian Product

    //kalman gain
    var s as Float = p11 + ALTITUDE_VARIANCE;
    var k11 as Float = p11 / s;
    var k12 as Float = p12 / s;
    var y as Float = _fPosition - fPosition;

    //update
    fPosition += k11 * y;
    fVelocity += k12 * y;
    p22 -= k12 * p21;
    p12 -= k12 * p11;
    p21 -= k11 * p21;
    p11 -= k11 * p11;
  }
}
