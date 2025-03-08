// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (C) 2022 Yannick Dutertre <https://yannickd9.wixsite.com/myvario>
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
    if (_context == :contextSounds) {
      if (_item == :itemSoundsToneDriver) {
        var iSoundToneDriver = $.oMySettings.loadSoundsToneDriver();
        var oFactory = new PickerFactoryDictionary([0, 1], ["Buzzer", "Speaker"], null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleSoundsToneDriver) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iSoundToneDriver)]});
      }
    }
    else if(_context == :contextVariometer) {

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

      else if(_item == :itemSmoothing) {
        var iVariometerSmoothing = $.oMySettings.loadVariometerSmoothing();
        $.oMySettings.load();  // ... reload potentially modified settings
        var asValues = [Ui.loadResource(Rez.Strings.valueVariometerSmoothingLow),Ui.loadResource(Rez.Strings.valueVariometerSmoothingMedium),Ui.loadResource(Rez.Strings.valueVariometerSmoothingHigh),Ui.loadResource(Rez.Strings.valueVariometerSmoothingUltra)];
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3], asValues, {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleVariometerSmoothing) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iVariometerSmoothing)]});
      }

      else if(_item == :itemPlotRange) {
        var iVariometerPlotRange = $.oMySettings.loadVariometerPlotRange();
        var oFactory = new PickerFactoryNumber(1, 3, null);
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

      else if(_item == :itemPlotOrientation) {
          var iVariometerPlotOrientation = $.oMySettings.loadVariometerPlotOrientation();
          var oFactory = new PickerFactoryDictionary([0, 1], ["North up", "HDG up"], null);
          Picker.initialize({
              :title => new Ui.Text({
                  :text => Ui.loadResource(Rez.Strings.titleVariometerPlotOrientation) as String,
                  :font => Gfx.FONT_TINY,
                  :locX=>Ui.LAYOUT_HALIGN_CENTER,
                  :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                  :color => Gfx.COLOR_BLUE}),
              :pattern => [oFactory],
              :defaults => [oFactory.indexOfKey(iVariometerPlotOrientation)]});
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
      else if(_item == :itemMinimumSink) {
        var iMinimumSink = $.oMySettings.loadMinimumSink();
        $.oMySettings.load();  // ... reload potentially modified settings
        var sFormat = $.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f ? "%.01f" : "%.0f";
        var asValues =
          [format("$1$\n$2$", [(-1.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(-2.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(-3.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(-4.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(-6.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]),
            format("$1$\n$2$", [(-10.0f*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed])];
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3, 4, 5], asValues, {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleMinimumSink) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iMinimumSink)]});
      }
      else if(_item == :itemActivityType) {
        var iActivityType = $.oMySettings.loadActivityType();
        $.oMySettings.load();  // ... reload potentially modified settings
        var asValues = [Ui.loadResource(Rez.Strings.valueActivityTypeFlight),Ui.loadResource(Rez.Strings.valueActivityTypeHike),Ui.loadResource(Rez.Strings.valueActivityTypeHG)];
        var oFactory = new PickerFactoryDictionary([0, 1, 2], asValues, {:font => Gfx.FONT_TINY});
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleActivityType) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iActivityType)]});
      }
    }
    else if(_context == :contextGeneral) {

      if(_item == :itemBackgroundColor) {
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
      } else if (_item == :itemWindSpeed) {
        var iUnitWindSpeed = $.oMySettings.loadUnitWindSpeed();
        var oFactory = new PickerFactoryDictionary([-1, 0, 1, 2, 3],
                                                   [Ui.loadResource(Rez.Strings.valueAuto), "km/h", "mph", "kt", "m/s"],
                                                   null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleUnitWindSpeed) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iUnitWindSpeed)]});
      }
    }
    else if (_context == :contextLivetrack) {
      if(_item == :itemLivetrack24Frequency) {
        var iLivetrack24Frequency = $.oMySettings.loadLivetrack24Frequency();
        $.oMySettings.load();  // ... reload potentially modified settings
        var asValues = ["Off", "2s", "5s", "15s", "30s", "60s", "120s", "180s", "300s"];
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3, 4, 5, 6, 7, 8], asValues, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleLivetrack24Frequency) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iLivetrack24Frequency)]});
      }
      else if(_item == :itemSportsTrackLiveFrequency) {
        var iSportsTrackLiveFrequency = $.oMySettings.loadSportsTrackLiveFrequency();
        $.oMySettings.load();  // ... reload potentially modified settings
        var asValues = ["Off", "2s", "5s", "15s", "30s", "60s", "120s", "180s", "300s"];
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3, 4, 5, 6, 7, 8], asValues, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleSportsTrackLiveFrequency) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iSportsTrackLiveFrequency)]});
      }
      else if(_item == :itemFlySafeLivetrackFrequency) {
        var iFlySafeLivetrackFrequency = $.oMySettings.loadFlySafeLivetrackFrequency();
        $.oMySettings.load();  // ... reload potentially modified settings
        var asValues = ["Off", "10s", "15s", "20s", "30s", "60s", "120s", "180s", "300s"];
        var oFactory = new PickerFactoryDictionary([0, 1, 2, 3, 4, 5, 6, 7, 8], asValues, null);
        Picker.initialize({
            :title => new Ui.Text({
                :text => Ui.loadResource(Rez.Strings.titleFlySafeLivetrackFrequency) as String,
                :font => Gfx.FONT_TINY,
                :locX=>Ui.LAYOUT_HALIGN_CENTER,
                :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
                :color => Gfx.COLOR_BLUE}),
            :pattern => [oFactory],
            :defaults => [oFactory.indexOfKey(iFlySafeLivetrackFrequency)]});
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
    if (self.context == :contextSounds) {
      if (self.item == :itemSoundsToneDriver) {
        $.oMySettings.saveSoundsToneDriver(_amValues[0] as Number);
      }
    }
    else if(self.context == :contextVariometer) {

      if(self.item == :itemRange) {
        $.oMySettings.saveVariometerRange(_amValues[0] as Number);
      }
      else if(self.item == :itemSmoothing) {
        $.oMySettings.saveVariometerSmoothing(_amValues[0] as Number);
      }
      else if(self.item == :itemPlotRange) {
        $.oMySettings.saveVariometerPlotRange(_amValues[0] as Number);
      }
      else if(self.item == :itemPlotOrientation) {
        $.oMySettings.saveVariometerPlotOrientation(_amValues[0] as Number);
      }
    }
    else if(self.context == :contextSettings) {
      if(self.item == :itemMinimumClimb) {
        $.oMySettings.saveMinimumClimb(_amValues[0] as Number);
      }
      else if(self.item == :itemMinimumSink) {
        $.oMySettings.saveMinimumSink(_amValues[0] as Number);
      }
      else if(self.item == :itemActivityType) {
        $.oMySettings.saveActivityType(_amValues[0] as Number);
      }
    }
    else if(self.context == :contextGeneral) {

      if(self.item == :itemBackgroundColor) {
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
      else if(self.item == :itemWindSpeed) {
        $.oMySettings.saveUnitWindSpeed(_amValues[0] as Number);
      }
      $.oMySettings.load();  // ... use proper units in settings

    }
    else if(self.context == :contextLivetrack) {
      if(self.item == :itemLivetrack24Frequency) {
        $.oMySettings.saveLivetrack24Frequency(_amValues[0] as Number);
      }
      else if(self.item == :itemSportsTrackLiveFrequency) {
        $.oMySettings.saveSportsTrackLiveFrequency(_amValues[0] as Number);
      }
      else if(self.item == :itemFlySafeLivetrackFrequency) {
        $.oMySettings.saveFlySafeLivetrackFrequency(_amValues[0] as Number);
      }
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
