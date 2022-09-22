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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

// Display mode (intent)
var iMyViewVarioplotPanZoom as Number = 0;
var iMyViewVarioplotOffsetX as Number = 0;
var iMyViewVarioplotOffsetY as Number = 0;

class MyViewVarioplot extends MyViewHeader {

  //CONSTANTS
  public const TIME_CONSTANT = 4;

  //
  // VARIABLES
  //

  // Display mode (internal)
  private var iPanZoom as Number = 0;

  // Resources
  // ... buttons
  private var oRezButtonKeyUp as Ui.Drawable?;
  private var oRezButtonKeyDown as Ui.Drawable?;
  // ... fonts
  private var oRezFontPlot as Ui.FontResource?;

  // Layout-specific
  private var iLayoutCenter as Number = 120;
  private var iLayoutClipY as Number = 31;
  private var iLayoutClipW as Number = 240;
  private var iLayoutClipH as Number = 178;
  private var iLayoutValueXleft as Number = 40;
  private var iLayoutValueXright as Number = 200;
  private var iLayoutValueYtop as Number = 30;
  private var iLayoutValueYbottom as Number = 193;
  private var iDotRadius = 5 as Number;

  // Color scale
  private var aiScale as Array<Number> = [-3000, -2000, -1000, -50, 50, 1000, 2000, 3000] as Array<Number>;


  //
  // FUNCTIONS: Layout-specific
  //

  (:layout_218x218)
  function initLayout() as Void {
    self.iLayoutCenter = 109;
    self.iLayoutClipY = 28;
    self.iLayoutClipW = 218;
    self.iLayoutClipH = 162;
    self.iLayoutValueXleft = 36;
    self.iLayoutValueXright = 182;
    self.iLayoutValueYtop = 27;
    self.iLayoutValueYbottom = 173;
    self.iDotRadius = 3;
  }

  (:layout_246x322)
  function initLayout() as Void {
    self.iLayoutCenter = 120;
    self.iLayoutClipY = 31;
    self.iLayoutClipW = 240;
    self.iLayoutClipH = 178;
    self.iLayoutValueXleft = 40;
    self.iLayoutValueXright = 200;
    self.iLayoutValueYtop = 30;
    self.iLayoutValueYbottom = 190;
    self.iDotRadius = 3;
  }

  (:layout_240x240)
  function initLayout() as Void {
    self.iLayoutCenter = 120;
    self.iLayoutClipY = 31;
    self.iLayoutClipW = 240;
    self.iLayoutClipH = 178;
    self.iLayoutValueXleft = 40;
    self.iLayoutValueXright = 200;
    self.iLayoutValueYtop = 30;
    self.iLayoutValueYbottom = 190;
    self.iDotRadius = 3;
  }

  (:layout_260x260)
  function initLayout() as Void {
    self.iLayoutCenter = 130;
    self.iLayoutClipY = 34;
    self.iLayoutClipW = 260;
    self.iLayoutClipH = 192;
    self.iLayoutValueXleft = 43;
    self.iLayoutValueXright = 217;
    self.iLayoutValueYtop = 33;
    self.iLayoutValueYbottom = 205;
    self.iDotRadius = 4;
  }

  (:layout_280x280)
  function initLayout() as Void {
    self.iLayoutCenter = 140;
    self.iLayoutClipY = 36;
    self.iLayoutClipW = 280;
    self.iLayoutClipH = 208;
    self.iLayoutValueXleft = 47;
    self.iLayoutValueXright = 233;
    self.iLayoutValueYtop = 35;
    self.iLayoutValueYbottom = 221;
    self.iDotRadius = 5;
  }

  (:layout_282x470)
  function initLayout() as Void {
    self.iLayoutCenter = 140;
    self.iLayoutClipY = 36;
    self.iLayoutClipW = 280;
    self.iLayoutClipH = 208;
    self.iLayoutValueXleft = 47;
    self.iLayoutValueXright = 233;
    self.iLayoutValueYtop = 35;
    self.iLayoutValueYbottom = 221;
    self.iDotRadius = 5;
  }

  (:layout_360x360)
  function initLayout() as Void {
    self.iLayoutCenter = 180;
    self.iLayoutClipY = 46;
    self.iLayoutClipW = 360;
    self.iLayoutClipH = 268;
    self.iLayoutValueXleft = 61;
    self.iLayoutValueXright = 299;
    self.iLayoutValueYtop = 45;
    self.iLayoutValueYbottom = 281;
    self.iDotRadius = 6;
  }

  (:layout_390x390)
  function initLayout() as Void {
    self.iLayoutCenter = 195;
    self.iLayoutClipY = 50;
    self.iLayoutClipW = 390;
    self.iLayoutClipH = 290;
    self.iLayoutValueXleft = 66;
    self.iLayoutValueXright = 324;
    self.iLayoutValueYtop = 49;
    self.iLayoutValueYbottom = 304;
    self.iDotRadius = 7;
  }

  (:layout_416x416)
  function initLayout() as Void {
    self.iLayoutCenter = 208;
    self.iLayoutClipY = 53;
    self.iLayoutClipW = 416;
    self.iLayoutClipH = 309;
    self.iLayoutValueXleft = 70;
    self.iLayoutValueXright = 346;
    self.iLayoutValueYtop = 52;
    self.iLayoutValueYbottom = 328;
    self.iDotRadius = 7;
  }


  //
  // FUNCTIONS: MyViewHeader (override/implement)
  //

  function initialize() {
    MyViewHeader.initialize();

    // Layout-specific initialization
    self.initLayout();
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewVarioplot.prepare()");
    MyViewHeader.prepare();

    // Load resources
    // ... fonts
    self.oRezFontPlot = Ui.loadResource(Rez.Fonts.fontPlot) as Ui.FontResource;

    // Color scale
    switch($.oMySettings.iVariometerRange) {
    default:
    case 0:
      self.aiScale = [-3000, -2000, -1000, -50, 50, 1000, 2000, 3000] as Array<Number>;
      break;
    case 1:
      self.aiScale = [-6000, -4000, -2000, -100, 100, 2000, 4000, 6000] as Array<Number>;
      break;
    case 2:
      self.aiScale = [-9000, -6000, -3000, -150, 150, 3000, 6000, 9000] as Array<Number>;
      break;
    }

    // Unmute tones
    (App.getApp() as MyApp).unmuteTones();
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.onUpdate()");

    // Update layout
    MyViewHeader.updateLayout(true);
    View.onUpdate(_oDC);
    self.drawPlot(_oDC);
    self.drawValues(_oDC);

    // Draw buttons
    if($.iMyViewVarioplotPanZoom) {
      if(self.oRezButtonKeyUp == null or self.oRezButtonKeyDown == null
         or self.iPanZoom != $.iMyViewVarioplotPanZoom) {
        if($.iMyViewVarioplotPanZoom == 1) {  // ... zoom in/out
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonPlus();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonMinus();
        }
        else if($.iMyViewVarioplotPanZoom == 2) {  // ... pan up/down
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonUp();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonDown();
        }
        else if($.iMyViewVarioplotPanZoom == 3) {  // ... pan left/right
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonLeft();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonRight();
        }
        self.iPanZoom = $.iMyViewVarioplotPanZoom;
      }
      (self.oRezButtonKeyUp as Ui.Drawable).draw(_oDC);
      (self.oRezButtonKeyDown as Ui.Drawable).draw(_oDC);
    }
    else {
      self.oRezButtonKeyUp = null;
      self.oRezButtonKeyDown = null;
    }
  }

  function drawPlot(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.drawPlot()");
    var iNowEpoch = Time.now().value();

    // Draw plot
    _oDC.setPenWidth(3);
    var iPlotIndex = $.oMyProcessing.iPlotIndex;
    var iVariometerPlotRange = $.oMySettings.iVariometerPlotRange * 60;
    if(iPlotIndex < 0) {
      // No data
      return;
    }

    // ... end (center) location
    var iEndIndex = iPlotIndex;
    var iEndEpoch = $.oMyProcessing.aiPlotEpoch[iEndIndex];
    if(iEndEpoch < 0 or iNowEpoch-iEndEpoch > iVariometerPlotRange) {
      // No data or data too old
      return;
    }
    var iEndLatitude = $.oMyProcessing.aiPlotLatitude[iEndIndex];
    var iEndLongitude = $.oMyProcessing.aiPlotLongitude[iEndIndex];

    // ... start location
    var iStartEpoch = iNowEpoch-iVariometerPlotRange;

    // ... plot
    _oDC.setClip(0, self.iLayoutClipY, self.iLayoutClipW, self.iLayoutClipH);
    var iCurrentIndex = (iEndIndex-iVariometerPlotRange+1+MyProcessing.PLOTBUFFER_SIZE) % MyProcessing.PLOTBUFFER_SIZE;
    var fZoomX = $.oMySettings.fVariometerPlotZoom * Math.cos(iEndLatitude / 495035534.9930312523f);
    var fZoomY = $.oMySettings.fVariometerPlotZoom;
    var iMaxDeltaEpoch = self.TIME_CONSTANT;
    var iLastEpoch = iEndEpoch;  //
    var iLastX = 0;
    var iLastY = 0;
    var iLastColor = 0;
    var bDraw = false;
    for(var i=iVariometerPlotRange; i>0; i--) {
      var iCurrentEpoch = $.oMyProcessing.aiPlotEpoch[iCurrentIndex];
      if(iCurrentEpoch >= 0 and iCurrentEpoch >= iStartEpoch) {
        if(iCurrentEpoch-iLastEpoch <= iMaxDeltaEpoch) {
          var iCurrentX = self.iLayoutCenter+$.iMyViewVarioplotOffsetX + (($.oMyProcessing.aiPlotLongitude[iCurrentIndex]-iEndLongitude)*fZoomX).toNumber();
          var iCurrentY = self.iLayoutCenter+$.iMyViewVarioplotOffsetY - (($.oMyProcessing.aiPlotLatitude[iCurrentIndex]-iEndLatitude)*fZoomY).toNumber();
          var iCurrentVariometer = $.oMyProcessing.aiPlotVariometer[iCurrentIndex];
          if(bDraw) {
            var iCurrentColor;
            if(iCurrentVariometer > self.aiScale[7]) {
              iCurrentColor = 0xAAFFAA;
            }
            else if(iCurrentVariometer > self.aiScale[6]) {
              iCurrentColor = 0x00FF00;
            }
            else if(iCurrentVariometer > self.aiScale[5]) {
              iCurrentColor = 0x00AA00;
            }
            else if(iCurrentVariometer > self.aiScale[4]) {
              iCurrentColor = 0x55AA55;
            }
            else if(iCurrentVariometer < self.aiScale[0]) {
              iCurrentColor = 0xFFAAAA;
            }
            else if(iCurrentVariometer < self.aiScale[1]) {
              iCurrentColor = 0xFF0000;
            }
            else if(iCurrentVariometer < self.aiScale[2]) {
              iCurrentColor = 0xAA0000;
            }
            else if(iCurrentVariometer < self.aiScale[3]) {
              iCurrentColor = 0xAA5555;
            }
            else {
              iCurrentColor = 0xAAAAAA;
            }
            if(iCurrentX != iLastX or iCurrentY != iLastY or iCurrentColor != iLastColor) {  // ... better a few comparison than drawLine() for nothing
              _oDC.setColor(iCurrentColor, Gfx.COLOR_TRANSPARENT);
              _oDC.drawLine(iLastX, iLastY, iCurrentX, iCurrentY);
              if(i == 1) {
                _oDC.fillCircle(iCurrentX, iCurrentY, self.iDotRadius);
              }
            }
            iLastColor = iCurrentColor;
          }
          else {
            iLastColor = -1;
          }
          iLastX = iCurrentX;
          iLastY = iCurrentY;
          bDraw = true;
        }
        else {
          bDraw = false;
        }
        iLastEpoch = iCurrentEpoch;
      }
      else {
        bDraw = false;
      }
      iCurrentIndex = (iCurrentIndex+1) % MyProcessing.PLOTBUFFER_SIZE;
    }
    if($.oMyProcessing.iCenterLongitude != 0 && $.oMyProcessing.iCenterLatitude != 0 && $.oMyProcessing.iStandardDev != 0) {
      var myX = self.iLayoutCenter + $.iMyViewVarioplotOffsetX + (($.oMyProcessing.iCenterLongitude-iEndLongitude)*fZoomX).toNumber() + ($.oMyProcessing.fCenterWindOffsetLongitude / $.oMySettings.fVariometerPlotScale).toNumber();
      var myY = self.iLayoutCenter + $.iMyViewVarioplotOffsetY - (($.oMyProcessing.iCenterLatitude-iEndLatitude)*fZoomY).toNumber() - ($.oMyProcessing.fCenterWindOffsetLatitude / $.oMySettings.fVariometerPlotScale).toNumber();
      _oDC.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
      _oDC.drawCircle(myX, myY, ($.oMyProcessing.iStandardDev*fZoomY).toNumber());
    }
    //Sys.println(format("DEBUG: centerX, centerY, iEndLongitude, iEndLatitude = $1$, $2$, $3$, $4$", [$.oMyProcessing.iCenterLongitude, $.oMyProcessing.iCenterLatitude, iEndLongitude, iEndLatitude]));
    _oDC.clearClip();
  }

  function drawValues(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.drawValues()");

    // Draw values
    var fValue;
    var sValue;
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

    // ... altitude
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and LangUtils.notNaN($.oMyProcessing.fAltitude)) {
      fValue = $.oMyProcessing.fAltitude * $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYtop, self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitElevation]), Gfx.TEXT_JUSTIFY_LEFT);

    // ... variometer
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and LangUtils.notNaN($.oMyProcessing.fVariometer)) {
      fValue = $.oMyProcessing.fVariometer_filtered * $.oMySettings.fUnitVerticalSpeedCoefficient;
      if($.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.1f");
      }
      else {
        sValue = fValue.format("%+.0f");
      }
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutValueXright, self.iLayoutValueYtop, self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitVerticalSpeed]), Gfx.TEXT_JUSTIFY_RIGHT);

    // ... ground speed
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and LangUtils.notNaN($.oMyProcessing.fGroundSpeed)) {
      fValue = $.oMyProcessing.fGroundSpeed * $.oMySettings.fUnitHorizontalSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYbottom, self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitHorizontalSpeed]), Gfx.TEXT_JUSTIFY_LEFT);

    // ... finesse
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and !$.oMyProcessing.bAscent and LangUtils.notNaN($.oMyProcessing.fFinesse)) {
      fValue = $.oMyProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN2;
    }
    _oDC.drawText(self.iLayoutValueXright, self.iLayoutValueYbottom, self.oRezFontPlot as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_RIGHT);
  }

  function onHide() {
    MyViewHeader.onHide();

    //Sys.println("DEBUG: MyViewVarioplot.onHide()");
    $.iMyViewVarioplotPanZoom = 0;
    $.iMyViewVarioplotOffsetX = 0;
    $.iMyViewVarioplotOffsetY = 0;

    // Mute tones
    (App.getApp() as MyApp).muteTones();

    // Free resources
    // ... buttons
    self.oRezButtonKeyUp = null;
    self.oRezButtonKeyDown = null;
  }

}

class MyViewVarioplotDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onMenu()");
    if($.iMyViewVarioplotPanZoom) {
      $.iMyViewVarioplotPanZoom = 0;  // ... cancel pan/zoom
      $.iMyViewVarioplotOffsetX = 0;
      $.iMyViewVarioplotOffsetY = 0;
      Ui.pushView(new MyMenuGeneric(:menuSettings),
                  new MyMenuGenericDelegate(:menuSettings),
                  Ui.SLIDE_IMMEDIATE);
    }
    else {
      $.iMyViewVarioplotPanZoom = 1;  // ... enter pan/zoom
      Ui.requestUpdate();
    }
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onSelect()");
    if($.iMyViewVarioplotPanZoom) {
      $.iMyViewVarioplotPanZoom = ($.iMyViewVarioplotPanZoom+1) % 4;
      if($.iMyViewVarioplotPanZoom == 0) {
        $.iMyViewVarioplotPanZoom = 1;
      }
      Ui.requestUpdate();
    }
    else if($.oMyActivity == null) {
      Ui.pushView(new MyMenuGenericConfirm(:contextActivity, :actionStart),
                  new MyMenuGenericConfirmDelegate(:contextActivity, :actionStart, false),
                  Ui.SLIDE_IMMEDIATE);
    }
    else {
      Ui.pushView(new MyMenuGeneric(:menuActivity),
                  new MyMenuGenericDelegate(:menuActivity),
                  Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onBack()");
    if($.iMyViewVarioplotPanZoom) {
      $.iMyViewVarioplotPanZoom = 0;  // ... cancel pan/zoom
      $.iMyViewVarioplotOffsetX = 0;
      $.iMyViewVarioplotOffsetY = 0;
      Ui.requestUpdate();
      return true;
    }
    else if($.oMyActivity != null) {

      return true;
    }
    return false;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onPreviousPage()");
    if($.iMyViewVarioplotPanZoom == 0) {
      Ui.switchToView(new MyViewVariometer(),
                      new MyViewVariometerDelegate(),
                      Ui.SLIDE_IMMEDIATE);
    }
    else if($.iMyViewVarioplotPanZoom == 1) {  // ... zoom in
      var fPlotZoom_previous = $.oMySettings.fVariometerPlotZoom;
      $.oMySettings.setVariometerPlotZoom($.oMySettings.iVariometerPlotZoom+1);
      var fPlotZoom_ratio = $.oMySettings.fVariometerPlotZoom/fPlotZoom_previous;
      $.iMyViewVarioplotOffsetY = ($.iMyViewVarioplotOffsetY*fPlotZoom_ratio).toNumber();
      $.iMyViewVarioplotOffsetX = ($.iMyViewVarioplotOffsetX*fPlotZoom_ratio).toNumber();
      App.Properties.setValue("userVariometerPlotZoom", $.oMySettings.iVariometerPlotZoom);
      Ui.requestUpdate();
    }
    else if($.iMyViewVarioplotPanZoom == 2) {  // ... pan up
      $.iMyViewVarioplotOffsetY += 10;
      Ui.requestUpdate();
    }
    else if($.iMyViewVarioplotPanZoom == 3) {  // ... pan left
      $.iMyViewVarioplotOffsetX += 10;
      Ui.requestUpdate();
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onNextPage()");
    if($.iMyViewVarioplotPanZoom == 0) {
      if($.oMyActivity != null) { //Skip the log view if we are recording, e.g. in flight
          Ui.switchToView(new MyViewGeneral(),
                  new MyViewGeneralDelegate(),
                  Ui.SLIDE_IMMEDIATE);
      }
      else {
        Ui.switchToView(new MyViewLog(),
                        new MyViewLogDelegate(),
                        Ui.SLIDE_IMMEDIATE);        
      }
    }
    else if($.iMyViewVarioplotPanZoom == 1) {  // ... zoom out
      var fPlotZoom_previous = $.oMySettings.fVariometerPlotZoom;
      $.oMySettings.setVariometerPlotZoom($.oMySettings.iVariometerPlotZoom-1);
      var fPlotZoom_ratio = $.oMySettings.fVariometerPlotZoom/fPlotZoom_previous;
      $.iMyViewVarioplotOffsetY = ($.iMyViewVarioplotOffsetY*fPlotZoom_ratio).toNumber();
      $.iMyViewVarioplotOffsetX = ($.iMyViewVarioplotOffsetX*fPlotZoom_ratio).toNumber();
      App.Properties.setValue("userVariometerPlotZoom", $.oMySettings.iVariometerPlotZoom);
      Ui.requestUpdate();
    }
    else if($.iMyViewVarioplotPanZoom == 2) {  // ... pan down
      $.iMyViewVarioplotOffsetY -= 10;
      Ui.requestUpdate();
    }
    else if($.iMyViewVarioplotPanZoom == 3) {  // ... pan right
      $.iMyViewVarioplotOffsetX -= 10;
      Ui.requestUpdate();
    }
    return true;
  }

}
