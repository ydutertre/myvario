// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (C) 2022 Yannick Dutertre <https://yannickd9.wixsite.com/myvario>
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
using Toybox.Position as Pos;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class MyDrawableHeader extends Ui.Drawable {

  //
  // VARIABLES
  //

  // Resources
  private var oRezHeaderAccuracy1 as Ui.Drawable;
  private var oRezHeaderAccuracy2 as Ui.Drawable;
  private var oRezHeaderAccuracy3 as Ui.Drawable;
  private var oRezHeaderAccuracy4 as Ui.Drawable;

  // Background color
  private var iColorBackground as Number = Gfx.COLOR_TRANSPARENT;

  // Position accuracy
  private var iPositionAccuracy as Number = Pos.QUALITY_NOT_AVAILABLE;


  //
  // FUNCTIONS: Ui.Drawable (override/implement)
  //

  function initialize() {
    Drawable.initialize({:identifier => "MyDrawableHeader"});

    // Resources
    oRezHeaderAccuracy1 = new Rez.Drawables.drawHeaderAccuracy1();
    oRezHeaderAccuracy2 = new Rez.Drawables.drawHeaderAccuracy2();
    oRezHeaderAccuracy3 = new Rez.Drawables.drawHeaderAccuracy3();
    oRezHeaderAccuracy4 = new Rez.Drawables.drawHeaderAccuracy4();
  }

  function draw(_oDC) { 
    // Draw
    // ... background
    _oDC.setColor(self.iColorBackground, self.iColorBackground);
    _oDC.clear();

    // ... positioning accuracy
    switch(self.iPositionAccuracy) {

    case Pos.QUALITY_GOOD:
      _oDC.setColor(Gfx.COLOR_DK_GREEN, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy1.draw(_oDC);
      self.oRezHeaderAccuracy2.draw(_oDC);
      self.oRezHeaderAccuracy3.draw(_oDC);
      self.oRezHeaderAccuracy4.draw(_oDC);
      break;

    case Pos.QUALITY_USABLE:
      _oDC.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy1.draw(_oDC);
      self.oRezHeaderAccuracy2.draw(_oDC);
      self.oRezHeaderAccuracy3.draw(_oDC);
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy4.draw(_oDC);
      break;

    case Pos.QUALITY_POOR:
      _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy1.draw(_oDC);
      self.oRezHeaderAccuracy2.draw(_oDC);
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy3.draw(_oDC);
      self.oRezHeaderAccuracy4.draw(_oDC);
      break;

    case Pos.QUALITY_LAST_KNOWN:
      _oDC.setColor(Gfx.COLOR_DK_RED, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy1.draw(_oDC);
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy2.draw(_oDC);
      self.oRezHeaderAccuracy3.draw(_oDC);
      self.oRezHeaderAccuracy4.draw(_oDC);
      break;

    case Pos.QUALITY_NOT_AVAILABLE:
    default:
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      self.oRezHeaderAccuracy1.draw(_oDC);
      self.oRezHeaderAccuracy2.draw(_oDC);
      self.oRezHeaderAccuracy3.draw(_oDC);
      self.oRezHeaderAccuracy4.draw(_oDC);
      break;

    }
  }


  //
  // FUNCTIONS: self
  //

  function setColorBackground(_iColorBackground as Number) as Void {
    self.iColorBackground = _iColorBackground;
  }

  function setPositionAccuracy(_iPositionAccuracy as Number) as Void {
    self.iPositionAccuracy = _iPositionAccuracy;
  }

}
