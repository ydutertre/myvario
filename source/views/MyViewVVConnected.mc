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
using Toybox.Graphics as Gfx;
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;


class MyViewVVConnected extends MyViewHeader {

  var oStartTime;

  //
  // FUNCTIONS: MyViewHeader (override/implement)
  //

  function initialize() {
    MyViewHeader.initialize();
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewVarioplot.prepare()");
    MyViewHeader.prepare();
  }

  function onLayout(_oDC) {
    oStartTime = Time.now();
    MyViewHeader.onLayout(_oDC);
    self.drawValues(_oDC);
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.onUpdate()");

    // Update layout
    MyViewHeader.updateLayout(true);
    View.onUpdate(_oDC);
    self.drawValues(_oDC);
  }

  function drawValues(_oDC as Gfx.Dc) as Void {

    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    var justify = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
    var midX = _oDC.getWidth() / 2d;                // x 50%
    var midY = _oDC.getHeight() * 3d / 5d;          // y 60%
    var fontHeight = Gfx.getFontHeight(Gfx.FONT_SMALL);
    if($.oMyVectorVario.bBleConnected) {
      _oDC.drawText(midX, midY - fontHeight, Gfx.FONT_SMALL, "VV Connected!", justify); // (50%, 40%)
    } else {
      _oDC.drawText(midX, midY - fontHeight, Gfx.FONT_SMALL, "VV Disconnected!", justify); // (50%, 40%)
    }
    var oTimeNow = Time.now();
    if(oTimeNow.subtract(oStartTime).value() >= 3) {
      Ui.switchToView(new MyViewGeneral(),
                new MyViewGeneralDelegate(),
                Ui.SLIDE_IMMEDIATE);
    }
  }

  function onHide() {
    MyViewHeader.onHide();
  }

}

class MyViewVVConnectedDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    Ui.switchToView(new MyViewGeneral(),
                new MyViewGeneralDelegate(),
                Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onSelect() {
    Ui.switchToView(new MyViewGeneral(),
                new MyViewGeneralDelegate(),
                Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onBack() {
    Ui.switchToView(new MyViewGeneral(),
                new MyViewGeneralDelegate(),
                Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onPreviousPage() {
    Ui.switchToView(new MyViewGeneral(),
                    new MyViewGeneralDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    Ui.switchToView(new MyViewGeneral(),
                new MyViewGeneralDelegate(),
                Ui.SLIDE_IMMEDIATE);
    return true;
  }

}