// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (c) 2025 Yannick Dutertre <https://yannickd9.wixsite.com/myvario>
//
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
using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Graphics as Gfx;

class MyMenu2Generic extends Ui.Menu2 {
  private var menu as Symbol = :menuNone;
  (:icon) var NoExclude as Symbol = :NoExclude;
  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function getFieldIndexFromMenuItemId(_itemId as Symbol) as Number {
    switch(_itemId) {
    case :menuGeneralViewPageField0: return 0;
    case :menuGeneralViewPageField1: return 1;
    case :menuGeneralViewPageField2: return 2;
    case :menuGeneralViewPageField3: return 3;
    case :menuGeneralViewPageField4: return 4;
    case :menuGeneralViewPageField5: return 5;
    case :menuGeneralViewPageField6: return 6;
    default: return -1;
    }
  }

  function initialize(_menu as Symbol, _focus as Number) {
    Menu2.initialize({:focus=>_focus});
    menu = _menu;
    $.oMySettings.load();
    var sFormat = $.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f ? "%.1f" : "%.0f";
    
    if(menu == :menuSettings) {
      Menu2.setTitle((self has :NoExclude)?(new $.DrawableMenu(:title)):Rez.Strings.titleSettings);
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsGeneral, null, :menuSettingsGeneral, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsAltimeter, null, :menuSettingsAltimeter, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsVariometer, null, :menuSettingsVariometer, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsSounds, null, :menuSettingsSounds, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsActivity, null, :menuSettingsActivity, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsLivetrack, null, :menuSettingsLivetrack, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsUnits, null, :menuSettingsUnits, {}));
      if (Ui has :MapView) {
        Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSettingsMapView, null, :menuSettingsMapView, {}));
      }
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleAbout, null, :menuAbout, {}));
    }

    else if(menu == :menuSettingsGeneral) {
      Menu2.setTitle(Rez.Strings.titleSettingsGeneral);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleGeneralBackgroundColor, {:enabled=>Ui.loadResource(Rez.Strings.valueColorBlack), :disabled=>Ui.loadResource(Rez.Strings.valueColorWhite)}, :menuGeneralBackgroundColor, ($.oMySettings.iGeneralBackgroundColor?false:true), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleActiveLook, null, :menuActiveLook, $.oMySettings.bActiveLook, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleVectorVario, null, :menuVectorVario, $.oMySettings.bVectorVario, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleGPS, {:enabled=>Ui.loadResource(Rez.Strings.valueGPSBest), :disabled=>Ui.loadResource(Rez.Strings.valueGPSNormal)}, :menuGPS, ($.oMySettings.iGPS?false:true), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem("General View Pages", null, :menuGeneralViewPages, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleStorageClearLogs, null, :menuStorageClearLogs, {}));
    }

    else if(menu == :menuGeneralViewPages) {
      Menu2.setTitle("General View Pages");
      Sys.println("DEBUG: menuGeneralViewPages - Page count: " + $.oMySettings.getGeneralViewPageCount());
      var iPageCount = $.oMySettings.getGeneralViewPageCount();
      for(var i=0; i<iPageCount; i++) {
        var iLayout = $.oMySettings.getGeneralViewPageLayout(i);
        var sPageName = $.oMySettings.getGeneralViewPageName(i);
        var sLayoutLabel = iLayout == 2 ? "2" : (iLayout == 4 ? "4" : "7");
        Sys.println("DEBUG:   Adding page " + i + ": '" + sPageName + "' (" + sLayoutLabel + ")");
        var pageItemId = :menuGeneralViewPageEdit0;
        if(i == 1) { pageItemId = :menuGeneralViewPageEdit1; }
        else if(i == 2) { pageItemId = :menuGeneralViewPageEdit2; }
        else if(i == 3) { pageItemId = :menuGeneralViewPageEdit3; }
        else if(i == 4) { pageItemId = :menuGeneralViewPageEdit4; }
        else if(i == 5) { pageItemId = :menuGeneralViewPageEdit5; }
        else if(i == 6) { pageItemId = :menuGeneralViewPageEdit6; }
        else if(i == 7) { pageItemId = :menuGeneralViewPageEdit7; }
        else if(i == 8) { pageItemId = :menuGeneralViewPageEdit8; }
        else if(i == 9) { pageItemId = :menuGeneralViewPageEdit9; }
        Menu2.addItem(new Ui.MenuItem(sPageName + " (" + sLayoutLabel + ")", null, pageItemId, {}));
      }
      if(iPageCount < 10) {
        Menu2.addItem(new Ui.MenuItem("Add Page", null, :menuGeneralViewPageAdd, {}));
      }
    }

    else if(menu == :menuGeneralViewPageAdd) {
      Menu2.setTitle("Select Layout");
      Menu2.addItem(new Ui.MenuItem("2 Indicators", null, :menuGeneralViewPageLayout2, {}));
      Menu2.addItem(new Ui.MenuItem("4 Indicators", null, :menuGeneralViewPageLayout4, {}));
      Menu2.addItem(new Ui.MenuItem("7 Indicators", null, :menuGeneralViewPageLayout7, {}));
    }

    else if(menu == :menuGeneralViewPageEdit) {
      var iPageIndex = $.oMySettings.iGeneralViewEditingPageIndex;
      var sPageName = $.oMySettings.getGeneralViewPageName(iPageIndex);
      var aFields = $.oMySettings.getGeneralViewPageFields(iPageIndex);
      var iFieldCount = $.oMySettings.getGeneralViewPageLayout(iPageIndex);
      if(iFieldCount > aFields.size()) {
        iFieldCount = aFields.size();
      }
      Menu2.setTitle("Edit: " + sPageName);
      for(var i = 0; i < iFieldCount; i++) {
        var iIndicator = aFields[i] as Number;
        var sIndicatorLabel = "";
        if(iIndicator == $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED) {
          sIndicatorLabel = "None";
        } else if(iIndicator == 0) {
          sIndicatorLabel = "Wind Direction";
        } else if(iIndicator == 1) {
          sIndicatorLabel = "Wind Speed";
        } else if(iIndicator == 2) {
          sIndicatorLabel = "Altitude";
        } else if(iIndicator == 3) {
          sIndicatorLabel = "Finesse";
        } else if(iIndicator == 4) {
          sIndicatorLabel = "Heading";
        } else if(iIndicator == 5) {
          sIndicatorLabel = "Vert. Speed";
        } else if(iIndicator == 6) {
          sIndicatorLabel = "Ground Speed";
        } else if(iIndicator == 7) {
          sIndicatorLabel = "Altitude Chart";
        } else if(iIndicator == 8) {
          sIndicatorLabel = "Heartbeat";
        }
        var fieldItemId = :menuGeneralViewPageField0;
        if(i == 1) { fieldItemId = :menuGeneralViewPageField1; }
        else if(i == 2) { fieldItemId = :menuGeneralViewPageField2; }
        else if(i == 3) { fieldItemId = :menuGeneralViewPageField3; }
        else if(i == 4) { fieldItemId = :menuGeneralViewPageField4; }
        else if(i == 5) { fieldItemId = :menuGeneralViewPageField5; }
        else if(i == 6) { fieldItemId = :menuGeneralViewPageField6; }
        Menu2.addItem(new Ui.MenuItem("Field " + (i+1), sIndicatorLabel, fieldItemId, {}));
      }
      Menu2.addItem(new Ui.MenuItem("Delete", null, :menuGeneralViewPageDelete, {}));
    }

    else if(self.getFieldIndexFromMenuItemId(menu) >= 0) {
      Menu2.setTitle("Field " + (self.getFieldIndexFromMenuItemId(menu) + 1));
      Menu2.addItem(new Ui.MenuItem("Wind Direction", null, :menuGeneralViewPageIndicator0, {}));
      Menu2.addItem(new Ui.MenuItem("Wind Speed", null, :menuGeneralViewPageIndicator1, {}));
      Menu2.addItem(new Ui.MenuItem("Altitude", null, :menuGeneralViewPageIndicator2, {}));
      Menu2.addItem(new Ui.MenuItem("Finesse (Glide Ratio)", null, :menuGeneralViewPageIndicator3, {}));
      Menu2.addItem(new Ui.MenuItem("Heading", null, :menuGeneralViewPageIndicator4, {}));
      Menu2.addItem(new Ui.MenuItem("Vertical Speed", null, :menuGeneralViewPageIndicator5, {}));
      Menu2.addItem(new Ui.MenuItem("Ground Speed", null, :menuGeneralViewPageIndicator6, {}));
      Menu2.addItem(new Ui.MenuItem("Heartbeat", null, :menuGeneralViewPageIndicator8, {}));
      if($.oMySettings.getGeneralViewPageLayout($.oMySettings.iGeneralViewEditingPageIndex) == $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_2) {
        Menu2.addItem(new Ui.MenuItem("Altitude Chart", null, :menuGeneralViewPageIndicator7, {}));
      }
      Menu2.addItem(new Ui.MenuItem("None", null, :menuGeneralViewPageIndicatorNone, {}));
    }

    else if(menu == :menuSettingsAltimeter) {
      Menu2.setTitle(Rez.Strings.titleSettingsAltimeter);
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleAltimeterCalibration, null, :menuAltimeterCalibration, {}));
    }
    else if(menu == :menuAltimeterCalibration) {
      Menu2.setTitle(Rez.Strings.titleAltimeterCalibration);
      if(LangUtils.notNaN($.oMyAltimeter.fAltitudeActual)) {
        Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleAltimeterCalibrationElevation, format("baro: $1$ $2$", [($.oMyAltimeter.fAltitudeActual*$.oMySettings.fUnitElevationCoefficient).format("%.0f"), $.oMySettings.sUnitElevation]), :menuAltimeterCalibrationElevation, {}));
      }
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleAltimeterCalibrationQNH, format("$1$ $2$", [($.oMySettings.fAltimeterCalibrationQNH*$.oMySettings.fUnitPressureCoefficient).format("%.2f"), $.oMySettings.sUnitPressure]), :menuAltimeterCalibrationQNH, {}));
    }

    else if(menu == :menuSettingsVariometer) {
      Menu2.setTitle(Rez.Strings.titleSettingsVariometer);
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleVariometerRange, format("$1$ $2$", [($.oMySettings.fVariometerRange*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]), :menuVariometerRange, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleVariometerSmoothing, $.oMySettings.sVariometerSmoothingName, :menuVariometerSmoothing, {}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleVariometerAutoThermal, null, :menuVariometerAutoThermal, $.oMySettings.bVariometerAutoThermal, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleVariometerThermalDetect, null, :menuVariometerThermalDetect, $.oMySettings.bVariometerThermalDetect, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleVariometerPlotOrientation, {:enabled=>Ui.loadResource(Rez.Strings.valueNorthUp), :disabled=>Ui.loadResource(Rez.Strings.valueHeadingUp)}, :menuVariometerPlotOrientation, ($.oMySettings.iVariometerPlotOrientation?false:true), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleVariometerPlotRange, format("$1$ $2$", [$.oMySettings.iVariometerPlotRange, Ui.loadResource(Rez.Strings.unitTimeMinute)]), :menuVariometerPlotRange, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleVariometerPlotZoom, format("$1$ $2$", [$.oMySettings.fVariometerPlotScale.format("%.2f"),Ui.loadResource(Rez.Strings.unitZoom)]), :menuVariometerPlotZoom, {}));
    }

    else if(menu == :menuSettingsSounds) {
      Menu2.setTitle(Rez.Strings.titleSettingsSounds);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleSoundsVariometerTones, null, :menuSoundsVariometerTones, $.oMySettings.bSoundsVariometerTones, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleVariometerVibrations, null, :menuVariometerVibrations, $.oMySettings.bVariometerVibrations, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleSoundsToneDriver, {:enabled=>Ui.loadResource(Rez.Strings.valueSpeaker), :disabled=>Ui.loadResource(Rez.Strings.valueBuzzer)}, :menuSoundsToneDriver, ($.oMySettings.iSoundsToneDriver?true:false), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleMinimumClimb, format("$1$ $2$", [($.oMySettings.fMinimumClimb*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]), :menuMinimumClimb, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleMinimumSink, format("$1$ $2$", [($.oMySettings.fMinimumSink*$.oMySettings.fUnitVerticalSpeedCoefficient).format(sFormat), $.oMySettings.sUnitVerticalSpeed]), :menuMinimumSink, {}));
    }

    else if(menu == :menuSettingsActivity) {
      Menu2.setTitle(Rez.Strings.titleSettingsActivity);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleActivityAutoStart, null, :menuActivityAutoStart, $.oMySettings.bActivityAutoStart, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleActivityAutoSpeedStart, format("$1$ $2$", [($.oMySettings.fActivityAutoSpeedStart*$.oMySettings.fUnitHorizontalSpeedCoefficient).format("%.0f"), $.oMySettings.sUnitHorizontalSpeed]), :menuActivityAutoSpeedStart, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleActivityType, $.oMySettings.sActivityType, :menuActivityType, {}));
    }

    else if(menu == :menuSettingsUnits) {
      Menu2.setTitle(Rez.Strings.titleSettingsUnits);
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitDistance, $.oMySettings.sUnitDistance, :menuUnitDistance, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitElevation, $.oMySettings.sUnitElevation, :menuUnitElevation, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitPressure, $.oMySettings.sUnitPressure, :menuUnitPressure, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitWindSpeed, $.oMySettings.sUnitWindSpeed, :menuUnitWindSpeed, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitDirection, $.oMySettings.sUnitDirection, :menuUnitDirection, {}));   
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleUnitTimeUTC, $.oMySettings.sUnitTime, :menuUnitTimeUTC, {})); 
    }

    else if(menu == :menuSettingsLivetrack) {
      Menu2.setTitle(Rez.Strings.titleSettingsLivetrack);
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleLivetrack24Frequency, format("$1$$2$", [$.oMySettings.iLivetrack24FrequencySeconds, Ui.loadResource(Rez.Strings.unitTimeSecond)]), :menuLivetrack24Frequency, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleSportsTrackLiveFrequency, format("$1$$2$", [$.oMySettings.iSportsTrackLiveFrequencySeconds, Ui.loadResource(Rez.Strings.unitTimeSecond)]), :menuSportsTrackLiveFrequency, {}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleFlySafeLivetrackFrequency, format("$1$$2$", [$.oMySettings.iFlySafeLivetrackFrequencySeconds, Ui.loadResource(Rez.Strings.unitTimeSecond)]), :menuFlySafeLivetrackFrequency, {}));
    }

    else if(menu == :menuSettingsMapView && Ui has :MapView) {
      Menu2.setTitle(Rez.Strings.titleSettingsMapView);
      Menu2.addItem(new Ui.ToggleMenuItem(Rez.Strings.titleMapDisplay, null, :menuMapDisplay, $.oMySettings.bMapDisplay, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_RIGHT}));
      Menu2.addItem(new Ui.MenuItem(Rez.Strings.titleMapViewZoom, format("$1$ $2$", [$.oMySettings.fMapViewScale.format("%.2f"),Ui.loadResource(Rez.Strings.unitZoom)]), :menuMapViewZoom, {}));
    }

    else if(menu == :menuAbout) {
      Menu2.setTitle(Rez.Strings.titleAbout);
      Menu2.addItem(new Ui.MenuItem(format("$1$: $2$", [Ui.loadResource(Rez.Strings.titleVersion), Ui.loadResource(Rez.Strings.AppVersion)]), null, :aboutVersion, {}));
      Menu2.addItem(new Ui.MenuItem(format("$1$: GPL 3.0", [Ui.loadResource(Rez.Strings.titleLicense)]), null, :aboutLicense, {}));
      Menu2.addItem(new Ui.MenuItem(format("$1$: Yannick Dutertre", [Ui.loadResource(Rez.Strings.titleAuthor)]), null, :aboutAuthor, {}));
      Menu2.addItem(new Ui.MenuItem("Originaly based on Glider SK", null, :aboutGliderSK, {}));
      Menu2.addItem(new Ui.MenuItem(format("$1$: Cédric Dufour", [Ui.loadResource(Rez.Strings.titleAuthor)]), null, :aboutAuthor, {}));
    }

    if(menu == :menuActivity) {
      Menu2.setTitle(Rez.Strings.titleActivity);
      if($.oMyActivity != null) {
        if(($.oMyActivity as MyActivity).isRecording()) {
          Menu2.addItem(new Ui.IconMenuItem(Rez.Strings.titleActivityPause, null, :menuActivityPause, (new $.DrawableMenu(:pause)), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
        }
        else {
          Menu2.addItem(new Ui.IconMenuItem(Rez.Strings.titleActivityResume, null, :menuActivityResume, (new $.DrawableMenu(:resume)), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
        }
        Menu2.addItem(new Ui.IconMenuItem(Rez.Strings.titleActivitySave, null, :menuActivitySave, (new $.DrawableMenu(:save)), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
        Menu2.addItem(new Ui.IconMenuItem(Rez.Strings.titleActivityDiscard, null, :menuActivityDiscard, (new $.DrawableMenu(:discard)), {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
      }
    }
  }
}

class MyMenu2GenericDelegate extends Ui.Menu2InputDelegate {

  //
  // VARIABLES
  //

  private var menu as Symbol = :menuNone;


  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

 function initialize(_menu as Symbol) {
    Menu2InputDelegate.initialize();
    self.menu = _menu;
  }

  function getPageIndexFromMenuItemId(_itemId as Symbol) as Number {
    switch(_itemId) {
    case :menuGeneralViewPageEdit0: return 0;
    case :menuGeneralViewPageEdit1: return 1;
    case :menuGeneralViewPageEdit2: return 2;
    case :menuGeneralViewPageEdit3: return 3;
    case :menuGeneralViewPageEdit4: return 4;
    case :menuGeneralViewPageEdit5: return 5;
    case :menuGeneralViewPageEdit6: return 6;
    case :menuGeneralViewPageEdit7: return 7;
    case :menuGeneralViewPageEdit8: return 8;
    case :menuGeneralViewPageEdit9: return 9;
    default: return -1;
    }
  }

  function getFieldIndexFromMenuItemId(_itemId as Symbol) as Number {
    switch(_itemId) {
    case :menuGeneralViewPageField0: return 0;
    case :menuGeneralViewPageField1: return 1;
    case :menuGeneralViewPageField2: return 2;
    case :menuGeneralViewPageField3: return 3;
    case :menuGeneralViewPageField4: return 4;
    case :menuGeneralViewPageField5: return 5;
    case :menuGeneralViewPageField6: return 6;
    default: return -1;
    }
  }

  function getLayoutFromMenuItemId(_itemId as Symbol) as Number {
    switch(_itemId) {
    case :menuGeneralViewPageLayout2: return $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_2;
    case :menuGeneralViewPageLayout4: return $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_4;
    case :menuGeneralViewPageLayout7: return $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_7;
    default: return -1;
    }
  }

  function getIndicatorFromMenuItemId(_itemId as Symbol) as Number {
    switch(_itemId) {
    case :menuGeneralViewPageIndicator0: return 0;
    case :menuGeneralViewPageIndicator1: return 1;
    case :menuGeneralViewPageIndicator2: return 2;
    case :menuGeneralViewPageIndicator3: return 3;
    case :menuGeneralViewPageIndicator4: return 4;
    case :menuGeneralViewPageIndicator5: return 5;
    case :menuGeneralViewPageIndicator6: return 6;
    case :menuGeneralViewPageIndicator7: return 7;
    case :menuGeneralViewPageIndicator8: return 8;
    case :menuGeneralViewPageIndicatorNone: return $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED;
    default: return -2;
    }
  }

  function onSelect(_item as Ui.MenuItem) {
    var item = _item as Ui.ToggleMenuItem;
    var itemId = _item.getId() as Symbol;
    if(self.menu == :menuSettings) {
        Ui.pushView(new MyMenu2Generic(itemId, 0),
                    new MyMenu2GenericDelegate(itemId),
                    Ui.SLIDE_IMMEDIATE);
    }

    else if(self.menu == :menuSettingsGeneral) {
      if(itemId == :menuGeneralBackgroundColor) {
        $.oMySettings.saveGeneralBackgroundColor(item.isEnabled()?0:1);
        $.oMySettings.setGeneralBackgroundColor(item.isEnabled()?0:1);
      }
      else if(itemId == :menuActiveLook) {
        $.oMySettings.saveActiveLook(item.isEnabled());
        $.oMySettings.setActiveLook(item.isEnabled());
      }
      else if(itemId == :menuVectorVario) {
        $.oMySettings.saveVectorVario(item.isEnabled());
        $.oMySettings.setVectorVario(item.isEnabled());
      }
      else if(itemId == :menuGPS) {
        $.oMySettings.saveGPS(item.isEnabled()?0:1);
        $.oMySettings.setGPS(item.isEnabled()?0:1);
      }
      else if(itemId == :menuStorageClearLogs) {
        Ui.pushView((self has :NoExclude)?(new MyMenuConfirmDiscard()) : (new Ui.Confirmation(Ui.loadResource(Rez.Strings.titleActivityDiscard) + "?")),
                    (self has :NoExclude)?(new MyMenuConfirmDiscardDelegate(:actionClearLogs, false)) : (new MyMenuGenericConfirmDelegate(:contextStorage, :actionClearLogs, false)),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuGeneralViewPages) {
        Ui.pushView(new MyMenu2Generic(:menuGeneralViewPages, 0),
                    new MyMenu2GenericDelegate(:menuGeneralViewPages),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuGeneralViewPages) {
      var iPageIndex = self.getPageIndexFromMenuItemId(itemId);
      if(iPageIndex >= 0) {
        $.oMySettings.iGeneralViewEditingPageIndex = iPageIndex;
        Ui.pushView(new MyMenu2Generic(:menuGeneralViewPageEdit, 0),
                    new MyMenu2GenericDelegate(:menuGeneralViewPageEdit),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuGeneralViewPageAdd) {
        Ui.pushView(new MyMenu2Generic(:menuGeneralViewPageAdd, 2),
                    new MyMenu2GenericDelegate(:menuGeneralViewPageAdd),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuGeneralViewPageAdd) {
      var iLayout = self.getLayoutFromMenuItemId(itemId);
      if(iLayout > 0) {
        $.oMySettings.createGeneralViewPage("Page " + ($.oMySettings.getGeneralViewPageCount() + 1), iLayout);
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        Ui.pushView(new MyMenu2Generic(:menuGeneralViewPages, 0),
                    new MyMenu2GenericDelegate(:menuGeneralViewPages),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuGeneralViewPageEdit) {
      var iFieldIndex = self.getFieldIndexFromMenuItemId(itemId);
      if(iFieldIndex >= 0) {
        var aFields = $.oMySettings.getGeneralViewPageFields($.oMySettings.iGeneralViewEditingPageIndex);
        var iCurrentIndicator = (iFieldIndex < aFields.size()) ? (aFields[iFieldIndex] as Number) : $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED;
        var iEditedLayout = $.oMySettings.getGeneralViewPageLayout($.oMySettings.iGeneralViewEditingPageIndex);
        var iFocus = iCurrentIndicator;
        if(iCurrentIndicator == $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED) {
          iFocus = (iEditedLayout == $.oMySettings.GENERAL_VIEW_PAGE_LAYOUT_2) ? 9 : 8;
        }
        else if(iCurrentIndicator == 8) {
          iFocus = 7;
        }
        else if(iCurrentIndicator == 7) {
          iFocus = 8;
        }
        Ui.pushView(new MyMenu2Generic(itemId, iFocus),
                    new MyMenu2GenericDelegate(itemId),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuGeneralViewPageDelete) {
        var iPageIndex = $.oMySettings.iGeneralViewEditingPageIndex;
        Sys.println("DEBUG: Delete handler - iPageIndex=" + iPageIndex + " pageCount=" + $.oMySettings.getGeneralViewPageCount());
        var bDeleted = false;
        if(iPageIndex >= 0 && iPageIndex < $.oMySettings.getGeneralViewPageCount() && $.oMySettings.getGeneralViewPageCount() > 1) {
          Sys.println("DEBUG: Delete handler - Calling deleteGeneralViewPage(" + iPageIndex + ")");
          bDeleted = $.oMySettings.deleteGeneralViewPage(iPageIndex);
          Sys.println("DEBUG: Delete handler - bDeleted=" + bDeleted);
          if(bDeleted) {
            $.oMySettings.iGeneralViewEditingPageIndex = -1;
          }
        }
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        if(bDeleted) {
          // Replace stale pages list with a fresh one after deleting so the UI reflects the change.
          Ui.popView(Ui.SLIDE_IMMEDIATE);
          Ui.pushView(new MyMenu2Generic(:menuGeneralViewPages, 0),
                      new MyMenu2GenericDelegate(:menuGeneralViewPages),
                      Ui.SLIDE_IMMEDIATE);
        } else {
          // Keep the existing pages list if deletion did not happen.
        }
      }
    }

    else if(self.getFieldIndexFromMenuItemId(self.menu) >= 0) {
      var iIndicator = self.getIndicatorFromMenuItemId(itemId);
      if(iIndicator >= $.oMySettings.GENERAL_VIEW_PAGE_SLOT_UNUSED) {
        var iPageIndex = $.oMySettings.iGeneralViewEditingPageIndex;
        var iFieldIndex = self.getFieldIndexFromMenuItemId(self.menu);
        $.oMySettings.setGeneralViewPageField(iPageIndex, iFieldIndex, iIndicator);
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        Ui.switchToView(new MyMenu2Generic(:menuGeneralViewPageEdit, iFieldIndex),
                        new MyMenu2GenericDelegate(:menuGeneralViewPageEdit),
                        Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuSettingsAltimeter) {
      if(itemId == :menuAltimeterCalibration) {
        Ui.pushView(new MyMenu2Generic(:menuAltimeterCalibration, 0),
                    new MyMenu2GenericDelegate(:menuAltimeterCalibration),
                    Ui.SLIDE_IMMEDIATE);
      }
    }

    else if(self.menu == :menuAltimeterCalibration) {
      if(itemId == :menuAltimeterCalibrationQNH) {
        Ui.pushView(new MyPickerGenericPressure(:contextSettings, :menuAltimeterCalibrationQNH),
                    new MyPickerGenericPressureDelegate(:contextSettings, :menuAltimeterCalibrationQNH, self.menu),
                    Ui.SLIDE_LEFT);
      }
      else if(itemId == :menuAltimeterCalibrationElevation) {
        Ui.pushView(new MyPickerGenericElevation(:contextSettings, :menuAltimeterCalibrationElevation),
                    new MyPickerGenericElevationDelegate(:contextSettings, :menuAltimeterCalibrationElevation, self.menu),
                    Ui.SLIDE_LEFT);
      }
    }
    
    else if(self.menu == :menuSettingsVariometer) {
      if(itemId == :menuVariometerAutoThermal) {
        $.oMySettings.saveVariometerAutoThermal(item.isEnabled());
        $.oMySettings.setVariometerAutoThermal(item.isEnabled());
      }
      else if(itemId == :menuVariometerThermalDetect) {
        $.oMySettings.saveVariometerThermalDetect(item.isEnabled());
        $.oMySettings.setVariometerThermalDetect(item.isEnabled());
      }
      else if(itemId == :menuVariometerPlotOrientation) {
        $.oMySettings.saveVariometerPlotOrientation(item.isEnabled()?0:1);
        $.oMySettings.setVariometerPlotOrientation(item.isEnabled()?0:1);
      }
      else {
        Ui.pushView(new MyPickerGenericSettings(:contextVariometer, itemId),
                    new MyPickerGenericSettingsDelegate(:contextVariometer, itemId, self.menu),
                    Ui.SLIDE_LEFT);
      }
    }
    
    else if(self.menu == :menuSettingsSounds) {
      if(itemId == :menuSoundsVariometerTones) {
        $.oMySettings.saveSoundsVariometerTones(item.isEnabled());
        $.oMySettings.setSoundsVariometerTones(item.isEnabled());
      }
      else if(itemId == :menuVariometerVibrations) {
        $.oMySettings.saveVariometerVibrations(item.isEnabled());
        $.oMySettings.setVariometerVibrations(item.isEnabled());
      }
      else if(itemId == :menuSoundsToneDriver) {
        $.oMySettings.saveSoundsToneDriver(item.isEnabled()?1:0);
        $.oMySettings.setSoundsToneDriver(item.isEnabled()?1:0);
      }
      else {
        Ui.pushView(new MyPickerGenericSettings(:contextSounds, itemId),
                    new MyPickerGenericSettingsDelegate(:contextSounds, itemId, self.menu),
                    Ui.SLIDE_LEFT); 
      }
    }

    else if(self.menu == :menuSettingsActivity) {
      if(itemId == :menuActivityAutoStart) {
        $.oMySettings.saveActivityAutoStart(item.isEnabled());
        $.oMySettings.setActivityAutoStart(item.isEnabled());
      }
      else if(itemId == :menuActivityAutoSpeedStart) {
        Ui.pushView(new MyPickerGenericSpeed(:contextSettings, :itemActivityAutoSpeedStart),
                    new MyPickerGenericSpeedDelegate(:contextSettings, :itemActivityAutoSpeedStart, self.menu),
                    Ui.SLIDE_LEFT);
      }
      else {
        Ui.pushView(new MyPickerGenericSettings(:contextActivitySettings, itemId),
            new MyPickerGenericSettingsDelegate(:contextActivitySettings, itemId, self.menu),
            Ui.SLIDE_LEFT); 
      }
    }

    else if(self.menu == :menuSettingsUnits) {
        Ui.pushView(new MyPickerGenericSettings(:contextUnit, itemId),
                    new MyPickerGenericSettingsDelegate(:contextUnit, itemId, self.menu),
                    Ui.SLIDE_LEFT);
    }

    else if(self.menu == :menuSettingsLivetrack) {
        Ui.pushView(new MyPickerGenericSettings(:contextLivetrackSettings, itemId),
                    new MyPickerGenericSettingsDelegate(:contextLivetrackSettings, itemId, self.menu),
                    Ui.SLIDE_LEFT);      
    }

    else if(self.menu == :menuSettingsMapView) {
      if(itemId == :menuMapDisplay) {
        $.oMySettings.saveMapDisplay(item.isEnabled());
        $.oMySettings.setMapDisplay(item.isEnabled());
      }
      else {
        Ui.pushView(new MyPickerGenericSettings(:contextMapView, itemId),
                    new MyPickerGenericSettingsDelegate(:contextMapView, itemId, self.menu),
                    Ui.SLIDE_LEFT);
      }
    }

    else if(self.menu == :menuActivity) {
      if(itemId == :menuActivityResume) {
        if($.oMyActivity != null) {
          ($.oMyActivity as MyActivity).resume();
          Ui.popView(Ui.SLIDE_IMMEDIATE);
        }
      }
      else if(itemId == :menuActivityPause) {
        if($.oMyActivity != null) {
          ($.oMyActivity as MyActivity).pause();
          Ui.popView(Ui.SLIDE_IMMEDIATE);
        }
      }
      else if(itemId == :menuActivitySave) {
        Ui.pushView(new Ui.Confirmation(Ui.loadResource(Rez.Strings.titleActivitySave) + "?"),
                    new MyMenuGenericConfirmDelegate(:contextActivity, :actionSave, true),
                    Ui.SLIDE_IMMEDIATE);
      }
      else if(itemId == :menuActivityDiscard) {
        Ui.pushView((self has :NoExclude)?(new MyMenuConfirmDiscard()) : (new Ui.Confirmation(Ui.loadResource(Rez.Strings.titleActivityDiscard) + "?")),
                    (self has :NoExclude)?(new MyMenuConfirmDiscardDelegate(:actionDiscard, true)) : (new MyMenuGenericConfirmDelegate(:contextActivity, :actionDiscard, false)),
                    Ui.SLIDE_IMMEDIATE);
      }
    }
  }
}

class DrawableMenu extends Ui.Drawable {
    
  //
  // VARIABLES
  //

  var menu as Symbol = :menuNone;

  //! Constructor
  public function initialize(_menu as Symbol) {
      Drawable.initialize({});
      self.menu = _menu;
  }

  //! Draw the application icon and main menu title
  //! @param dc Device Context
  (:icon)
  public function draw(_oDC) {

    var appIcon = null;
    var bitmapX = 0;
    var bitmapY = 0;

    if(menu==:title) {
      var spacing = 5;
      appIcon = Ui.loadResource($.Rez.Drawables.AppIcon);
      var bitmapWidth = appIcon.getWidth();
      var labelWidth = _oDC.getTextWidthInPixels(Ui.loadResource(Rez.Strings.titleSettings), Graphics.FONT_TINY);

      bitmapX = (_oDC.getWidth() - (bitmapWidth + spacing + labelWidth)) / 2;
      var labelX = bitmapX + bitmapWidth + spacing;
      bitmapY = (_oDC.getHeight() - appIcon.getHeight()) / 2;
      var labelY = _oDC.getHeight() / 2;

      // _oDC.drawBitmap(bitmapX, bitmapY, appIcon);
      _oDC.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
      _oDC.drawText(labelX, labelY, Graphics.FONT_TINY, Ui.loadResource(Rez.Strings.titleSettings), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
    else if(menu==:pause) {
      appIcon = Ui.loadResource($.Rez.Drawables.pauseIcon);
      bitmapX = (_oDC.getWidth() - appIcon.getWidth()) / 2;
      bitmapY = (_oDC.getHeight() - appIcon.getHeight()) / 2;
    }
    else if(menu==:resume) {
      appIcon = Ui.loadResource($.Rez.Drawables.resumeIcon);
      bitmapX = (_oDC.getWidth() - appIcon.getWidth()) / 2;
      bitmapY = (_oDC.getHeight() - appIcon.getHeight()) / 2;
    }
    else if(menu==:save) {
      appIcon = Ui.loadResource($.Rez.Drawables.saveIcon);
      bitmapX = (_oDC.getWidth() - appIcon.getWidth()) / 2;
      bitmapY = (_oDC.getHeight() - appIcon.getHeight()) / 2;
    }
    else if(menu==:discard) {
      appIcon = Ui.loadResource($.Rez.Drawables.discardIcon);
      bitmapX = (_oDC.getWidth() - appIcon.getWidth()) / 2;
      bitmapY = (_oDC.getHeight() - appIcon.getHeight()) / 2;
    }
    _oDC.drawBitmap(bitmapX, bitmapY, appIcon);
  }
}
