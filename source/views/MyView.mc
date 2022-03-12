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
using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyView extends Ui.View {

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var bShow as Boolean = false;

  // Resources
  // ... strings
  protected var sValueActivityStandby as String = "SBY";
  protected var sValueActivityRecording as String = "REC";
  protected var sValueActivityPaused as String = "PSD";

  // Internals
  protected var iColorText as Number = Gfx.COLOR_BLACK;


  //
  // FUNCTIONS: Ui.View (override/implement)
  //

  function initialize() {
    View.initialize();
  }

  function onShow() {
    //Sys.println("DEBUG: MyView.onShow()");

    // Prepare view
    self.prepare();

    // Done
    self.bShow = true;
    $.oMyView = self;
  }

  function onHide() {
    //Sys.println("DEBUG: MyView.onHide()");
    $.oMyView = null;
    self.bShow = false;
  }


  //
  // FUNCTIONS: self
  //

  function prepare() as Void {
    //Sys.println("DEBUG: MyView.prepare()");

    // Load resources
    // ... strings
    self.sValueActivityStandby = Ui.loadResource(Rez.Strings.valueActivityStandby) as String;
    self.sValueActivityRecording = Ui.loadResource(Rez.Strings.valueActivityRecording) as String;
    self.sValueActivityPaused = Ui.loadResource(Rez.Strings.valueActivityPaused) as String;

    // (Re)load settings
    (App.getApp() as MyApp).loadSettings();
    // ... colors
    self.iColorText = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
  }

  function updateUi() as Void {
    //Sys.println("DEBUG: MyView.updateUi()");

    // Request UI update
    if(self.bShow) {
      Ui.requestUpdate();
    }
  }

  function updateLayout(_bUpdateTime as Boolean) as Void {
    //Sys.println("DEBUG: MyView.updateLayout()");

    // Set colors
    self.iColorText = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
  }

}
