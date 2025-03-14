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
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Math;

class MyViewVariometer extends MyView {

  //
  // VARIABLES
  //

  // Layout-specific
  private var iLayoutCenter as Number = (Sys.getDeviceSettings().screenWidth * 0.5).toNumber();
  private var iLayoutValueR as Number = (iLayoutCenter * 0.5).toNumber();
  private var iLayoutCacheX as Number = (iLayoutCenter * 0.84).toNumber();
  private var iLayoutCacheR as Number = (iLayoutCenter * 0.75).toNumber();
  private var iLayoutBatteryY as Number = (Sys.getDeviceSettings().screenHeight * 0.615).toNumber();
  // private var iLayoutActivityY as Number = (iLayoutBatteryY * 0.5).toNumber();
  private var iLayoutActivityY as Number = (Sys.getDeviceSettings().screenHeight - iLayoutBatteryY);
  private var iLayoutTimeY as Number = Math.round(Sys.getDeviceSettings().screenHeight * 0.675);
  private var iLayoutAltitudeY as Number = (Sys.getDeviceSettings().screenHeight - iLayoutTimeY);
  private var iLayoutUnitX as Number = (Sys.getDeviceSettings().screenWidth * 0.883).toNumber();
  
  //
  // FUNCTIONS: MyView (override/implement)
  //

  function initialize() {
    MyView.initialize();
  }

  function onLayout(_oDC) {
    //Sys.println("DEBUG: MyViewVariometer.onLayout()");
    // No layout; see drawLayout() below
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
    if(LangUtils.notNaN(fValue)) {
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
    _oDC.setColor(self.iColorTextGr, Gfx.COLOR_TRANSPARENT);
    sValue = Lang.format("$1$%", [Sys.getSystemStats().battery.format("%.0f")]);
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutBatteryY, Gfx.FONT_XTINY, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... activity
    if($.oMyActivity == null) {  // ... stand-by
      _oDC.setColor(self.iColorTextGr, Gfx.COLOR_TRANSPARENT);
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
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutActivityY - Gfx.getFontHeight(Gfx.FONT_XTINY), Gfx.FONT_XTINY, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // ... time
    var oTimeNow = Time.now();
    var oTimeInfo = $.oMySettings.bUnitTimeUTC ? Gregorian.utcInfo(oTimeNow, Time.FORMAT_SHORT) : Gregorian.info(oTimeNow, Time.FORMAT_SHORT);
    sValue = Lang.format("$1$$2$$3$ $4$", [oTimeInfo.hour.format("%02d"), oTimeNow.value() % 2 ? "." : ":", oTimeInfo.min.format("%02d"), $.oMySettings.sUnitTime]);
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutTimeY, Gfx.FONT_MEDIUM, sValue, Gfx.TEXT_JUSTIFY_CENTER);

    // Draw position values

    // ... altitude
    fValue = $.oMyProcessing.fAltitude;
    if(LangUtils.notNaN(fValue)) {
      fValue *= $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutAltitudeY - Gfx.getFontHeight(Gfx.FONT_MEDIUM), Gfx.FONT_MEDIUM, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitElevation]), Gfx.TEXT_JUSTIFY_CENTER);

    // ... variometer
    fValue = $.oMyProcessing.fVariometer_filtered;
    if(LangUtils.notNaN(fValue)) {
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
    _oDC.drawText(self.iLayoutCacheX, self.iLayoutCenter, Gfx.FONT_NUMBER_MEDIUM, sValue, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(self.iLayoutUnitX, self.iLayoutCenter, Gfx.FONT_TINY, $.oMySettings.sUnitVerticalSpeed, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
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
