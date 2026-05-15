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

class MyPickerGeneralViewPageLayout extends Ui.Picker {

  function initialize(_item as Symbol) {
    if(_item == :menuGeneralViewPageAdd) {
      var asValues = ["2 Indicators", "4 Indicators", "7 Indicators"];
      var oFactory = new PickerFactoryDictionary([$.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_2, $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_4, $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_7], asValues, {:font => Gfx.FONT_TINY});
      Picker.initialize({
            :title => new Ui.Text({
                :text => "Select Layout",
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey($.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_7)]});
    }
  }
}

class MyPickerGeneralViewPageLayoutDelegate extends Ui.PickerDelegate {

  private var item as Symbol = :menuNone;

  function initialize(_item as Symbol) {
    PickerDelegate.initialize();
    item = _item;
  }

  function onCancel() {
    Ui.popView(Ui.SLIDE_IMMEDIATE);
  }

  function onAccept(_amValues) {
    if(_amValues.size() > 0) {
      var iLayout = _amValues[0] as Number;
      if(item == :menuGeneralViewPageAdd) {
        // Create a default page with the selected layout
        $.oMySettings.createGeneralViewPage("Page " + ($.oMySettings.getGeneralViewPageCount() + 1), iLayout);
        // Close the picker and the stale pages menu, then reopen the page list so it refreshes.
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        Ui.pushView(new MyMenu2Generic(:menuGeneralViewPages, 0),
                    new MyMenu2GenericDelegate(:menuGeneralViewPages),
                    Ui.SLIDE_IMMEDIATE);
      } else {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
      }
    }
  }
}
