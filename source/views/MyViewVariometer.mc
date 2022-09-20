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
using Toybox.Position as Pos;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewVariometer extends MyView {

  //
  // VARIABLES
  //

  // Resources
  // ... fonts
  private var oRezFontMeter as Ui.FontResource?;
  private var oRezFontStatus as Ui.FontResource?;

  // Layout-specific
  private var iLayoutCenter as Number = 120;
  private var iLayoutValueR as Number = 60;
  private var iLayoutCacheX as Number = 100;
  private var iLayoutCacheR as Number = 90;
  private var iLayoutBatteryY as Number = 148;
  private var iLayoutActivityY as Number = 75;
  private var iLayoutTimeY as Number = 162;
  private var iLayoutAltitudeY as Number = 42;
  private var iLayoutValueY as Number = 83;
  private var iLayoutUnitX as Number = 212;
  private var iLayoutUnitY as Number = 105;


  //
  // FUNCTIONS: Layout-specific
  //

  (:layout_218x218)
  function initLayout() as Void {
    self.iLayoutCenter = 109;
    self.iLayoutValueR = 55;
    self.iLayoutCacheX = 91;
    self.iLayoutCacheR = 82;
    self.iLayoutBatteryY = 134;
    self.iLayoutActivityY = 68;
    self.iLayoutTimeY = 147;
    self.iLayoutAltitudeY = 38;
    self.iLayoutValueY = 75;
    self.iLayoutUnitX = 193;
    self.iLayoutUnitY = 95;
  }

  (:layout_240x240)
  function initLayout() as Void {
    self.iLayoutCenter = 120;
    self.iLayoutValueR = 60;
    self.iLayoutCacheX = 100;
    self.iLayoutCacheR = 90;
    self.iLayoutBatteryY = 148;
    self.iLayoutActivityY = 75;
    self.iLayoutTimeY = 162;
    self.iLayoutAltitudeY = 42;
    self.iLayoutValueY = 83;
    self.iLayoutUnitX = 212;
    self.iLayoutUnitY = 105;
  }

  (:layout_260x260)
  function initLayout() as Void {
    self.iLayoutCenter = 130;
    self.iLayoutValueR = 65;
    self.iLayoutCacheX = 108;
    self.iLayoutCacheR = 98;
    self.iLayoutBatteryY = 160;
    self.iLayoutActivityY = 81;
    self.iLayoutTimeY = 176;
    self.iLayoutAltitudeY = 46;
    self.iLayoutValueY = 90;
    self.iLayoutUnitX = 230;
    self.iLayoutUnitY = 114;
  }

  (:layout_280x280)
  function initLayout() as Void {
    self.iLayoutCenter = 140;
    self.iLayoutValueR = 70;
    self.iLayoutCacheX = 120;
    self.iLayoutCacheR = 105;
    self.iLayoutBatteryY = 173;
    self.iLayoutActivityY = 88;
    self.iLayoutTimeY = 189;
    self.iLayoutAltitudeY = 49;
    self.iLayoutValueY = 97;
    self.iLayoutUnitX = 247;
    self.iLayoutUnitY = 123;
  }

  (:layout_360x360)
  function initLayout() as Void {
    self.iLayoutCenter = 180;
    self.iLayoutValueR = 90;
    self.iLayoutCacheX = 154;
    self.iLayoutCacheR = 135;
    self.iLayoutBatteryY = 222;
    self.iLayoutActivityY = 114;
    self.iLayoutTimeY = 243;
    self.iLayoutAltitudeY = 63;
    self.iLayoutValueY = 125;
    self.iLayoutUnitX = 318;
    self.iLayoutUnitY = 159;
  }

  (:layout_390x390)
  function initLayout() as Void {
    self.iLayoutCenter = 195;
    self.iLayoutValueR = 98;
    self.iLayoutCacheX = 167;
    self.iLayoutCacheR = 146;
    self.iLayoutBatteryY = 241;
    self.iLayoutActivityY = 123;
    self.iLayoutTimeY = 263;
    self.iLayoutAltitudeY = 68;
    self.iLayoutValueY = 135;
    self.iLayoutUnitX = 344;
    self.iLayoutUnitY = 172;
  }

  (:layout_416x416)
  function initLayout() as Void {
    self.iLayoutCenter = 208;
    self.iLayoutValueR = 104;
    self.iLayoutCacheX = 178;
    self.iLayoutCacheR = 156;
    self.iLayoutBatteryY = 257;
    self.iLayoutActivityY = 131;
    self.iLayoutTimeY = 281;
    self.iLayoutAltitudeY = 73;
    self.iLayoutValueY = 144;
    self.iLayoutUnitX = 367;
    self.iLayoutUnitY = 183;
  }


  //
  // FUNCTIONS: MyView (override/implement)
  //

  function initialize() {
    //Populate last view
    $.oMyProcessing.bIsPreviousGeneral = false;

    MyView.initialize();

    // Layout-specific initialization
    self.initLayout();
  }

  function onLayout(_oDC) {
    //Sys.println("DEBUG: MyViewVariometer.onLayout()");
    // No layout; see drawLayout() below

    // Load resources
    // ... fonts
    self.oRezFontMeter = Ui.loadResource(Rez.Fonts.fontMeter) as Ui.FontResource;
    self.oRezFontStatus = Ui.loadResource(Rez.Fonts.fontStatus) as Ui.FontResource;
  }

  function onShow() {
    //Sys.println("DEBUG: MyViewVariometer.onShow()");
    MyView.onShow();

    // Unmute tones
    (App.getApp() as MyApp).unmuteTones();
  }

  function onUpdate(_oDC) {
    //Sys.println("DEBUG: MyViewVariometer.onUpdate()");
    MyView.onUpdate(_oDC);

    // Draw layout
    self.drawLayout(_oDC);
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewVariometer.onHide()");
    MyView.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();
  }


  //
  // FUNCTIONS: self
  //

  function drawLayout(_oDC) {
    // Draw background
    _oDC.setPenWidth(self.iLayoutCenter);

    // ... background
    _oDC.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
    _oDC.clear();

    // ... variometer
    var fValue;
    var iColor = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    _oDC.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);
    _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_COUNTER_CLOCKWISE, 15, 345);
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor, $.oMySettings.iGeneralBackgroundColor);
    _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_CLOCKWISE, 15, 345);
    fValue = $.oMyProcessing.fVariometer_filtered;
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      if(fValue > 0.0f) {
        iColor = Gfx.COLOR_DK_GREEN;
        var iAngle = (180.0f*fValue/$.oMySettings.fVariometerRange).toNumber();
        if(iAngle != 0) {
          if(iAngle > 165) { iAngle = 165; }  // ... leave room for unit text
          _oDC.setColor(iColor, iColor);
          _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_CLOCKWISE, 180, 180-iAngle);
        }
      }
      else if(fValue < 0.0f) {
        iColor = Gfx.COLOR_RED;
        var iAngle = -(180.0f*fValue/$.oMySettings.fVariometerRange).toNumber();
        if(iAngle != 0) {
          if(iAngle > 165) { iAngle = 165; }  // ... leave room for unit text
          _oDC.setColor(iColor, iColor);
          _oDC.drawArc(self.iLayoutCenter, self.iLayoutCenter, self.iLayoutValueR, Gfx.ARC_COUNTER_CLOCKWISE, 180, 180+iAngle);
        }
      }
    }

    // ... cache
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor, $.oMySettings.iGeneralBackgroundColor);
    _oDC.fillCircle(self.iLayoutCacheX, self.iLayoutCenter, self.iLayoutCacheR);

    // Draw non-position values
    var sValue;

    // ... battery
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
    sValue = Lang.format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]);
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutBatteryY, self.oRezFontStatus as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... activity
    if($.oMyActivity == null) {  // ... stand-by
      _oDC.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityStandby;
    }
    else if(($.oMyActivity as MyActivity).isRecording()) {  // ... recording
      _oDC.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityRecording;
    }
    else {  // ... paused
      _oDC.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
      sValue = self.sValueActivityPaused;
    }
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutActivityY, self.oRezFontStatus as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... time
    var oTimeNow = Time.now();
    var oTimeInfo = $.oMySettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    sValue = Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.oMySettings.sUnitTime]);
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutTimeY, Gfx.FONT_MEDIUM, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // Draw position values

    // ... altitude
    fValue = $.oMyProcessing.fAltitude;
    if(LangUtils.notNaN(fValue) and $.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      fValue *= $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutAltitudeY, Gfx.FONT_MEDIUM, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitElevation]), Gfx.TEXT_JUSTIFY_CENTER);

    // ... variometer
    fValue = $.oMyProcessing.fVariometer_filtered;
    if(LangUtils.notNaN(fValue) and $.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE) {
      fValue *= $.oMySettings.fUnitVerticalSpeedCoefficient;
      if($.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.1f");
        if(fValue <= -0.05f or fValue >= 0.05f) {
          _oDC.setColor(iColor, Gfx.COLOR_TRANSPARENT);
        }
      }
      else {
        sValue = fValue.format("%+.0f");
        if(fValue <= -0.5f or fValue >= 0.5f) {
          _oDC.setColor(iColor, Gfx.COLOR_TRANSPARENT);
        }
      }
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutValueY, self.oRezFontMeter as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutUnitX, self.iLayoutUnitY, Gfx.FONT_TINY, $.oMySettings.sUnitVerticalSpeed, Gfx.TEXT_JUSTIFY_CENTER);
  }
}

class MyViewVariometerDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewVariometerDelegate.onPreviousPage()");
    Ui.switchToView(new MyViewGeneral(),
                    new MyViewGeneralDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewVariometerDelegate.onNextPage()");
    Ui.switchToView(new MyViewVarioplot(),
                    new MyViewVarioplotDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
