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

class PickerGenericOnOff extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_sTitle as String, _bValue as Boolean?) {
    // Input validation
    // ... value
    var bValue = _bValue != null ? _bValue : false;

    // Initialize picker
    var oFactory = new PickerFactoryDictionary([true, false],
                                               [Ui.loadResource(Rez.Strings.valueOn) as String,
                                                Ui.loadResource(Rez.Strings.valueOff) as String],
                                               null);
    Picker.initialize({
        :title => new Ui.Text({
            :text => _sTitle,
            :font => Gfx.FONT_TINY,
            :locX => Ui.LAYOUT_HALIGN_CENTER,
            :locY => Ui.LAYOUT_VALIGN_BOTTOM,
            :color => Gfx.COLOR_BLUE}),
        :pattern => [oFactory],
        :defaults => [oFactory.indexOfKey(bValue)]});
  }


  //
  // FUNCTIONS: self
  //

  function getValue(_amValues as Array) as Boolean {
    // Return value
    return _amValues[0];
  }
}
