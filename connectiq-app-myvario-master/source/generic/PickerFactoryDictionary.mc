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

class PickerFactoryDictionary extends Ui.PickerFactory {

  //
  // VARIABLES
  //

  private var amKeys as Array = [];
  private var amValues as Array = [];
  private var amSettingsKeys as Array = [];
  private var amSettingsValues as Array = [];

  //
  // FUNCTIONS: Ui.PickerFactory (override/implement)
  //

  function initialize(_amKeys as Array, _amValues as Array, _dictSettings as Dictionary?) {
    PickerFactory.initialize();
    self.amKeys = _amKeys;
    self.amValues = _amValues;
    if(_dictSettings != null) {
      self.amSettingsKeys = _dictSettings.keys();
      self.amSettingsValues = _dictSettings.values();
    }
    else {
      self.amSettingsKeys = [];
      self.amSettingsValues = [];
    }
  }

  function getDrawable(_iItem, _bSelected) {
    var dictSettings = {
      :text => self.amValues[_iItem] as String,
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
    return self.amKeys[_iItem];
  }

  function getSize() {
    return self.amKeys.size();
  }


  //
  // FUNCTIONS: self
  //

  function indexOfKey(_mKey as Object?) as Number {
    return self.amKeys.indexOf(_mKey);
  }

  function indexOfValue(_mValue as Object?) as Number {
    return self.amValues.indexOf(_mValue);
  }

}
