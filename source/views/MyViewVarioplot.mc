// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (c) 2025 Yannick Dutertre <https://yannickd9.wixsite.com/myvario>
// Amended using code from fork "GlideApp" by Pablo Castro
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
// Scale bar
var iScaleBarSize as Number = 0;
var sScaleBarUnit as String = "";
var iPlotScaleBarSize = 48 as Number; // Maximum size of the plot scale bar in pixels

class MyViewVarioplot extends MyViewHeader {
  
  //CONSTANTS
  private const TIME_CONSTANT = 4;

  //
  // VARIABLES
  //
  (:icon) var NoExclude as Symbol = :NoExclude;
  // Display mode (internal)
  private var fMapRotation as Float = 0.0f;
  // Resources
  // ... buttons
  private var oRezButtonKeyUp as Ui.Drawable?;
  private var oRezButtonKeyDown as Ui.Drawable?;

  // ... fonts
  private var oRezFontPlot as Ui.FontResource?;
  private var oRezFontPlotS as Ui.FontResource?;
  private var iFontPlotHeight as Number = 0;

  // Layout-specific
  private var iLayoutCenter as Number = (Sys.getDeviceSettings().screenWidth * 0.5).toNumber();
  private var iLayoutClipY as Number = (Sys.getDeviceSettings().screenHeight * 0.13).toNumber();
  private var iLayoutClipW as Number = Sys.getDeviceSettings().screenWidth;
  private var iLayoutClipH as Number = (Sys.getDeviceSettings().screenHeight * 0.742).toNumber();
  private var iLayoutValueXleft as Number = (Sys.getDeviceSettings().screenWidth * 0.165).toNumber();
  private var iLayoutValueXright as Number = Sys.getDeviceSettings().screenWidth - iLayoutValueXleft;
  private var iLayoutValueYtop as Number = (Sys.getDeviceSettings().screenHeight * 0.125).toNumber();
  private var iLayoutValueYcenter as Number = (Sys.getDeviceSettings().screenHeight * 0.476).toNumber();
  private var iLayoutValueYbottom as Number = Sys.getDeviceSettings().screenHeight - iLayoutValueYtop;
  private var iDotRadius as Number = (Sys.getDeviceSettings().screenWidth * 0.0164).toNumber();
  private var iCompassRadius as Number = (Sys.getDeviceSettings().screenHeight * 0.0385).toNumber();

  // Color scale
  private var aiScale as Array<Number> = [-3000, -2000, -1000, -50, 50, 1000, 2000, 3000] as Array<Number>;

  //
  // FUNCTIONS: MyViewHeader (override/implement)
  //

  function initialize() {
    MyViewHeader.initialize();

    // // Layout-specific initialization
    $.iPlotScaleBarSize = (iLayoutCenter * 0.4).toNumber(); // Maximum size of the plot scale bar in pixels
    (App.getApp() as MyApp).calculateScaleBar($.iPlotScaleBarSize, $.oMySettings.fVariometerPlotScale, $.oMySettings.sUnitDistance, $.oMySettings.fUnitDistanceCoefficient);
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewVarioplot.prepare()");
    MyViewHeader.prepare();

    // Load resources
    // ... fonts
    self.oRezFontPlot = Ui.loadResource(Rez.Fonts.fontPlot) as Ui.FontResource;
    self.oRezFontPlotS = Ui.loadResource(Rez.Fonts.fontPlotS) as Ui.FontResource;
    self.iFontPlotHeight = Gfx.getFontHeight(oRezFontPlotS);

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
      if(self.oRezButtonKeyUp == null or self.oRezButtonKeyDown == null) {
        if($.iMyViewVarioplotPanZoom == 1) {  // ... zoom in/out
          self.oRezButtonKeyUp = new Rez.Drawables.drawButtonPlus();
          self.oRezButtonKeyDown = new Rez.Drawables.drawButtonMinus();
        }
      }
      (self.oRezButtonKeyUp as Ui.Drawable).draw(_oDC);
      (self.oRezButtonKeyDown as Ui.Drawable).draw(_oDC);
    }
    else {
      self.oRezButtonKeyUp = null;
      self.oRezButtonKeyDown = null;
    }
  }

  function rotateCoordinate(_fOriginLong, _fOriginLat, _fLong, _fLat, _fThetaSin, _fThetaCos) as AFloats? {
    var fLongDiff = _fLong - _fOriginLong;
    var fLatDiff = _fLat - _fOriginLat;
    var fLongDiffRot = fLongDiff * _fThetaCos - fLatDiff * _fThetaSin;
    var fLatDiffRot = fLongDiff * _fThetaSin + fLatDiff * _fThetaCos;
    return [fLongDiffRot + _fOriginLong, fLatDiffRot + _fOriginLat];
  }

  function drawArrow(_oDC as Gfx.Dc, _iCenterX, _iCenterY, _iRadius, _fAngle, _fThickness,  _iColorFg, _iColorBg) as Void {
    // Draw background
    if(_oDC has :setAntiAlias) { _oDC.setAntiAlias(true); }
    if (_iColorBg != Gfx.COLOR_TRANSPARENT) {
      _oDC.setColor(_iColorBg, Gfx.COLOR_TRANSPARENT);
      _oDC.fillCircle(_iCenterX, _iCenterY, _iRadius + 1);
    }

    // Draw arrow
    if (_iColorFg == Gfx.COLOR_TRANSPARENT) { return; }
    var fArrowWidth = Math.PI * (1 - _fThickness);
    var fArrowBackLeft = _fAngle - fArrowWidth;
    var fArrowBackRight = _fAngle + fArrowWidth;

    var aiiArrow = [
      [_iCenterX + _iRadius * Math.sin(_fAngle),         _iCenterY - _iRadius * Math.cos(_fAngle)],
      [_iCenterX + _iRadius * Math.sin(fArrowBackLeft),  _iCenterY - _iRadius * Math.cos(fArrowBackLeft)],
      [_iCenterX + _iRadius * 0.2f * Math.sin(_fAngle + Math.PI),  _iCenterY - _iRadius * 0.2f * Math.cos(_fAngle - Math.PI)],
      [_iCenterX + _iRadius * Math.sin(fArrowBackRight), _iCenterY - _iRadius * Math.cos(fArrowBackRight)]
    ];

    _oDC.setColor(_iColorFg, Gfx.COLOR_TRANSPARENT);
    _oDC.fillPolygon(aiiArrow);
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
    var iCurrentIndex = (iEndIndex-iVariometerPlotRange+1+$.oMyProcessing.PLOTBUFFER_SIZE)%($.oMyProcessing.PLOTBUFFER_SIZE);
    var fZoomX = $.oMySettings.fVariometerPlotZoom * Math.cos(iEndLatitude / 495035534.9930312523f);
    var fZoomY = $.oMySettings.fVariometerPlotZoom;
    var iMaxDeltaEpoch = self.TIME_CONSTANT;
    var iLastEpoch = iEndEpoch;  //
    var iLastX = 0;
    var iLastY = 0;
    var iLastColor = 0;
    var bDraw = false;
    var bHeadingUp = LangUtils.notNaN($.oMyProcessing.fHeading) && $.oMySettings.iVariometerPlotOrientation == 1;
    var fHeadingSin = 0;
    var fHeadingCos = 1;
    if (bHeadingUp) {
      fHeadingSin = Math.sin($.oMyProcessing.fHeading);
      fHeadingCos = Math.cos($.oMyProcessing.fHeading);
      fMapRotation = $.oMyProcessing.fHeading;
    } else {
      fMapRotation = 0.0f;
    }
    for(var i=iVariometerPlotRange; i>0; i--) {
      var iCurrentEpoch = $.oMyProcessing.aiPlotEpoch[iCurrentIndex];
      if(iCurrentEpoch >= 0 and iCurrentEpoch >= iStartEpoch) {
        if(iCurrentEpoch-iLastEpoch <= iMaxDeltaEpoch) {
          var fLong = $.oMyProcessing.aiPlotLongitude[iCurrentIndex];
          var fLat = $.oMyProcessing.aiPlotLatitude[iCurrentIndex];
          if (bHeadingUp) {
            var rotated = rotateCoordinate(iEndLongitude, iEndLatitude, fLong, fLat, fHeadingSin, fHeadingCos);
            fLong = rotated[0];
            fLat = rotated[1];
          }
          var iCurrentX = self.iLayoutCenter+((fLong-iEndLongitude)*fZoomX).toNumber();
          var iCurrentY = self.iLayoutCenter-((fLat-iEndLatitude)*fZoomY).toNumber();
          var iCurrentVariometer = $.oMyProcessing.aiPlotVariometer[iCurrentIndex];
          if(bDraw) {
            var iCurrentColor = self.getDrawColor(iCurrentVariometer);
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
      iCurrentIndex = (iCurrentIndex+1) % $.oMyProcessing.PLOTBUFFER_SIZE;
    }

    // Draw detected thermal if enabled
    if($.oMyProcessing.iCenterLongitude != 0 && $.oMyProcessing.iCenterLatitude != 0 && $.oMyProcessing.iStandardDev != 0) {
      var fCenterLong = $.oMyProcessing.iCenterLongitude;
      var fCenterLat = $.oMyProcessing.iCenterLatitude;
      var fWindLong = $.oMyProcessing.fCenterWindOffsetLongitude;
      var fWindLat = $.oMyProcessing.fCenterWindOffsetLatitude;
      if (bHeadingUp) {
        var rotated = rotateCoordinate(iEndLongitude, iEndLatitude, fCenterLong, fCenterLat, fHeadingSin, fHeadingCos);
        fCenterLong = rotated[0];
        fCenterLat = rotated[1];
        rotated = rotateCoordinate(0, 0, fWindLong, fWindLat, fHeadingSin, fHeadingCos);
        fWindLong = rotated[0];
        fWindLat = rotated[1];
      }
      var myX = self.iLayoutCenter + ((fCenterLong-iEndLongitude)*fZoomX).toNumber() + (fWindLong / $.oMySettings.fVariometerPlotScale).toNumber();
      var myY = self.iLayoutCenter - ((fCenterLat-iEndLatitude)*fZoomY).toNumber() - (fWindLat / $.oMySettings.fVariometerPlotScale).toNumber();
      _oDC.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
      _oDC.drawCircle(myX, myY, ($.oMyProcessing.iStandardDev*fZoomY).toNumber());
    }
    
    // Draw compass
    if (bHeadingUp) {
      var iCompassX = self.iLayoutCenter;
      var iCompassY = self.iLayoutValueYtop + iCompassRadius + 2;

      // Draw compass arrow
      var fCompassDir = -fMapRotation;
      // var iCompassBg = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_LT_GRAY : Gfx.COLOR_DK_GRAY;
      drawArrow(_oDC, iCompassX, iCompassY, iCompassRadius, fCompassDir, 0.2f, Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);

      // Draw compass text
      _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);
      _oDC.drawText(iCompassX, iCompassY, self.oRezFontPlotS as Ui.FontResource, "N", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }
    // ... cardinal points
    else {
      _oDC.setColor($.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_LT_GRAY : Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
      _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYtop, self.oRezFontPlotS as Ui.FontResource, "N", Gfx.TEXT_JUSTIFY_CENTER);
      _oDC.drawText(self.iLayoutValueXright*1.14, self.iLayoutValueYcenter, self.oRezFontPlotS as Ui.FontResource, "E", Gfx.TEXT_JUSTIFY_LEFT);
      _oDC.drawText(self.iLayoutCenter, self.iLayoutValueYbottom - iFontPlotHeight, self.oRezFontPlotS as Ui.FontResource, "S", Gfx.TEXT_JUSTIFY_CENTER);
    }

    //Sys.println(format("DEBUG: centerX, centerY, iEndLongitude, iEndLatitude = $1$, $2$, $3$, $4$", [$.oMyProcessing.iCenterLongitude, $.oMyProcessing.iCenterLatitude, iEndLongitude, iEndLatitude]));
    _oDC.clearClip();
  }

  function getDrawColor(_iGain) as Number {
    if(_iGain > self.aiScale[7]) {
      return 0xAAFFAA;
    }
    else if(_iGain > self.aiScale[6]) {
      return 0x00FF00;
    }
    else if(_iGain > self.aiScale[5]) {
      return 0x00AA00;
    }
    else if(_iGain > self.aiScale[4]) {
      return 0x55AA55;
    }
    else if(_iGain < self.aiScale[0]) {
      return 0xFFAAAA;
    }
    else if(_iGain < self.aiScale[1]) {
      return 0xFF0000;
    }
    else if(_iGain < self.aiScale[2]) {
      return 0xAA0000;
    }
    else if(_iGain < self.aiScale[3]) {
      return 0xAA5555;
    }
    else {
      return 0xAAAAAA;
    }
  }

  function drawValues(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewVarioplot.drawValues()");

    // Draw values
    var fValue;
    var sValue;

    _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);

    // ... altitude
    if(LangUtils.notNaN($.oMyProcessing.fAltitude)) {
      fValue = $.oMyProcessing.fAltitude * $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }

    if($.oMyProcessing.aiPointAltitude.size() >= $.oMyProcessing.PLOTBUFFER_SIZE && $.oMyProcessing.iPlotIndex >=0) {
      // Get average elevation change per second over last 20 seconds (in mm)
      var elevationChange = 1000 * ($.oMyProcessing.aiPointAltitude[$.oMyProcessing.iPlotIndex] - $.oMyProcessing.aiPointAltitude[($.oMyProcessing.iPlotIndex + $.oMyProcessing.PLOTBUFFER_SIZE - 20) % $.oMyProcessing.PLOTBUFFER_SIZE]) / 20;
      
      if(elevationChange.abs() < self.aiScale[7]) { //Only apply color changes for "weaker" thermals, when checking gain at a glance makes sense
        var altitudeTextColor = self.getDrawColor(elevationChange);
        _oDC.setColor(altitudeTextColor, Gfx.COLOR_TRANSPARENT);
      } 
    }
    _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYtop, self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitElevation]), Gfx.TEXT_JUSTIFY_LEFT);
    _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);

    // ... thermal info
    if ($.oMyProcessing.bCirclingCount >= 5) {
      // Draw thermal time
      var iThermalTime = Time.now().value() - $.oMyProcessing.iCirclingStartEpoch;
      var iThermalTimeMinutes = iThermalTime / 60;
      var iThermalTimeSeconds = iThermalTime % 60;
      sValue = Lang.format("$1$:$2$", [iThermalTimeMinutes.format("%02d"), iThermalTimeSeconds.format("%02d")]);
      _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYtop + self.iFontPlotHeight * 1.3, self.oRezFontPlotS as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_LEFT);

      // Draw thermal altitude gain
      var iThermalGain = $.oMyProcessing.fAltitude - $.oMyProcessing.fCirclingStartAltitude;
      fValue = iThermalGain * $.oMySettings.fUnitElevationCoefficient;
      var cThermalGainColor = self.getDrawColor(1000 * iThermalGain);
      if (fValue < 0) {
        sValue = fValue.format("%.0f");
      } else {
        sValue = "+" + fValue.format("%.0f");
      }
      sValue += $.oMySettings.sUnitElevation;
      _oDC.setColor(cThermalGainColor, Gfx.COLOR_TRANSPARENT);
      _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYtop + self.iFontPlotHeight * 2.2, self.oRezFontPlotS as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_LEFT);
      _oDC.setColor(self.iColorText, Gfx.COLOR_TRANSPARENT);
    }

    // ... variometer
    if(LangUtils.notNaN($.oMyProcessing.fVariometer)) {
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
    _oDC.drawText(self.iLayoutValueXleft, self.iLayoutValueYbottom - Gfx.getFontHeight(oRezFontPlot), self.oRezFontPlot as Ui.FontResource, Lang.format("$1$ $2$", [sValue, $.oMySettings.sUnitHorizontalSpeed]), Gfx.TEXT_JUSTIFY_LEFT);

    // ... finesse
    if($.oMyProcessing.iAccuracy > Pos.QUALITY_NOT_AVAILABLE and !$.oMyProcessing.bAscent and LangUtils.notNaN($.oMyProcessing.fFinesse)) {
      fValue = $.oMyProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN2;
    }
    _oDC.drawText(self.iLayoutValueXright, self.iLayoutValueYbottom - Gfx.getFontHeight(oRezFontPlot), self.oRezFontPlot as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_RIGHT);
  
    // ... plot scale
    _oDC.setPenWidth(2);
    fValue = $.iScaleBarSize;
    sValue = $.sScaleBarUnit;
    _oDC.setColor(self.iColorTextGr, Gfx.COLOR_TRANSPARENT);
    var iScaleBarHeight = self.iLayoutValueYbottom - self.iFontPlotHeight - Gfx.getFontHeight(oRezFontPlot);
    var iScaleBarStart = (self.iLayoutValueXright * 1.06f).toNumber();
    var iScaleBarEnd = iScaleBarStart - fValue.toNumber();
    _oDC.drawLine(iScaleBarStart, iScaleBarHeight, iScaleBarEnd, iScaleBarHeight); // Horizontal line
    _oDC.drawLine(iScaleBarStart, iScaleBarHeight, iScaleBarStart, iScaleBarHeight - 3); // Left vertical line
    _oDC.drawLine(iScaleBarEnd, iScaleBarHeight, iScaleBarEnd, iScaleBarHeight - 3); // Right vertical line
    _oDC.drawText(iScaleBarStart, iScaleBarHeight, self.oRezFontPlotS as Ui.FontResource, sValue, Gfx.TEXT_JUSTIFY_RIGHT);

    // ... wind dir
    if ($.oMyProcessing.bWindValid) {
      fValue = $.oMyProcessing.iWindDirection;
      if($.oMySettings.iUnitDirection == 1) {
        sValue = $.oMyProcessing.convertDirection(fValue);
      } else {
        sValue = fValue.format("%d");
      }

      // Draw wind arrow
      var iWindX = 5 + iCompassRadius;
      var iWindY = self.iLayoutValueYcenter - self.iFontPlotHeight - iCompassRadius;
      drawArrow(_oDC, iWindX, iWindY, iCompassRadius * 0.9, Math.toRadians(fValue + 180) - fMapRotation, 0.18f, Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.setColor($.oMySettings.iGeneralBackgroundColor?Gfx.COLOR_DK_BLUE:Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(5, self.iLayoutValueYcenter - self.iFontPlotHeight, self.oRezFontPlotS as Ui.FontResource, (sValue.equals($.MY_NOVALUE_LEN3)?"":sValue), Gfx.TEXT_JUSTIFY_LEFT);

    // ... wind speed
    if ($.oMyProcessing.bWindValid) {
      fValue = $.oMyProcessing.fWindSpeed * $.oMySettings.fUnitWindSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    _oDC.drawText(5, self.iLayoutValueYcenter, self.oRezFontPlotS as Ui.FontResource, (sValue.equals($.MY_NOVALUE_LEN3)?"":"Wind"), Gfx.TEXT_JUSTIFY_LEFT);
    _oDC.drawText(5, self.iLayoutValueYcenter + self.iFontPlotHeight, self.oRezFontPlotS as Ui.FontResource, (sValue.equals($.MY_NOVALUE_LEN3)?"":sValue), Gfx.TEXT_JUSTIFY_LEFT);
    _oDC.drawText(5, self.iLayoutValueYcenter + self.iFontPlotHeight*2, self.oRezFontPlotS as Ui.FontResource, (sValue.equals($.MY_NOVALUE_LEN3)?"":$.oMySettings.sUnitWindSpeed), Gfx.TEXT_JUSTIFY_LEFT);

  }

  function onHide() {
    MyViewHeader.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();

    $.iMyViewVarioplotPanZoom = 0;
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
      Ui.pushView(new MyMenu2Generic(:menuSettings, 2),
                  new MyMenu2GenericDelegate(:menuSettings),
                  Ui.SLIDE_RIGHT);
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onSelect()");
    if($.iMyViewVarioplotPanZoom) {
      $.iMyViewVarioplotPanZoom = 0;  // ... cancel pan/zoom
      Ui.requestUpdate();
      return true;
    }
    else {
      $.iMyViewVarioplotPanZoom = 1;  // ... enter pan/zoom
      Ui.requestUpdate();
    }
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onBack()");
    if($.iMyViewVarioplotPanZoom) {
      $.iMyViewVarioplotPanZoom = 0;  // ... cancel pan/zoom
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
      $.oMySettings.setVariometerPlotZoom($.oMySettings.iVariometerPlotZoom+1);
      App.Properties.setValue("userVariometerPlotZoom", $.oMySettings.iVariometerPlotZoom);
      (App.getApp() as MyApp).calculateScaleBar($.iPlotScaleBarSize, $.oMySettings.fVariometerPlotScale, $.oMySettings.sUnitDistance, $.oMySettings.fUnitDistanceCoefficient);
      Ui.requestUpdate();
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewVarioplotDelegate.onNextPage()");
    if($.iMyViewVarioplotPanZoom == 0) {
      if((Ui has :MapView)&&($.oMySettings.bMapDisplay)) {
        var mapView = new MyViewMap();
        Ui.switchToView(mapView,
                        new MyViewMapDelegate(mapView),
                        Ui.SLIDE_IMMEDIATE);
      } 
      else if ($.oMyActivity != null) {
        Ui.switchToView(new MyViewGeneral(),
                new MyViewGeneralDelegate(),
                Ui.SLIDE_IMMEDIATE);
      } else {
        Ui.switchToView(new MyViewLog(),
            new MyViewLogDelegate(),
            Ui.SLIDE_IMMEDIATE);
      }
    }
    else if($.iMyViewVarioplotPanZoom == 1) {  // ... zoom out
      $.oMySettings.setVariometerPlotZoom($.oMySettings.iVariometerPlotZoom-1);
      App.Properties.setValue("userVariometerPlotZoom", $.oMySettings.iVariometerPlotZoom);
      (App.getApp() as MyApp).calculateScaleBar($.iPlotScaleBarSize, $.oMySettings.fVariometerPlotScale, $.oMySettings.sUnitDistance, $.oMySettings.fUnitDistanceCoefficient);
      Ui.requestUpdate();
    }
    return true;
  }

}
