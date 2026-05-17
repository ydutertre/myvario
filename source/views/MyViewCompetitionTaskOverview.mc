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
using Toybox.Graphics as Gfx;
using Toybox.Math;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewCompetitionTaskOverview extends Ui.View {

  private var fRefLat as Float = 0.0f;
  private var fRefLon as Float = 0.0f;
  private var fMinX as Float = 0.0f;
  private var fMaxX as Float = 0.0f;
  private var fMinY as Float = 0.0f;
  private var fMaxY as Float = 0.0f;
  private var bBoundsValid as Boolean = false;
  private var iScaleBarSize as Number = 0;
  private var sScaleBarLabel as String = "";

  function initialize() {
    View.initialize();
    self.fitTaskBounds();
  }

  function fitTaskBounds() as Void {
    var task = $.oMyCompetitionTask;
    if(task == null || task.asNames.size() == 0) {
      self.bBoundsValid = false;
      return;
    }

    self.fRefLat = task.afLatitude[0] as Float;
    self.fRefLon = task.afLongitude[0] as Float;
    self.fMinX = 0.0f;
    self.fMaxX = 0.0f;
    self.fMinY = 0.0f;
    self.fMaxY = 0.0f;

    for(var i=0; i<task.asNames.size(); i++) {
      var fLat = task.afLatitude[i] as Float;
      var fLon = task.afLongitude[i] as Float;
      var fRadius = task.afRadius[i] as Float;
      var aMeters = task.toLocalMeters(fLat, fLon, self.fRefLat, self.fRefLon);
      var fX = aMeters[0] as Float;
      var fY = aMeters[1] as Float;
      self.includeMeters(fX - fRadius, fY - fRadius);
      self.includeMeters(fX + fRadius, fY + fRadius);
    }

    var fXSpan = self.fMaxX - self.fMinX;
    var fYSpan = self.fMaxY - self.fMinY;
    if(fXSpan < 1000.0f) {
      fXSpan = 1000.0f;
    }
    if(fYSpan < 1000.0f) {
      fYSpan = 1000.0f;
    }
    var fScreenAspect = Sys.getDeviceSettings().screenWidth.toFloat() / Sys.getDeviceSettings().screenHeight.toFloat();
    var fBoundsAspect = fXSpan / fYSpan;
    if(fBoundsAspect > fScreenAspect) {
      var fTargetYSpan = fXSpan / fScreenAspect;
      self.fMinY -= (fTargetYSpan - fYSpan) * 0.5f;
      self.fMaxY += (fTargetYSpan - fYSpan) * 0.5f;
      fYSpan = fTargetYSpan;
    }
    else {
      var fTargetXSpan = fYSpan * fScreenAspect;
      self.fMinX -= (fTargetXSpan - fXSpan) * 0.5f;
      self.fMaxX += (fTargetXSpan - fXSpan) * 0.5f;
      fXSpan = fTargetXSpan;
    }
    self.fMinX -= fXSpan * 0.18f;
    self.fMaxX += fXSpan * 0.18f;
    self.fMinY -= fYSpan * 0.18f;
    self.fMaxY += fYSpan * 0.18f;
    self.bBoundsValid = true;
  }

  function includeMeters(_fX as Float, _fY as Float) as Void {
    if(_fX < self.fMinX) {
      self.fMinX = _fX;
    }
    if(_fX > self.fMaxX) {
      self.fMaxX = _fX;
    }
    if(_fY < self.fMinY) {
      self.fMinY = _fY;
    }
    if(_fY > self.fMaxY) {
      self.fMaxY = _fY;
    }
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    var iBackground = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_WHITE : Gfx.COLOR_BLACK;
    _oDC.setColor(iBackground, iBackground);
    _oDC.clear();
    self.drawTaskOverlay(_oDC);
  }

  function drawTaskOverlay(_oDC as Gfx.Dc) as Void {
    var task = $.oMyCompetitionTask;
    var iText = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_BLACK : Gfx.COLOR_WHITE;
    if(task == null || task.asNames.size() == 0 || !self.bBoundsValid) {
      _oDC.setColor(iText, Gfx.COLOR_TRANSPARENT);
      _oDC.drawText(_oDC.getWidth() / 2, _oDC.getHeight() / 2, Gfx.FONT_SMALL, "No task", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
      return;
    }

    var iLegColor = Gfx.COLOR_BLUE;
    var iCylinderColor = $.oMySettings.iGeneralBackgroundColor ? Gfx.COLOR_DK_GRAY : Gfx.COLOR_LT_GRAY;
    var iStartColor = Gfx.COLOR_DK_GREEN;
    var iGoalColor = Gfx.COLOR_RED;

    self.drawOptimizedTaskPath(_oDC, task, iLegColor);

    for(var j=0; j<task.asNames.size(); j++) {
      var iColor = iCylinderColor;
      if(j == task.iStartIndex) {
        iColor = iStartColor;
      }
      if(j == task.iGoalIndex || j == task.iEssIndex) {
        iColor = iGoalColor;
      }
      self.drawCylinder(_oDC, task, j, iColor);
      var aCenter = self.project(task.afLatitude[j] as Float, task.afLongitude[j] as Float, _oDC);
      _oDC.setColor(iColor, Gfx.COLOR_TRANSPARENT);
      _oDC.fillCircle(aCenter[0] as Number, aCenter[1] as Number, 3);
      self.drawWaypointLabel(_oDC, task, j, aCenter[0] as Number, aCenter[1] as Number, iColor);
    }
    self.drawScaleBar(_oDC, iText);
  }

  function drawScaleBar(_oDC as Gfx.Dc, _iColor as Number) as Void {
    self.calculateScaleBar((_oDC.getWidth() * 0.28f).toNumber(), (_oDC.getWidth().toFloat() / (self.fMaxX - self.fMinX)));
    if(self.iScaleBarSize <= 0) {
      return;
    }
    var iY = (_oDC.getHeight() * 0.82f).toNumber();
    var iXStart = ((_oDC.getWidth() - self.iScaleBarSize) * 0.5f).toNumber();
    var iXEnd = iXStart + self.iScaleBarSize;
    _oDC.setColor(_iColor, Gfx.COLOR_TRANSPARENT);
    _oDC.setPenWidth(2);
    _oDC.drawLine(iXStart, iY, iXEnd, iY);
    _oDC.drawLine(iXStart, iY, iXStart, iY - 3);
    _oDC.drawLine(iXEnd, iY, iXEnd, iY - 3);
    _oDC.drawText(_oDC.getWidth() / 2, iY - Gfx.getFontHeight(Gfx.FONT_XTINY), Gfx.FONT_XTINY, self.sScaleBarLabel, Gfx.TEXT_JUSTIFY_CENTER);
    _oDC.setPenWidth(1);
  }

  function calculateScaleBar(_iMaxBarSize as Number, _fPixelsPerMeter as Float) as Void {
    var fMaxMeters = _iMaxBarSize / _fPixelsPerMeter;
    var aiNiceMeters = [50000, 20000, 10000, 5000, 2000, 1000, 500, 200, 100, 50, 20, 10];
    for(var i=0; i<aiNiceMeters.size(); i++) {
      var iMeters = aiNiceMeters[i] as Number;
      if(iMeters <= fMaxMeters) {
        self.iScaleBarSize = (iMeters * _fPixelsPerMeter).toNumber();
        var fDisplay = iMeters * $.oMySettings.fUnitDistanceCoefficient;
        if(fDisplay >= 1.0f || $.oMySettings.sUnitDistance.equals("m")) {
          self.sScaleBarLabel = fDisplay.format("%.0f") + $.oMySettings.sUnitDistance;
        }
        else {
          self.sScaleBarLabel = iMeters.format("%d") + "m";
        }
        return;
      }
    }
    self.iScaleBarSize = 0;
    self.sScaleBarLabel = "";
  }

  function drawWaypointLabel(_oDC as Gfx.Dc, _task as MyCompetitionTask, _iIndex as Number, _iX as Number, _iY as Number, _iColor as Number) as Void {
    if(_iIndex == _task.iGoalIndex && _iIndex != _task.iEssIndex && _task.iEssIndex >= 0) {
      return;
    }
    var sLabel = _task.getTurnpointTypeLabel(_iIndex);
    if(sLabel.equals("ESS/Goal")) {
      sLabel = "ESS/G";
    }
    else if(sLabel.equals("Goal")) {
      sLabel = "G";
    }
    var iOffsetX = 0;
    var iOffsetY = -14;
    if(_iIndex == _task.iStartIndex) {
      iOffsetX = -12;
      iOffsetY = -4;
    }
    else if(_iIndex == _task.iEssIndex || _iIndex == _task.iGoalIndex) {
      iOffsetX = 0;
      iOffsetY = 10;
    }
    _oDC.setColor(_iColor, Gfx.COLOR_TRANSPARENT);
    _oDC.drawText(_iX + iOffsetX, _iY + iOffsetY, Gfx.FONT_XTINY, sLabel, Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
  }

  function drawOptimizedTaskPath(_oDC as Gfx.Dc, _task as MyCompetitionTask, _iColor as Number) as Void {
    var iStart = _task.iStartIndex >= 0 ? _task.iStartIndex : _task.nextNavigableIndex(-1);
    if(iStart < 0 || iStart >= _task.asNames.size()) {
      return;
    }

    var iCurrent = iStart;
    var iNext = _task.nextNavigableIndex(iCurrent);
    if(iNext >= _task.asNames.size() || iNext > _task.iGoalIndex) {
      return;
    }

    var aPreviousTarget = _task.getOptimizedCylinderPoint(_task.afLatitude[iCurrent] as Float, _task.afLongitude[iCurrent] as Float, iCurrent, iNext);
    while(iNext < _task.asNames.size() && iNext <= _task.iGoalIndex) {
      var iAfter = _task.nextNavigableIndex(iNext);
      var aNextTarget;
      if(iAfter < _task.asNames.size() && iAfter <= _task.iGoalIndex) {
        aNextTarget = _task.getOptimizedCylinderPoint(aPreviousTarget[0] as Float, aPreviousTarget[1] as Float, iNext, iAfter);
      }
      else {
        var fBearing = _task.bearingRadians(_task.afLatitude[iNext] as Float, _task.afLongitude[iNext] as Float, aPreviousTarget[0] as Float, aPreviousTarget[1] as Float);
        aNextTarget = _task.destination(_task.afLatitude[iNext] as Float, _task.afLongitude[iNext] as Float, fBearing, _task.afRadius[iNext] as Float);
      }

      var aFrom = self.project(aPreviousTarget[0] as Float, aPreviousTarget[1] as Float, _oDC);
      var aTo = self.project(aNextTarget[0] as Float, aNextTarget[1] as Float, _oDC);
      _oDC.setColor(_iColor, Gfx.COLOR_TRANSPARENT);
      _oDC.drawLine(aFrom[0] as Number, aFrom[1] as Number, aTo[0] as Number, aTo[1] as Number);
      self.drawLegArrow(_oDC, aFrom[0] as Number, aFrom[1] as Number, aTo[0] as Number, aTo[1] as Number, _iColor);

      iCurrent = iNext;
      iNext = iAfter;
      aPreviousTarget = aNextTarget;
    }
  }

  function drawCylinder(_oDC as Gfx.Dc, _task as MyCompetitionTask, _iIndex as Number, _iColor as Number) as Void {
    _oDC.setColor(_iColor, Gfx.COLOR_TRANSPARENT);
    var aFirst = null;
    var aLast = null;
    for(var i=0; i<=24; i++) {
      var fBearing = Math.PI * 2.0f * i / 24.0f;
      var aGeo = _task.destination(_task.afLatitude[_iIndex] as Float, _task.afLongitude[_iIndex] as Float, fBearing, _task.afRadius[_iIndex] as Float);
      var aScreen = self.project(aGeo[0] as Float, aGeo[1] as Float, _oDC);
      if(aLast != null) {
        _oDC.drawLine((aLast as Array)[0] as Number, (aLast as Array)[1] as Number, aScreen[0] as Number, aScreen[1] as Number);
      }
      else {
        aFirst = aScreen;
      }
      aLast = aScreen;
    }
    if(aFirst != null && aLast != null) {
      _oDC.drawLine((aLast as Array)[0] as Number, (aLast as Array)[1] as Number, (aFirst as Array)[0] as Number, (aFirst as Array)[1] as Number);
    }
  }

  function drawLegArrow(_oDC as Gfx.Dc, _iX1 as Number, _iY1 as Number, _iX2 as Number, _iY2 as Number, _iColor as Number) as Void {
    var fX = _iX1 + (_iX2 - _iX1) * 0.65f;
    var fY = _iY1 + (_iY2 - _iY1) * 0.65f;
    var fAngle = Math.atan2((_iY2 - _iY1).toFloat(), (_iX2 - _iX1).toFloat());
    var fSize = 7.0f;
    var aiiArrow = [
      [fX + Math.cos(fAngle) * fSize, fY + Math.sin(fAngle) * fSize],
      [fX + Math.cos(fAngle + 2.55f) * fSize, fY + Math.sin(fAngle + 2.55f) * fSize],
      [fX + Math.cos(fAngle - 2.55f) * fSize, fY + Math.sin(fAngle - 2.55f) * fSize]
    ];
    _oDC.setColor(_iColor, Gfx.COLOR_TRANSPARENT);
    _oDC.fillPolygon(aiiArrow);
  }

  function project(_fLat as Float, _fLon as Float, _oDC as Gfx.Dc) as Array<Number> {
    var aMeters = ($.oMyCompetitionTask as MyCompetitionTask).toLocalMeters(_fLat, _fLon, self.fRefLat, self.fRefLon);
    var x = (((aMeters[0] as Float) - self.fMinX) / (self.fMaxX - self.fMinX) * _oDC.getWidth()).toNumber();
    var y = ((self.fMaxY - (aMeters[1] as Float)) / (self.fMaxY - self.fMinY) * _oDC.getHeight()).toNumber();
    return [x, y];
  }
}

class MyViewCompetitionTaskOverviewDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onBack() as Boolean {
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }
}
