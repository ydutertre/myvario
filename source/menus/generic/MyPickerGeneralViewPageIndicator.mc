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

import Toybox.Lang;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class MyPickerGeneralViewPageIndicator extends Ui.Picker {

  function initialize(_iPageIndex as Number, _iFieldIndex as Number) {
    var aiIndicators = [0, 1, 2, 3, 4, 5, 6, $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED];
    var asIndicatorLabels = [
      "Wind Direction",
      "Wind Speed",
      "Altitude",
      "Finesse (Glide Ratio)",
      "Heading",
      "Vertical Speed",
      "Ground Speed",
      "None"
    ];
    
    var aFields = $.oMySettings.getGeneralViewPageFields(_iPageIndex);
    var iCurrentIndicator = (_iFieldIndex < aFields.size()) ? (aFields[_iFieldIndex] as Number) : $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED;
    
    var oFactory = new PickerFactoryDictionary(aiIndicators, asIndicatorLabels, {:font => Gfx.FONT_TINY});
    Picker.initialize({
          :title => new Ui.Text({
              :text => "Field " + (_iFieldIndex + 1),
              :font => Gfx.FONT_TINY,
              :locX=>Ui.LAYOUT_HALIGN_CENTER,
              :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
              :color => Gfx.COLOR_BLUE}),
          :pattern => [oFactory],
          :defaults => [oFactory.indexOfKey(iCurrentIndicator)]});
  }
}

class MyPickerGeneralViewPageIndicatorDelegate extends Ui.PickerDelegate {

  private var iPageIndex as Number = 0;
  private var iFieldIndex as Number = 0;

  function initialize(_iPageIndex as Number, _iFieldIndex as Number) {
    PickerDelegate.initialize();
    iPageIndex = _iPageIndex;
    iFieldIndex = _iFieldIndex;
  }

  function onCancel() {
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onAccept(_amValues) {
    if(_amValues.size() > 0) {
      var iIndicator = _amValues[0] as Number;
      $.oMySettings.setGeneralViewPageField(iPageIndex, iFieldIndex, iIndicator);
    }
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    Ui.switchToView(new MyMenu2Generic(:menuGeneralViewPageEdit, 0),
                    new MyMenu2GenericDelegate(:menuGeneralViewPageEdit),
                    Ui.SLIDE_IMMEDIATE);
  }
}
