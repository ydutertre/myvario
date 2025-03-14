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
using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class MyPickerGenericPressure extends PickerGenericPressure {

  //
  // FUNCTIONS: PickerGenericPressure (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    if(_context == :contextSettings) {

      if(_item == :menuAltimeterCalibrationQNH) {
        PickerGenericPressure.initialize(Ui.loadResource(Rez.Strings.titleAltimeterCalibrationQNH) as String,
                                         $.oMyAltimeter.fQNH,
                                         $.oMySettings.iUnitPressure,
                                         false);
      }

    }
  }

}

class MyPickerGenericPressureDelegate extends Ui.PickerDelegate {

  //
  // VARIABLES
  //

  private var context as Symbol = :contextNone;
  private var item as Symbol = :itemNone;
  private var parent as Symbol = :parentNone;
  private var focus as Number = 0;


  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol, _parent as Symbol) {
    PickerDelegate.initialize();
    self.context = _context;
    self.item = _item;
    self.parent = _parent;
  }

  function onAccept(_amValues) {
    // Input validation
    // ... unit
    var iUnit = $.oMySettings.iUnitPressure != null ? $.oMySettings.iUnitPressure : -1;
    if(iUnit < 0) {
      var oDeviceSettings = Sys.getDeviceSettings();
      if(oDeviceSettings has :distanceUnits and oDeviceSettings.distanceUnits != null) {
        iUnit = oDeviceSettings.distanceUnits;
      }
      else {
        iUnit = Sys.UNIT_METRIC;
      }
    }

    // Assemble components
    var fValue = _amValues[1]*1000.0f + _amValues[2]*100.0f + _amValues[3]*10.0f + _amValues[4];
    if(_amValues[0] != null) {
      fValue *= _amValues[0];
    }

    // Use user-specified pressure unit (NB: metric units are always used internally)
    if(iUnit == Sys.UNIT_STATUTE) {
      fValue /= 0.2953f;  // inHg (* 1000) -> Pa
    }
    else {
      fValue *= 10.0f;  // mb (* 10) -> Pa
    }

    if(self.context == :contextSettings) {

      if(self.item == :menuAltimeterCalibrationQNH) {
        $.oMyAltimeter.setQNH(fValue);
        $.oMySettings.saveAltimeterCalibrationQNH($.oMyAltimeter.fQNH);
        focus = 1;
      }

    }
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    Ui.switchToView(new MyMenu2Generic(self.parent, focus), new MyMenu2GenericDelegate(self.parent), WatchUi.SLIDE_RIGHT);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_RIGHT);
    return true;
  }


}
