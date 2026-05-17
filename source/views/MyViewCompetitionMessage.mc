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

import Toybox.Lang;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;

class MyViewCompetitionMessage extends Ui.View {

  private var sTitle as String = "";
  private var sSubtitle as String = "";

  function initialize(_sTitle as String, _sSubtitle as String) {
    View.initialize();
    self.sTitle = _sTitle;
    self.sSubtitle = _sSubtitle;
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    _oDC.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    _oDC.clear();

    var iCenterX = _oDC.getWidth() / 2;
    var iCenterY = _oDC.getHeight() / 2;
    _oDC.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    var titleFont = Gfx.FONT_MEDIUM;
    var subtitleFont = Gfx.FONT_SMALL;
    var iTitleHeight = Gfx.getFontHeight(titleFont);
    var iSubtitleHeight = self.sSubtitle.length() > 0 ? Gfx.getFontHeight(subtitleFont) : 0;
    var iGap = self.sSubtitle.length() > 0 ? 6 : 0;
    var iBlockTop = iCenterY - ((iTitleHeight + iGap + iSubtitleHeight) / 2);

    _oDC.drawText(iCenterX, iBlockTop, titleFont, self.sTitle, Gfx.TEXT_JUSTIFY_CENTER);
    if(self.sSubtitle.length() > 0) {
      _oDC.drawText(iCenterX, iBlockTop + iTitleHeight + iGap, subtitleFont, self.sSubtitle, Gfx.TEXT_JUSTIFY_CENTER);
    }
  }
}

class MyViewCompetitionMessageDelegate extends Ui.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onBack() as Boolean {
    (App.getApp() as MyApp).hideCompetitionMessage();
    return true;
  }
}
