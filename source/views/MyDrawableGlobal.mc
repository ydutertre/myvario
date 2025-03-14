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
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class MyDrawableGlobal extends Ui.Drawable {

  //
  // VARIABLES
  //

  // Resources
  private var oRezFieldsBackground as Ui.Drawable;
  private var oRezAlertLeft as Ui.Drawable;
  private var oRezAlertCenter as Ui.Drawable;
  private var oRezAlertRight as Ui.Drawable;

  // Colors
  private var iColorFieldsBackground as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorAlertLeft as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorAlertCenter as Number = Gfx.COLOR_TRANSPARENT;
  private var iColorAlertRight as Number = Gfx.COLOR_TRANSPARENT;


  //
  // FUNCTIONS: Ui.Drawable (override/implement)
  //

  function initialize() {
    Drawable.initialize({:identifier => "MyDrawableGlobal"});

    // Resources
    oRezFieldsBackground = new Rez.Drawables.drawFieldsBackground();
    oRezAlertLeft = new Rez.Drawables.drawGlobalAlertLeft();
    oRezAlertCenter = new Rez.Drawables.drawGlobalAlertCenter();
    oRezAlertRight = new Rez.Drawables.drawGlobalAlertRight();
  }

  function draw(_oDC) {
    // Draw

    // ... fields
    _oDC.setColor(self.iColorFieldsBackground, Gfx.COLOR_TRANSPARENT);
    self.oRezFieldsBackground.draw(_oDC);

    // ... alerts
    if(self.iColorAlertLeft != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(self.iColorAlertLeft, Gfx.COLOR_TRANSPARENT);
      self.oRezAlertLeft.draw(_oDC);
    }
    if(self.iColorAlertCenter != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(self.iColorAlertCenter, Gfx.COLOR_TRANSPARENT);
      self.oRezAlertCenter.draw(_oDC);
    }
    if(self.iColorAlertRight != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(self.iColorAlertRight, Gfx.COLOR_TRANSPARENT);
      self.oRezAlertRight.draw(_oDC);
    }

  }


  //
  // FUNCTIONS: self
  //

  function setColorFieldsBackground(_iColor as Number) as Void {
    self.iColorFieldsBackground = _iColor;
  }

  function setColorAlertLeft(_iColor as Number) as Void {
    self.iColorAlertLeft = _iColor;
  }

  function setColorAlertCenter(_iColor as Number) as Void {
    self.iColorAlertCenter = _iColor;
  }

  function setColorAlertRight(_iColor as Number) as Void {
    self.iColorAlertRight = _iColor;
  }

}
