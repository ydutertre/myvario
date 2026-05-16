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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewGeneral extends MyViewGlobal {
  //
  // VARIABLES
  //

  //strings
  private var sUnitElapsed as String = "elapsed";

  // active page tracking
  private var iCurrentGeneralViewPageIndex as Number = -1;

  // page slots
  private const GENERAL_VIEW_SLOT_NAMES as Array = ["TopLeft", "TopRight", "Left", "Center", "Right", "BottomLeft", "BottomRight"];

  // supported indicators
  private const GENERAL_VIEW_INDICATOR_WIND_DIRECTION as Number = 0;
  private const GENERAL_VIEW_INDICATOR_WIND_SPEED as Number = 1;
  private const GENERAL_VIEW_INDICATOR_ALTITUDE as Number = 2;
  private const GENERAL_VIEW_INDICATOR_FINESSE as Number = 3;
  private const GENERAL_VIEW_INDICATOR_HEADING as Number = 4;
  private const GENERAL_VIEW_INDICATOR_VERTICAL_SPEED as Number = 5;
  private const GENERAL_VIEW_INDICATOR_GROUND_SPEED as Number = 6;
  private const GENERAL_VIEW_INDICATOR_ALTITUDE_CHART as Number = 7;
  private const GENERAL_VIEW_INDICATOR_HEARTBEAT as Number = 8;
  private const GENERAL_VIEW_INDICATOR_FLIGHT_TIME as Number = 9;

  private const GENERAL_VIEW_INDICATOR_COUNT as Number = 10;

  //
  // FUNCTIONS: MyViewGlobal (override/implement)
  //

  function initialize() {
    //Populate last view
    $.oMyProcessing.bIsPreviousGeneral = true;
    self.iCurrentGeneralViewPageIndex = -1;
    MyViewGlobal.initialize();
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewGeneral.prepare()");
    MyViewGlobal.prepare();

    self.updatePageLabels();

    // Unmute tones
    (App.getApp() as MyApp).unmuteTones();
  }

  function getGlobalLayout(_oDC) {
    var iLayout = $.oMySettings.getGeneralViewPageLayout($.oMySettings.iGeneralViewActivePageIndex);
    switch(iLayout) {
    case $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_4:
      return Rez.Layouts.layoutGlobal4(_oDC);
    case $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_2:
      return Rez.Layouts.layoutGlobal2(_oDC);
    default:
      return Rez.Layouts.layoutGlobal(_oDC);
    }
  }

  function getGeneralViewSlotName(_iFieldIndex as Number, _iLayout as Number) as String {
    switch(_iLayout) {
    case $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_2:
      return (_iFieldIndex == 0) ? "TopLeft" : "TopRight";
    case $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_4:
      switch(_iFieldIndex) {
      case 0:
        return "TopLeft";
      case 1:
        return "TopRight";
      case 2:
        return "BottomLeft";
      case 3:
        return "BottomRight";
      default:
        return "TopLeft";
      }
    default:
      return GENERAL_VIEW_SLOT_NAMES[_iFieldIndex] as String;
    }
  }

  function clearPageSlot(_sSlot as String) as Void {
    var oLabel = View.findDrawableById("label" + _sSlot) as Ui.Text;
    var oUnit = View.findDrawableById("unit" + _sSlot) as Ui.Text;
    var oValue = View.findDrawableById("value" + _sSlot) as Ui.Text;
    if(oLabel != null) {
      oLabel.setText("");
    }
    if(oUnit != null) {
      oUnit.setText("");
    }
    if(oValue != null) {
      oValue.setText("");
    }
  }

  function updateFieldSlot(_sSlot as String, _iIndicator as Number, _bRecording as Boolean) as Void {
    var oValue = View.findDrawableById("value" + _sSlot) as Ui.Text;
    if(oValue == null) {
      return;
    }
    if(_iIndicator == $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED) {
      oValue.setText("");
      return;
    }
    if(_iIndicator == GENERAL_VIEW_INDICATOR_ALTITUDE_CHART) {
      oValue.setText("");
      return;
    }
    var sText = self.getIndicatorValueText(_iIndicator);
    var iColor = self.getIndicatorValueColor(_iIndicator, _bRecording);
    oValue.setFont(self.getIndicatorValueFont(_iIndicator, sText));
    oValue.setColor(iColor);
    oValue.setText(sText);
  }

  function updatePageLabels() {
    var aFields = $.oMySettings.getGeneralViewPageFields($.oMySettings.iGeneralViewActivePageIndex);
    var iLayout = $.oMySettings.getGeneralViewPageLayout($.oMySettings.iGeneralViewActivePageIndex);
    for(var i=0; i<iLayout; i++) {
      var sSlot = self.getGeneralViewSlotName(i, iLayout);
      var oLabel = View.findDrawableById("label" + sSlot) as Ui.Text;
      var oUnit = View.findDrawableById("unit" + sSlot) as Ui.Text;
      var iIndicator = (i < aFields.size()) ? (aFields[i] as Number) : $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED;
      if(iIndicator >= 0 && iIndicator < GENERAL_VIEW_INDICATOR_COUNT) {
        if(oLabel != null) {
          oLabel.setText(self.getIndicatorLabelText(iIndicator));
          oLabel.setColor(Gfx.COLOR_DK_GRAY);
        }
        if(oUnit != null) {
          oUnit.setText(self.getIndicatorUnitText(iIndicator));
          oUnit.setColor(Gfx.COLOR_DK_GRAY);
        }
      }
      else {
        if(oLabel != null) {
          oLabel.setText("");
        }
        if(oUnit != null) {
          oUnit.setText("");
        }
      }
    }
  }

  function getIndicatorLabelText(_iIndicator as Number) as String {
    switch(_iIndicator) {
    case GENERAL_VIEW_INDICATOR_WIND_DIRECTION:
      return Ui.loadResource(Rez.Strings.labelWindDirection) as String;
    case GENERAL_VIEW_INDICATOR_WIND_SPEED:
      return Ui.loadResource(Rez.Strings.labelWindSpeed) as String;
    case GENERAL_VIEW_INDICATOR_ALTITUDE:
      return Ui.loadResource(Rez.Strings.labelAltitude) as String;
    case GENERAL_VIEW_INDICATOR_FINESSE:
      return Ui.loadResource(Rez.Strings.labelFinesse) as String;
    case GENERAL_VIEW_INDICATOR_HEADING:
      return Ui.loadResource(Rez.Strings.labelHeading) as String;
    case GENERAL_VIEW_INDICATOR_VERTICAL_SPEED:
      return Ui.loadResource(Rez.Strings.labelVerticalSpeed) as String;
    case GENERAL_VIEW_INDICATOR_GROUND_SPEED:
      return Ui.loadResource(Rez.Strings.labelGroundSpeed) as String;
    case GENERAL_VIEW_INDICATOR_ALTITUDE_CHART:
      return Ui.loadResource(Rez.Strings.labelAltitude) as String;
    case GENERAL_VIEW_INDICATOR_HEARTBEAT:
      return "Heartbeat";
    case GENERAL_VIEW_INDICATOR_FLIGHT_TIME:
      return Ui.loadResource(Rez.Strings.labelElapsed) as String;
    default:
      return "";
    }
  }

  function getIndicatorUnitText(_iIndicator as Number) as String {
    switch(_iIndicator) {
    case GENERAL_VIEW_INDICATOR_WIND_DIRECTION:
    case GENERAL_VIEW_INDICATOR_HEADING:
      return ($.oMySettings.iUnitDirection == 0) ? "[Deg]" : "";
    case GENERAL_VIEW_INDICATOR_WIND_SPEED:
      return Lang.format("[$1$]", [$.oMySettings.sUnitWindSpeed]);
    case GENERAL_VIEW_INDICATOR_ALTITUDE:
    case GENERAL_VIEW_INDICATOR_ALTITUDE_CHART:
      return Lang.format("[$1$]", [$.oMySettings.sUnitElevation]);
    case GENERAL_VIEW_INDICATOR_VERTICAL_SPEED:
      return Lang.format("[$1$]", [$.oMySettings.sUnitVerticalSpeed]);
    case GENERAL_VIEW_INDICATOR_GROUND_SPEED:
      return Lang.format("[$1$]", [$.oMySettings.sUnitHorizontalSpeed]);
    case GENERAL_VIEW_INDICATOR_HEARTBEAT:
      return "[bpm]";
    case GENERAL_VIEW_INDICATOR_FLIGHT_TIME:
      return $.MY_NOVALUE_BLANK;
    default:
      return "";
    }
  }

  function getIndicatorValueText(_iIndicator as Number) as String {
    var sValue = "";
    var fValue;
    var iValue;
    switch(_iIndicator) {
    case GENERAL_VIEW_INDICATOR_ALTITUDE:
      fValue = $.oMyProcessing.fAltitude;
      if(LangUtils.notNaN(fValue)) {
        fValue *= $.oMySettings.fUnitElevationCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case GENERAL_VIEW_INDICATOR_VERTICAL_SPEED:
      fValue = $.oMyProcessing.fVariometer_filtered;
      if(LangUtils.notNaN(fValue)) {
        fValue *= $.oMySettings.fUnitVerticalSpeedCoefficient;
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
      break;
    case GENERAL_VIEW_INDICATOR_WIND_DIRECTION:
      iValue = $.oMyProcessing.iWindDirection;
      if(LangUtils.notNaN(iValue) && $.oMyProcessing.bWindValid) {
        if($.oMySettings.iUnitDirection == 1) {
          sValue = $.oMyProcessing.convertDirection(iValue);
        }
        else {
          sValue = iValue.format("%d");
        }
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case GENERAL_VIEW_INDICATOR_WIND_SPEED:
      fValue = $.oMyProcessing.fWindSpeed;
      if(LangUtils.notNaN(fValue) && $.oMyProcessing.bWindValid) {
        fValue *= $.oMySettings.fUnitWindSpeedCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case GENERAL_VIEW_INDICATOR_FINESSE:
      if(LangUtils.notNaN($.oMyProcessing.fFinesse) && !$.oMyProcessing.bAscent) {
        sValue = $.oMyProcessing.fFinesse.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN2;
      }
      break;
    case GENERAL_VIEW_INDICATOR_HEADING:
      fValue = $.oMyProcessing.fHeading;
      if(LangUtils.notNaN(fValue)) {
        fValue = ((fValue * 57.2957795131f).toNumber()) % 360;
        if($.oMySettings.iUnitDirection == 1) {
          sValue = $.oMyProcessing.convertDirection(fValue);
        }
        else {
          sValue = fValue.format("%d");
        }
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case GENERAL_VIEW_INDICATOR_GROUND_SPEED:
      fValue = $.oMyProcessing.fGroundSpeed;
      if(LangUtils.notNaN(fValue)) {
        fValue *= $.oMySettings.fUnitHorizontalSpeedCoefficient;
        sValue = fValue.format("%.0f");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case GENERAL_VIEW_INDICATOR_ALTITUDE_CHART:
      sValue = "";
      break;
    case GENERAL_VIEW_INDICATOR_HEARTBEAT:
      if(LangUtils.notNaN($.oMyProcessing.iHR)) {
        sValue = ($.oMyProcessing.iHR as Number).format("%d");
      }
      else {
        sValue = $.MY_NOVALUE_LEN3;
      }
      break;
    case GENERAL_VIEW_INDICATOR_FLIGHT_TIME:
      if($.oMyActivity != null) {
        sValue = ($.oMyActivity as MyActivity).getFlightTime();
      }
      else {
        sValue = "--:--";
      }
      break;
    default:
      sValue = "";
    }
    return sValue;
  }

  function isIndicatorValueNumeric(_iIndicator as Number, _sText as String) as Boolean {
    if(_sText == "" or _sText == $.MY_NOVALUE_LEN2 or _sText == $.MY_NOVALUE_LEN3) {
      return false;
    }

    switch(_iIndicator) {
    case GENERAL_VIEW_INDICATOR_WIND_DIRECTION:
    case GENERAL_VIEW_INDICATOR_HEADING:
      return $.oMySettings.iUnitDirection != 1;
    case GENERAL_VIEW_INDICATOR_ALTITUDE:
    case GENERAL_VIEW_INDICATOR_VERTICAL_SPEED:
    case GENERAL_VIEW_INDICATOR_WIND_SPEED:
    case GENERAL_VIEW_INDICATOR_FINESSE:
    case GENERAL_VIEW_INDICATOR_GROUND_SPEED:
    case GENERAL_VIEW_INDICATOR_HEARTBEAT:
      return true;
    default:
      return false;
    }
  }

  function getIndicatorValueFont(_iIndicator as Number, _sText as String) {
    var iLayout = $.oMySettings.getGeneralViewPageLayout($.oMySettings.iGeneralViewActivePageIndex);
    if(iLayout == $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_7) {
      return Gfx.FONT_LARGE;
    }
    if(!self.isIndicatorValueNumeric(_iIndicator, _sText)) {
      return Gfx.FONT_LARGE;
    }
    return Gfx.FONT_NUMBER_MILD;
  }

  function getIndicatorValueColor(_iIndicator as Number, _bRecording as Boolean) as Number {
    var iColor = self.iColorText;
    var fValue;
    switch(_iIndicator) {
    case GENERAL_VIEW_INDICATOR_VERTICAL_SPEED:
      fValue = $.oMyProcessing.fVariometer_filtered;
      if(LangUtils.notNaN(fValue)) {
        fValue *= $.oMySettings.fUnitVerticalSpeedCoefficient;
        if($.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f) {
          if(fValue >= 0.05f) {
            iColor = Gfx.COLOR_DK_GREEN;
          }
          else if(fValue <= -0.05f) {
            iColor = Gfx.COLOR_RED;
          }
        }
        else {
          if(fValue >= 0.5f) {
            iColor = Gfx.COLOR_DK_GREEN;
          }
          else if(fValue <= -0.5f) {
            iColor = Gfx.COLOR_RED;
          }
        }
      }
      else {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case GENERAL_VIEW_INDICATOR_WIND_SPEED:
      if(!_bRecording) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case GENERAL_VIEW_INDICATOR_WIND_DIRECTION:
      if(!($.oMyProcessing.bWindValid && LangUtils.notNaN($.oMyProcessing.iWindDirection))) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case GENERAL_VIEW_INDICATOR_HEADING:
      if(!LangUtils.notNaN($.oMyProcessing.fHeading)) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case GENERAL_VIEW_INDICATOR_ALTITUDE:
      if(!LangUtils.notNaN($.oMyProcessing.fAltitude)) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case GENERAL_VIEW_INDICATOR_GROUND_SPEED:
      if(!LangUtils.notNaN($.oMyProcessing.fGroundSpeed)) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case GENERAL_VIEW_INDICATOR_ALTITUDE_CHART:
      iColor = self.iColorText;
      break;
    case GENERAL_VIEW_INDICATOR_HEARTBEAT:
      if(!LangUtils.notNaN($.oMyProcessing.iHR)) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case GENERAL_VIEW_INDICATOR_FLIGHT_TIME:
      if($.oMyActivity == null or ($.oMyActivity as MyActivity).oTimeStart == null) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    case GENERAL_VIEW_INDICATOR_FINESSE:
      if(!(LangUtils.notNaN($.oMyProcessing.fFinesse) && !$.oMyProcessing.bAscent)) {
        iColor = Gfx.COLOR_LT_GRAY;
      }
      break;
    default:
      iColor = Gfx.COLOR_LT_GRAY;
    }
    return iColor;
  }

  function clearPageField(_iSlot as Number) {
    var sSlot = GENERAL_VIEW_SLOT_NAMES[_iSlot] as String;
    var oLabel = View.findDrawableById("label" + sSlot) as Ui.Text;
    var oUnit = View.findDrawableById("unit" + sSlot) as Ui.Text;
    var oValue = View.findDrawableById("value" + sSlot) as Ui.Text;
    if(oLabel != null) {
      oLabel.setText("");
    }
    if(oUnit != null) {
      oUnit.setText("");
    }
    if(oValue != null) {
      oValue.setText("");
    }
  }

  function updateFieldValue(_iSlot as Number, _iIndicator as Number, _bRecording as Boolean) {
    var sSlot = GENERAL_VIEW_SLOT_NAMES[_iSlot] as String;
    var oValue = View.findDrawableById("value" + sSlot) as Ui.Text;
    if(oValue == null) {
      return;
    }
    if(_iIndicator == $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED) {
      oValue.setText("");
      return;
    }
    var sText = self.getIndicatorValueText(_iIndicator);
    var iColor = self.getIndicatorValueColor(_iIndicator, _bRecording);
    oValue.setFont(Gfx.FONT_LARGE);
    oValue.setColor(iColor);
    oValue.setText(sText);
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    // Sys.println("DEBUG: MyViewGeneral.onUpdate()");

    // Reload layout when active general view page changes so device-specific 2/4/7 layouts apply.
    var iActivePageIndex = $.oMySettings.iGeneralViewActivePageIndex;
    if(iActivePageIndex != self.iCurrentGeneralViewPageIndex) {
      self.iCurrentGeneralViewPageIndex = iActivePageIndex;
      self.onLayout(_oDC);
    }

    // Update layout
    MyViewGlobal.onUpdate(_oDC);
    self.drawAltitudeCharts(_oDC);
    self.drawArrow(_oDC);
  }

  function updateLayout(_b) {
    //Sys.println("DEBUG: MyViewGeneral.updateLayout()");
    MyViewGlobal.updateLayout(true);

    // Update labels/units if the active page changed
    self.updatePageLabels();

    // Colors
    if($.oMyProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.iColorText = Gfx.COLOR_LT_GRAY;
    }
    else if($.oMyProcessing.iAccuracy != Pos.QUALITY_NOT_AVAILABLE) {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
    }

    var bRecording = ($.oMyActivity != null);
    var aFields = $.oMySettings.getGeneralViewPageFields($.oMySettings.iGeneralViewActivePageIndex);
    var iLayout = $.oMySettings.getGeneralViewPageLayout($.oMySettings.iGeneralViewActivePageIndex);

    for(var i=0; i<iLayout; i++) {
      var sSlot = self.getGeneralViewSlotName(i, iLayout);
      var iIndicator = (i < aFields.size()) ? (aFields[i] as Number) : $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED;
      if(iIndicator == $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED) {
        self.clearPageSlot(sSlot);
      }
      else {
        self.updateFieldSlot(sSlot, iIndicator, bRecording);
      }
    }

    if($.oMyProcessing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE) {
      for(var i=0; i<iLayout; i++) {
        var sSlot = self.getGeneralViewSlotName(i, iLayout);
        var oValue = View.findDrawableById("value" + sSlot) as Ui.Text;
        if(oValue != null) {
          oValue.setFont(Gfx.FONT_LARGE);
          oValue.setColor(Gfx.COLOR_LT_GRAY);
          oValue.setText((i == 1 && iLayout == $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_2) ? $.MY_NOVALUE_LEN2 : $.MY_NOVALUE_LEN3);
        }
      }
      return;
    }
  }

  function drawAltitudeChart(_oDC as Gfx.Dc, _sSlot as String) as Void {
    var iLayout = $.oMySettings.getGeneralViewPageLayout($.oMySettings.iGeneralViewActivePageIndex);
    if(iLayout != $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_2) {
      return;
    }

    var iPlotIndex = $.oMyProcessing.iPlotIndex;
    if(iPlotIndex < 0 or $.oMyProcessing.aiPointAltitude.size() < $.oMyProcessing.PLOTBUFFER_SIZE) {
      return;
    }

    var iWidth = _oDC.getWidth();
    var iHeight = _oDC.getHeight();
    var iX1 = (iWidth * 0.14f).toNumber();
    var iX2 = iWidth - iX1;
    var iY1 = (_sSlot.equals("TopLeft") ? (iHeight * 0.29f) : (iHeight * 0.65f)).toNumber();
    var iY2 = (_sSlot.equals("TopLeft") ? (iHeight * 0.46f) : (iHeight * 0.82f)).toNumber();
    var iChartWidth = iX2 - iX1;
    var iChartHeight = iY2 - iY1;

    var iSampleCount = 90;
    if(iSampleCount > $.oMyProcessing.PLOTBUFFER_SIZE) {
      iSampleCount = $.oMyProcessing.PLOTBUFFER_SIZE;
    }

    var iMinAltitude = $.oMyProcessing.aiPointAltitude[iPlotIndex] as Number;
    var iMaxAltitude = iMinAltitude;
    var iValidCount = 0;
    for(var i = 0; i < iSampleCount; i++) {
      var iIndex = (iPlotIndex - i + $.oMyProcessing.PLOTBUFFER_SIZE) % $.oMyProcessing.PLOTBUFFER_SIZE;
      if(($.oMyProcessing.aiPlotEpoch[iIndex] as Number) >= 0) {
        var iAltitude = $.oMyProcessing.aiPointAltitude[iIndex] as Number;
        if(iAltitude < iMinAltitude) {
          iMinAltitude = iAltitude;
        }
        if(iAltitude > iMaxAltitude) {
          iMaxAltitude = iAltitude;
        }
        iValidCount++;
      }
    }
    if(iValidCount < 2) {
      return;
    }

    var fCoef = $.oMySettings.fUnitElevationCoefficient;
    var fMin = iMinAltitude.toFloat();
    var fMax = iMaxAltitude.toFloat();
    var fRangeBorder = 5.0f / fCoef;
    var fRangeMin = fMin - fRangeBorder;
    var fRangeMax = fMax + fRangeBorder;
    var fRangeMinSize = 30.0f / fCoef;
    if(fRangeMax - fRangeMin < fRangeMinSize) {
      fRangeMax = fRangeMin + fRangeMinSize;
    }

    var iLineColor = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY;
    var iBlockColor = $.oMySettings.iGeneralBackgroundColor ? 0x55aaaa : 0x005555;
    var iTextGray = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY;

    _oDC.setClip(iX1, iY1, iChartWidth, iChartHeight);
    _oDC.setPenWidth(1);

    var iLastX = null;
    var iLastY = null;
    for(var iX = iX1; iX <= iX2; iX++) {
      var iSampleOffset = ((iX - iX1) * (iSampleCount - 1)) / iChartWidth;
      var iBack = (iSampleCount - 1) - iSampleOffset;
      var iIndex = (iPlotIndex - iBack + $.oMyProcessing.PLOTBUFFER_SIZE) % $.oMyProcessing.PLOTBUFFER_SIZE;
      if(($.oMyProcessing.aiPlotEpoch[iIndex] as Number) >= 0) {
        var fAltitude = ($.oMyProcessing.aiPointAltitude[iIndex] as Number).toFloat();
        var iY = iY2 - (iChartHeight * (fAltitude - fRangeMin) / (fRangeMax - fRangeMin)).toNumber();
        _oDC.setColor(iBlockColor, Gfx.COLOR_TRANSPARENT);
        _oDC.drawLine(iX, iY, iX, iY2);
        if(iLastX != null) {
          _oDC.setColor(iLineColor, Gfx.COLOR_TRANSPARENT);
          _oDC.drawLine(iLastX, iLastY, iX, iY);
        }
        iLastX = iX;
        iLastY = iY;
      }
      else {
        iLastX = null;
        iLastY = null;
      }
    }

    _oDC.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT);
    self.drawChartTickLine(_oDC, iX1, iY1, iY2, -5, 3, true);
    self.drawChartTickLine(_oDC, iX2, iY1, iY2, 5, 3, true);
    self.drawChartTickLine(_oDC, iY2, iX1, iX2 + 1, 0, 3, false);

    _oDC.clearClip();
    if(LangUtils.notNaN($.oMyProcessing.fAltitude)) {
      var sAltitude = ($.oMyProcessing.fAltitude * $.oMySettings.fUnitElevationCoefficient).format("%.0f");
      _oDC.setColor(iTextGray, Gfx.COLOR_TRANSPARENT);
      _oDC.drawText((iX1 + iX2) / 2, (iY1 + iY2) / 2, Gfx.FONT_TINY, sAltitude, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }
  }

  function drawChartTickLine(_oDC as Gfx.Dc, _iC as Number, _iEnd1 as Number, _iEnd2 as Number, _iTickSize as Number, _iTickCount as Number, _bVertical as Boolean) as Void {
    self.drawChartTickLine0(_oDC, _iC, _iEnd1, _iEnd2, _bVertical);
    for(var i = 1; i <= _iTickCount; i++) {
      self.drawChartTickLine0(_oDC, (((_iTickCount + 1) - i) * _iEnd1 + i * _iEnd2) / (_iTickCount + 1), _iC, _iC + _iTickSize, !_bVertical);
    }
  }

  function drawChartTickLine0(_oDC as Gfx.Dc, _iC as Number, _iEnd1 as Number, _iEnd2 as Number, _bVertical as Boolean) as Void {
    if(_bVertical) {
      _oDC.drawLine(_iC, _iEnd1, _iC, _iEnd2);
    }
    else {
      _oDC.drawLine(_iEnd1, _iC, _iEnd2, _iC);
    }
  }

  function drawAltitudeCharts(_oDC as Gfx.Dc) as Void {
    var iLayout = $.oMySettings.getGeneralViewPageLayout($.oMySettings.iGeneralViewActivePageIndex);
    if(iLayout != $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_2) {
      return;
    }
    var aFields = $.oMySettings.getGeneralViewPageFields($.oMySettings.iGeneralViewActivePageIndex);
    for(var i = 0; i < iLayout; i++) {
      var iIndicator = (i < aFields.size()) ? (aFields[i] as Number) : $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED;
      if(iIndicator == GENERAL_VIEW_INDICATOR_ALTITUDE_CHART) {
        self.drawAltitudeChart(_oDC, self.getGeneralViewSlotName(i, iLayout));
      }
    }
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewGeneral.onHide()");
    MyViewGlobal.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();
  }

  function drawArrow(_oDC as Gfx.Dc) as Void {
    if($.oMyProcessing.bWindValid) {
      var iRadius = _oDC.getWidth()*0.05f;;
      var iCompassX = _oDC.getWidth()/2;
      var iCompassY = _oDC.getHeight()/4;

      // Draw compass arrow
      var fArrowDir = Math.toRadians($.oMyProcessing.iWindDirection + 180) - $.oMyProcessing.fHeading;;

      var fArrowWidth = Math.PI * (1 - 0.15f);
      var fArrowBackLeft = fArrowDir - fArrowWidth;
      var fArrowBackRight = fArrowDir + fArrowWidth;

      var aiiArrow = [
        [iCompassX + iRadius * Math.sin(fArrowDir),     iCompassY - iRadius * Math.cos(fArrowDir)],
        [iCompassX + iRadius * Math.sin(fArrowBackLeft),  iCompassY - iRadius * Math.cos(fArrowBackLeft)],
        [iCompassX + iRadius * 0.2f * Math.sin(fArrowDir + Math.PI),  iCompassY - iRadius * 0.2f * Math.cos(fArrowDir - Math.PI)],
        [iCompassX + iRadius * Math.sin(fArrowBackRight), iCompassY - iRadius * Math.cos(fArrowBackRight)]
      ];

      _oDC.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
      _oDC.fillPolygon(aiiArrow);
    }
  }

}

class MyViewGeneralDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewGeneralDelegate.onPreviousPage()");
    
    // Check if we should cycle to previous general view page
    if($.oMySettings.previousGeneralViewPage()) {
      Ui.requestUpdate();
      return true;
    }
    
    // At first general page, fall through to the previous view
    // Switch to previous view
    if ($.oMyActivity != null) { //Skip the log view if we're recording, e.g. in flight     
        if (Ui has :MapView && $.oMySettings.bMapDisplay) {
            var mapView = new MyViewMap();
            Ui.switchToView(mapView,
                            new MyViewMapDelegate(mapView),
                            Ui.SLIDE_IMMEDIATE);
        } else {
            Ui.switchToView(new MyViewVarioplot(),
            new MyViewVarioplotDelegate(),
            Ui.SLIDE_IMMEDIATE);
        }
    }
    else {
        Ui.switchToView(new MyViewLog(),
            new MyViewLogDelegate(),
            Ui.SLIDE_IMMEDIATE);
    }
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewGeneralDelegate.onNextPage()");
    
    // Check if we should cycle to next general view page
    if($.oMySettings.nextGeneralViewPage()) {
      Ui.requestUpdate();
      return true;
    }
    
    // At last general page, fall through to the next view
    // Otherwise, switch to next view
    Ui.switchToView(new MyViewVariometer(),
                    new MyViewVariometerDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
