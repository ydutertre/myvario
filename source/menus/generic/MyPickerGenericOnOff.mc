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
using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class MyPickerGenericOnOff extends PickerGenericOnOff {

  //
  // FUNCTIONS: PickerGenericOnOff (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    if(_context == :contextSettings) {

      if(_item == :itemSoundsVariometerTones) {
        PickerGenericOnOff.initialize(Ui.loadResource(Rez.Strings.titleSoundsVariometerTones) as String,
                                      $.oMySettings.loadSoundsVariometerTones());
      }
      else if(_item == :itemVariometerVibrations) {
        PickerGenericOnOff.initialize(Ui.loadResource(Rez.Strings.titleVariometerVibrations) as String,
                                      $.oMySettings.loadVariometerVibrations());
      }
      else if(_item == :itemActivityAutoStart) {
        PickerGenericOnOff.initialize(Ui.loadResource(Rez.Strings.titleActivityAutoStart) as String,
                                      $.oMySettings.loadActivityAutoStart());
      }

    }
    else if(_context == :contextVariometer) {
      if(_item == :itemAutoThermal) {
        PickerGenericOnOff.initialize(Ui.loadResource(Rez.Strings.titleVariometerAutoThermal) as String,
                                      $.oMySettings.loadVariometerAutoThermal());
      }
    }
  }

}

class MyPickerGenericOnOffDelegate extends Ui.PickerDelegate {

  //
  // VARIABLES
  //

  private var context as Symbol = :contextNone;
  private var item as Symbol = :itemNone;


  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    PickerDelegate.initialize();
    self.context = _context;
    self.item = _item;
  }

  function onAccept(_amValues) {
    var bValue = PickerGenericOnOff.getValue(_amValues);
    if(self.context == :contextSettings) {

      if(self.item == :itemSoundsVariometerTones) {
        $.oMySettings.saveSoundsVariometerTones(bValue);
      }
      else if(self.item == :itemVariometerVibrations) {
        $.oMySettings.saveVariometerVibrations(bValue);
      }
      else if(self.item == :itemActivityAutoStart) {
        $.oMySettings.saveActivityAutoStart(bValue);
      }

    }
    else if(self.context == :contextVariometer) {
      if(self.item == :itemAutoThermal) {
        $.oMySettings.saveVariometerAutoThermal(bValue);
      }
    }
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
