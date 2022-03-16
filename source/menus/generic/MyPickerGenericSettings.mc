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
using Toybox.WatchUi as Ui;

class MyPickerGenericSettings extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    if(_context == :contextVariometer) {

      if(_item == :itemRange) {
        var iVariometerRange = $.oMySettings.loadVariometerRange();
        $.oMySettings.load();  // ... reload potentially modified settings
        var sFormat = $.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f ? "%.01f" : "%.0f";
        var asValues =
          [format("$1$\n$2$", [(3.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(6.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(9.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed])];
        var oFactory = new PickerFactoryDictionary([0, 1, 2], asValues, {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleVariometerRange) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iVariometerRange)]});
      }
      else if(_item == :itemMode) {
        var iVariometerMode = $.oMySettings.loadVariometerMode();
        var oFactory = new PickerFactoryDictionary([0, 1],
                                                   [Ui.loadResource(Rez.Strings.valueVariometerModeAltitude),
                                                    Ui.loadResource(Rez.Strings.valueVariometerModeEnergy)],
                                                   {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleVariometerMode) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iVariometerMode)]});
      }
      else if(_item == :itemEnergyEfficiency) {
        var iVariometerEnergyEfficiency = $.oMySettings.loadVariometerEnergyEfficiency();
        var oFactory = new PickerFactoryNumber(0, 100, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$ [%]", [Ui.loadResource(Rez.Strings.titleVariometerEnergyEfficiency)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOf(iVariometerEnergyEfficiency)]});
      }
      else if(_item == :itemPlotRange) {
        var iVariometerPlotRange = $.oMySettings.loadVariometerPlotRange();
        var oFactory = new PickerFactoryNumber(1, 5, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$ [min]", [Ui.loadResource(Rez.Strings.titleVariometerPlotRange)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOf(iVariometerPlotRange)]});
      }

    }
    else if (_context == :contextSettings) {
      if(_item == :itemMinimumClimb) {
        var iMinimumClimb = $.oMySettings.loadMinimumClimb();
        $.oMySettings.load();  // ... reload potentially modified settings
        var sFormat = $.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f ? "%.01f" : "%.0f";
        var asValues =
          [format("$1$\n$2$", [(0.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(0.1f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(0.2f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(0.3f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(0.4f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(0.5f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed])];
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3, 4, 5], asValues, {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleMinimumClimb) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iMinimumClimb)]});
      }
    }
    else if(_context == :contextGeneral) {

      if(_item == :itemTimeConstant) {
        var iGeneralTimeConstant = $.oMySettings.loadGeneralTimeConstant();
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3, 4, 5, 10, 15, 20, 25, 30, 45, 60],
                                                   ["0", "1", "2", "3", "4", "5", "10", "15", "20", "25", "30", "45", "60"],
                                                   null);
        var iIndex = oFactory.indexOfKey(iGeneralTimeConstant);
        if(iIndex < 0) {
          iIndex = 5;
        }
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$ [s]", [Ui.loadResource(Rez.Strings.titleGeneralTimeConstant)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [iIndex]});
      }
      else if(_item == :itemDisplayFilter) {
        var iGeneralDisplayFilter = $.oMySettings.loadGeneralDisplayFilter();
        var oFactory = new PickerFactoryDictionary([0, 1, 2],
                                                   [Ui.loadResource(Rez.Strings.valueOff),
                                                    Ui.loadResource(Rez.Strings.valueGeneralDisplayFilterTimeDerived),
                                                    Ui.loadResource(Rez.Strings.valueAll)],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => format("$1$", [Ui.loadResource(Rez.Strings.titleGeneralDisplayFilter)]),
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iGeneralDisplayFilter)]});
      }
      else if(_item == :itemBackgroundColor) {
        var iColor = $.oMySettings.loadGeneralBackgroundColor();
        var oFactory = new PickerFactoryDictionary([Gfx.COLOR_WHITE, Gfx.COLOR_BLACK],
                                                   [Ui.loadResource(Rez.Strings.valueColorWhite),
                                                    Ui.loadResource(Rez.Strings.valueColorBlack)],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleGeneralBackgroundColor) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iColor)]});
      }

    }
    else if(_context == :contextUnit) {

      if(_item == :itemDistance) {
        var iUnitDistance = $.oMySettings.loadUnitDistance();
        var oFactory = new PickerFactoryDictionary([-1, 0, 1 ,2],
                                                   [Ui.loadResource(Rez.Strings.valueAuto), "km", "sm", "nm"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitDistance) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitDistance)]});
      }
      else if(_item == :itemElevation) {
        var iUnitElevation = $.oMySettings.loadUnitElevation();
        var oFactory = new PickerFactoryDictionary([-1, 0, 1],
                                                   [Ui.loadResource(Rez.Strings.valueAuto), "m", "ft"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitElevation) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitElevation)]});
      }
      else if(_item == :itemPressure) {
        var iUnitPressure = $.oMySettings.loadUnitPressure();
        var oFactory = new PickerFactoryDictionary([-1, 0, 1],
                                                   [Ui.loadResource(Rez.Strings.valueAuto), "mb", "inHg"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitPressure) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitPressure)]});
      }
      else if(_item == :itemDirection) {
        var iUnitDirection = $.oMySettings.loadUnitDirection();
        var oFactory = new PickerFactoryDictionary([0, 1],
                                                   ["°", "txt"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitDirection) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitDirection)]});
      }
      else if(_item == :itemTimeUTC) {
        var bUnitTimeUTC = $.oMySettings.loadUnitTimeUTC();
        var oFactory = new PickerFactoryDictionary([false, true],
                                                   [Ui.loadResource(Rez.Strings.valueUnitTimeLT),
                                                    Ui.loadResource(Rez.Strings.valueUnitTimeUTC)],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitTimeUTC) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(bUnitTimeUTC)]});
      }

    }
  }

}

class MyPickerGenericSettingsDelegate extends Ui.PickerDelegate {

  //
  // VARIABLES
  //

  private var context as Symbol = :contextNone;
  private var item as Symbol = :itemNone;


  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize(_context as Symbol, _item as Symbol) {
    PickerDelegate.initialize();
    self.context = _context;
    self.item = _item;
  }

  function onAccept(_amValues) {
    if(self.context == :contextVariometer) {

      if(self.item == :itemRange) {
        $.oMySettings.saveVariometerRange(_amValues[0] as Number);
      }
      else if(self.item == :itemMode) {
        $.oMySettings.saveVariometerMode(_amValues[0] as Number);
      }
      else if(self.item == :itemEnergyEfficiency) {
        $.oMySettings.saveVariometerEnergyEfficiency(_amValues[0] as Number);
      }
      else if(self.item == :itemPlotRange) {
        $.oMySettings.saveVariometerPlotRange(_amValues[0] as Number);
      }

    }
    else if(self.context == :contextSettings) {
      if(self.item == :itemMinimumClimb) {
        $.oMySettings.saveMinimumClimb(_amValues[0] as Number);
      }
    }
    else if(self.context == :contextGeneral) {

      if(self.item == :itemTimeConstant) {
        $.oMySettings.saveGeneralTimeConstant(_amValues[0] as Number);
      }
      else if(self.item == :itemDisplayFilter) {
        $.oMySettings.saveGeneralDisplayFilter(_amValues[0] as Number);
      }
      else if(self.item == :itemBackgroundColor) {
        $.oMySettings.saveGeneralBackgroundColor(_amValues[0] as Number);
      }

    }
    else if(self.context == :contextUnit) {

      if(self.item == :itemDistance) {
        $.oMySettings.saveUnitDistance(_amValues[0] as Number);
      }
      else if(self.item == :itemElevation) {
        $.oMySettings.saveUnitElevation(_amValues[0] as Number);
      }
      else if(self.item == :itemPressure) {
        $.oMySettings.saveUnitPressure(_amValues[0] as Number);
      }
      else if(self.item == :itemDirection) {
        $.oMySettings.saveUnitDirection(_amValues[0] as Number);
      }
      else if(self.item == :itemTimeUTC) {
        $.oMySettings.saveUnitTimeUTC(_amValues[0] as Boolean);
      }
      $.oMySettings.load();  // ... use proper units in settings

    }
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
