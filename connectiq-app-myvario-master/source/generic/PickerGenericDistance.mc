// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// Generic ConnectIQ Helpers/Resources (CIQ Helpers)
// Copyright (C) 2017-2022 Cedric Dufour <http://cedric.dufour.name>
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is free software:
// you can redistribute it and/or modify it under the terms of the GNU General
// Public License as published by the Free Software Foundation, Version 3.
//
// Generic ConnectIQ Helpers/Resources (CIQ Helpers) is distributed in the hope
// that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//
// See the GNU General Public License for more details.
//
// SPDX-License-Identifier: GPL-3.0
// License-Filename: LICENSE/GPL-3.0.txt

import Toybox.Lang;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class PickerGenericDistance extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_sTitle as String, _fValue as Float?, _iUnit as Number?, _bAllowNegative as Boolean) {
    // Input validation
    // ... unit
    var iUnit = _iUnit != null ? _iUnit : -1;
    if(iUnit < 0 or iUnit > 2) {
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :distanceUnits and oDeviceSettings.distanceUnits != null) {
        iUnit = oDeviceSettings.distanceUnits;
      }
      else {
        iUnit = Sys.UNIT_METRIC;
      }
    }
    // ... value
    var fValue = (_fValue != null and LangUtils.notNaN(_fValue)) ? _fValue : 0.0f;

    // Use user-specified distance unit (NB: SI units are always used internally)
    // PRECISION: 0.1 (* 10)
    var sUnit = "km";
    var iMaxSignificant = 99;
    if(iUnit == 2) {
      sUnit = "nm";
      iMaxSignificant = 53;
      fValue /= 185.2f;  // m -> nm (* 10)
      if(fValue > 539999.0f) {
        fValue = 539999.0f;
      }
      else if(fValue < -539999.0f) {
        fValue = -539999.0f;
      }
    }
    else if(iUnit == Sys.UNIT_STATUTE) {
      sUnit = "sm";
      iMaxSignificant = 61;
      fValue /= 160.9344f;  // m -> sm (* 10)
      if(fValue > 619999.0f) {
        fValue = 619999.0f;
      }
      else if(fValue < -619999.0f) {
        fValue = -619999.0f;
      }
    }
    else {
      fValue /= 100.0f;  // m -> km (* 10)
      if(fValue > 999999.0f) {
        fValue = 999999.0f;
      }
      else if(fValue < -999999.0f) {
        fValue = -999999.0f;
      }
    }
    if(!_bAllowNegative and fValue < 0.0f) {
      fValue = 0.0f;
    }

    // Split components
    var aiValues = new Array<Number>[6];
    aiValues[0] = fValue < 0.0f ? 0 : 1;
    fValue = fValue.abs() + 0.05f;
    aiValues[5] = fValue.toNumber() % 10;
    fValue = fValue / 10.0f;
    aiValues[4] = fValue.toNumber() % 10;
    fValue = fValue / 10.0f;
    aiValues[3] = fValue.toNumber() % 10;
    fValue = fValue / 10.0f;
    aiValues[2] = fValue.toNumber() % 10;
    fValue = fValue / 10.0f;
    aiValues[1] = fValue.toNumber();

    // Initialize picker
    Picker.initialize({
        :title => new Ui.Text({
            :text => format("$1$ [$2$]", [_sTitle, sUnit]),
            :font => Gfx.FONT_TINY,
            :locX => Ui.LAYOUT_HALIGN_CENTER,
            :locY => Ui.LAYOUT_VALIGN_BOTTOM,
            :color => Gfx.COLOR_BLUE}),
        :pattern => [_bAllowNegative ? new PickerFactoryDictionary([-1, 1], ["-", "+"], null) : new Ui.Text({}),
                     new PickerFactoryNumber(0, iMaxSignificant, {:langFormat => "$1$'"}),
                     new PickerFactoryNumber(0, 9, null),
                     new PickerFactoryNumber(0, 9, null),
                     new PickerFactoryNumber(0, 9, {:langFormat => "$1$."}),
                     new PickerFactoryNumber(0, 9, null)],
        :defaults => aiValues});
  }


  //
  // FUNCTIONS: self
  //

  function getValue(_amValues as Array, _iUnit as Number?) as Float {
    // Input validation
    // ... unit
    var iUnit = _iUnit != null ? _iUnit : -1;
    if(iUnit < 0 or iUnit > 2) {
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :distanceUnits and oDeviceSettings.distanceUnits != null) {
        iUnit = oDeviceSettings.distanceUnits;
      }
      else {
        iUnit = Sys.UNIT_METRIC;
      }
    }

    // Assemble components
    var fValue = _amValues[1]*10000.0f + _amValues[2]*1000.0f + _amValues[3]*100.0f + _amValues[4]*10.0f + _amValues[5];
    if(_amValues[0] != null) {
      fValue *= _amValues[0];
    }

    // Use user-specified distance unit (NB: SI units are always used internally)
    if(iUnit == 2) {
      fValue *= 185.2f;  // nm (* 10) -> m
    }
    else if(iUnit == Sys.UNIT_STATUTE) {
      fValue *= 160.9344f;  // sm (* 10) -> m
    }
    else {
      fValue *= 100.0f;  // km (* 10) -> m
    }

    // Return value
    return fValue;
  }
}
