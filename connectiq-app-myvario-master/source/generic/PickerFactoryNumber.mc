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
using Toybox.WatchUi as Ui;

class PickerFactoryNumber extends Ui.PickerFactory {

  //
  // VARIABLES
  //

  private var iNumberMinimum as Number = 0;
  private var iNumberMaximum as Number = 0;
  private var sFormat as String = "%d";
  private var sLangFormat as String = "$1$";
  private var amSettingsKeys as Array = [];
  private var amSettingsValues as Array = [];

  //
  // FUNCTIONS: Ui.PickerFactory (override/implement)
  //

  function initialize(_iNumberMinimum as Number, _iNumberMaximum as Number,
                      _dictSettings as {:format as String, :langFormat as String}?) {
    PickerFactory.initialize();
    self.iNumberMinimum = _iNumberMinimum;
    self.iNumberMaximum = _iNumberMaximum;
    if(_dictSettings != null) {
      if(_dictSettings.hasKey(:format)) {
        self.sFormat = _dictSettings.get(:format) as String;
        _dictSettings.remove(:format);
      }
      if(_dictSettings.hasKey(:langFormat)) {
        self.sLangFormat = _dictSettings.get(:langFormat) as String;
        _dictSettings.remove(:langFormat);
      }
      self.amSettingsKeys = _dictSettings.keys();
      self.amSettingsValues = _dictSettings.values();
    }
    else {
      self.sFormat = "%d";
      self.sLangFormat = "$1$";
      self.amSettingsKeys = [];
      self.amSettingsValues = [];
    }
  }

  function getDrawable(_iItem, _bSelected) {
    var dictSettings = {
      :text => format(self.sLangFormat, [(self.getValue(_iItem) as Number).format(self.sFormat)]),
      :locX => Ui.LAYOUT_HALIGN_CENTER,
      :locY => Ui.LAYOUT_VALIGN_CENTER,
      :color => _bSelected ? Gfx.COLOR_WHITE : Gfx.COLOR_DK_GRAY
    };
    for(var i=0; i<self.amSettingsKeys.size(); i++) {
      dictSettings[self.amSettingsKeys[i]] = self.amSettingsValues[i];
    }
    return new Ui.Text(dictSettings);
  }

  function getValue(_iItem) {
    return self.iNumberMinimum+_iItem;
  }

  function getSize() {
    return self.iNumberMaximum-self.iNumberMinimum+1;
  }


  //
  // FUNCTIONS: self
  //

  function indexOf(_iNumber as Number) as Number {
    return _iNumber-self.iNumberMinimum;
  }

}
