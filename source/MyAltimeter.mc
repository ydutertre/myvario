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
using Toybox.Math;
using Toybox.System as Sys;

// REFERENCES:
//   https://store.icao.int/manual-on-automatic-meteorological-observing-systems-at-aerodromes-2011-doc-9837-english-printed.html ($$$)
//   https://www.wmo.int/pages/prog/www/IMOP/meetings/SI/ET-Stand-1/Doc-10_Pressure-red.pdf

//
// CLASS
//

class MyAltimeter {

  //
  // CONSTANTS
  //

  // International Standard Atmosphere (ISA)
  public const ISA_PRESSURE_MSL = 101325.0f;  // [Pa] aka. QNE
  public const ISA_TEMPERATURE_MSL = 288.15f;  // [°K]
  public const ISA_TEMPERATURE_LRATE = -0.0065f;  // [°K/m]

  // International Civil Aviation Organization (OACI)
  public const ICAO_ALTITUDE_K1 = 44330.77f;
  public const ICAO_ALTITUDE_K2 = -11880.32f;
  public const ICAO_ALTITUDE_EXP = 0.190263f;
  public const ICAO_PRESSURE_EXP = 5.25588f;


  //
  // VARIABLES
  //

  // Pressure
  public var fQNH as Float = 101325.0f;  // [Pa]
  public var fQFE_raw as Float = NaN;  // [Pa]
  public var fQFE as Float = NaN;  // [Pa]

  // Altitude
  public var fAltitudeISA as Float = NaN;  // [m]
  public var fAltitudeActual as Float = NaN;  // [m]


  //
  // FUNCTIONS: self
  //

  function reset() as Void {
    // Pressure
    self.fQFE_raw = NaN;
    self.fQFE = NaN;

    // Altitude
    self.fAltitudeISA = NaN;
    self.fAltitudeActual = NaN;

    // Filter
  }

  function importSettings() as Void {
    // QNH
    self.fQNH = $.oMySettings.fAltimeterCalibrationQNH;
  }

  function setQFE(_fQFE as Float) as Void {  // [Pa]
    // Raw sensor value
    self.fQFE_raw = _fQFE;
    //Sys.println(format("DEBUG: QFE (raw) = $1$", [self.fQFE_raw]));

    // Calibrated value
    self.fQFE = self.fQFE_raw * $.oMySettings.fAltimeterCorrectionRelative + $.oMySettings.fAltimeterCorrectionAbsolute;
    //Sys.println(format("DEBUG: QFE (calibrated) = $1$", [self.fQFE]));

    // Derive altitudes (ICAO formula)
    // ... ISA (QNH=QNE)
    self.fAltitudeISA = self.ICAO_ALTITUDE_K1 + self.ICAO_ALTITUDE_K2 * Math.pow(self.fQFE/100.0f, self.ICAO_ALTITUDE_EXP).toFloat();
    //Sys.println(format("DEBUG: Altitude (ISA) = $1$", [self.fAltitudeISA]));
    // ... actual
    self.fAltitudeActual = self.fAltitudeISA - (Math.pow(self.fQNH/self.ISA_PRESSURE_MSL, self.ICAO_ALTITUDE_EXP).toFloat() - 1.0f)*self.ISA_TEMPERATURE_MSL/self.ISA_TEMPERATURE_LRATE;
    //Sys.println(format("DEBUG: Altitude (actual) = $1$ ~ $2$", [self.fAltitudeActual, self.fAltitudeActual_filtered]));
  }

  function setQNH(_fQNH as Float) as Void {  // [Pa]
    // QNH
    if(_fQNH == self.fQNH) {
      return;
    }
    self.fQNH = _fQNH;

    // ISA altitude (<-> QFE) available ?
    if(LangUtils.notNaN(self.fAltitudeISA)) {
      // Derive altitude (ICAO formula)
      // ... actual
      self.fAltitudeActual = self.fAltitudeISA - (Math.pow(self.fQNH/self.ISA_PRESSURE_MSL, self.ICAO_ALTITUDE_EXP).toFloat() - 1.0f)*self.ISA_TEMPERATURE_MSL/self.ISA_TEMPERATURE_LRATE;
      //Sys.println(format("DEBUG: Altitude (actual) = $1$ ~ $2$", [self.fAltitudeActual, self.fAltitudeActual_filtered]));
    }
  }

  function setAltitudeActual(_fAltitudeActual as Float) as Void {  // [m]
    // ISA altitude (<-> QFE) available ?
    if(LangUtils.notNaN(self.fAltitudeISA)) {
      // Derive QNH (ICAO formula)
      var fQNH_new = self.ISA_PRESSURE_MSL * Math.pow(1.0f + self.ISA_TEMPERATURE_LRATE*(self.fAltitudeISA-_fAltitudeActual)/self.ISA_TEMPERATURE_MSL, self.ICAO_PRESSURE_EXP).toFloat();
      //Sys.println(format("DEBUG: QNH = $1$", [fQNH_new]));

      // Save QNH
      self.setQNH(fQNH_new);
    }
  }

}
