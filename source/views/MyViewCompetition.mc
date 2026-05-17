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
using Toybox.Math;
using Toybox.WatchUi as Ui;

class MyViewCompetition extends MyView {

  function initialize() {
    MyView.initialize();
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    self.updateLayout(true);
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_WHITE : Gfx.COLOR_BLACK,
                  $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_WHITE : Gfx.COLOR_BLACK);
    _oDC.clear();

    var iText = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    var iMuted = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY;
    var iCenterX = _oDC.getWidth() / 2;
    var iCenterY = _oDC.getHeight() / 2;
    var iTinyHeight = Gfx.getFontHeight(Gfx.FONT_TINY);
    var iSmallHeight = Gfx.getFontHeight(Gfx.FONT_SMALL);
    var iTopY = (_oDC.getHeight() * 0.12f).toNumber();
    var iTimeY = iTopY + iTinyHeight + 2;

    if($.oMyCompetitionTask == null || !$.oMySettings.bCompetitionMode) {
      _oDC.setColor(iMuted, Gfx.COLOR_TRANSPARENT);
      _oDC.drawText(iCenterX, iCenterY, Gfx.FONT_MEDIUM, "Competition Off", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
      return;
    }

    var task = $.oMyCompetitionTask;
    _oDC.setColor(iMuted, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(iCenterX, iTopY, Gfx.FONT_TINY, task.getStatusText(), Gfx.TEXT_JUSTIFY_CENTER);

    var sTime = "";
    if(task.iTaskState == task.TASK_WAITING) {
      sTime = task.isAfterStart(task.currentUtcSeconds()) ? "Start " + task.getStartText() : "Start in " + task.getStartInText();
    }
    else {
      sTime = "Left " + task.getTaskLeftText();
    }
    _oDC.drawText(iCenterX, iTimeY, Gfx.FONT_TINY, sTime, Gfx.TEXT_JUSTIFY_CENTER);

    if(task.iState != task.STATE_READY && task.iState != task.STATE_DONE) {
      _oDC.setColor(iText, Gfx.COLOR_TRANSPARENT);
      _oDC.drawText(iCenterX, iCenterY, Gfx.FONT_MEDIUM, task.sStatus, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
      return;
    }

    var sName = task.sActiveName;
    if(sName.length() > 12) {
      sName = sName.substring(0, 12);
    }
    _oDC.setColor(iText, Gfx.COLOR_TRANSPARENT);
    var iNameY = (iCenterY + iSmallHeight * 0.7f).toNumber();
    if(LangUtils.notNaN(task.fBearing)) {
      var iArrowY = ((iTimeY + iTinyHeight + iNameY) / 2).toNumber();
      var iArrowRadius = (_oDC.getWidth() * 0.105f).toNumber();
      self.drawNavigationArrow(_oDC, iCenterX, iArrowY, iArrowRadius, task.fBearing);
    }
    _oDC.drawText(iCenterX, iNameY, Gfx.FONT_TINY, sName, Gfx.TEXT_JUSTIFY_CENTER);

    var sDistance = LangUtils.notNaN(task.fDistanceNext) ? (task.fDistanceNext * $.oMySettings.fUnitDistanceCoefficient).format("%.0f") + " " + $.oMySettings.sUnitDistance : "---";
    _oDC.drawText(iCenterX, iNameY + iTinyHeight + 4, Gfx.FONT_SMALL, sDistance, Gfx.TEXT_JUSTIFY_CENTER);
  }

  function drawNavigationArrow(_oDC as Gfx.Dc, _iCenterX as Number, _iCenterY as Number, _iRadius as Number, _fBearing as Float) as Void {
    var fArrowDir = _fBearing;
    if(LangUtils.notNaN($.oMyProcessing.fHeading)) {
      fArrowDir -= $.oMyProcessing.fHeading;
    }
    var fArrowWidth = Math.PI * 0.85f;
    var fArrowBackLeft = fArrowDir - fArrowWidth;
    var fArrowBackRight = fArrowDir + fArrowWidth;
    var aiiArrow = [
      [_iCenterX + _iRadius * Math.sin(fArrowDir), _iCenterY - _iRadius * Math.cos(fArrowDir)],
      [_iCenterX + _iRadius * Math.sin(fArrowBackLeft), _iCenterY - _iRadius * Math.cos(fArrowBackLeft)],
      [_iCenterX + _iRadius * 0.25f * Math.sin(fArrowDir + Math.PI), _iCenterY - _iRadius * 0.25f * Math.cos(fArrowDir + Math.PI)],
      [_iCenterX + _iRadius * Math.sin(fArrowBackRight), _iCenterY - _iRadius * Math.cos(fArrowBackRight)]
    ];
    _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
    _oDC.fillPolygon(aiiArrow);
  }
}

class MyViewCompetitionDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    if(Ui has :MapView && $.oMySettings.bMapDisplay) {
      var mapView = new MyViewMap();
      Ui.switchToView(mapView,
                      new MyViewMapDelegate(mapView),
                      Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.switchToView(new MyViewVarioplot(),
                      new MyViewVarioplotDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onNextPage() {
    if($.oMyActivity != null) {
      $.oMySettings.selectFirstGeneralViewPage();
      Ui.switchToView(new MyViewGeneral(),
                      new MyViewGeneralDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.switchToView(new MyViewLog(),
                      new MyViewLogDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }
}
