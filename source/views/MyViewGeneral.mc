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
using Toybox.Position as Pos;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewGeneral extends MyViewGlobal {
  //
  // VARIABLES
  //

  //strings
  private var sUnitElapsed as String = "elapsed";

  //
  // FUNCTIONS: MyViewGlobal (override/implement)
  //

  function initialize() {
    //Populate last view
    $.oMyProcessing.bIsPreviousGeneral = true;
    MyViewGlobal.initialize();
  }

  function prepare() {
    //Sys.println("DEBUG: MyViewGeneral.prepare()");
    MyViewGlobal.prepare();

    // Set colors (value-independent), labels and units
    // ... Current time
    (View.findDrawableById("labelTopLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelWindDirection) as String);
    if($.oMySettings.iUnitDirection==0) {
      (View.findDrawableById("unitTopLeft") as Ui.Text).setText("[°]");
    }
    // ... activity: elapsed
    (View.findDrawableById("labelTopRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelWindSpeed) as String);
    (View.findDrawableById("unitTopRight") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitHorizontalSpeed]));
    // ... altitude
    (View.findDrawableById("labelLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelAltitude) as String);
    (View.findDrawableById("unitLeft") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitElevation]));
    // ... finesse
    (View.findDrawableById("labelCenter") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelFinesse) as String);
    // ... heading
    (View.findDrawableById("labelRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelHeading) as String);
    if($.oMySettings.iUnitDirection==0) {
      (View.findDrawableById("unitRight") as Ui.Text).setText("[°]");
    }
    // ... vertical speed
    (View.findDrawableById("labelBottomLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelVerticalSpeed) as String);
    (View.findDrawableById("unitBottomLeft") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitVerticalSpeed]));
    // ... ground speed
    (View.findDrawableById("labelBottomRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelGroundSpeed) as String);
    (View.findDrawableById("unitBottomRight") as Ui.Text).setText(Lang.format("[$1$]", [$.oMySettings.sUnitHorizontalSpeed]));

    // Unmute tones
     (App.getApp() as MyApp).unmuteTones();
  }

  function updateLayout(_b) {  
    //Sys.println("DEBUG: MyViewGeneral.updateLayout()");
    MyViewGlobal.updateLayout(true);

    // Colors
    if($.oMyProcessing.iAccuracy == Pos.QUALITY_NOT_AVAILABLE) {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_DK_RED);
      (self.oRezValueTopLeft as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueTopLeft as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueTopRight as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueTopRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueLeft as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueLeft as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueCenter as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueCenter as Ui.Text).setText($.MY_NOVALUE_LEN2);
      (self.oRezValueRight as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueBottomLeft as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueBottomRight as Ui.Text).setColor(Gfx.COLOR_LT_GRAY);
      (self.oRezValueBottomRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      return;
    }
    else if($.oMyProcessing.iAccuracy == Pos.QUALITY_LAST_KNOWN) {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_DK_RED);
      self.iColorText = Gfx.COLOR_LT_GRAY;
    }
    else {
      (self.oRezDrawableGlobal as MyDrawableGlobal).setColorFieldsBackground(Gfx.COLOR_TRANSPARENT);
    }

    // Set values (and dependent colors)
    var fValue;
    var iValue;
    var sValue;
    var bRecording = ($.oMyActivity != null);

    // ... Wind Direction
    (self.oRezValueTopLeft as Ui.Text).setColor(self.iColorText);
    //sValue = LangUtils.formatTime(oTimeNow, $.oMySettings.bUnitTimeUTC, false);
    iValue = $.oMyProcessing.iWindDirection;
    if(LangUtils.notNaN(iValue) && $.oMyProcessing.bWindValid) {
      if($.oMySettings.iUnitDirection == 1) {
        sValue = $.oMyProcessing.convertDirection(iValue);
      } else {
        sValue = iValue.format("%d");
      }
        
    } else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueTopLeft as Ui.Text).setText(sValue);

    // ... Wind Speed
    (self.oRezValueTopRight as Ui.Text).setColor(bRecording ? self.iColorText : Gfx.COLOR_LT_GRAY);
    fValue = $.oMyProcessing.fWindSpeed;
    if(LangUtils.notNaN(fValue) && $.oMyProcessing.bWindValid) {
      fValue *= $.oMySettings.fUnitHorizontalSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueTopRight as Ui.Text).setText(sValue);

    // ... altitude
    (self.oRezValueLeft as Ui.Text).setColor(self.iColorText);
    fValue = $.oMyProcessing.fAltitude;
    if(LangUtils.notNaN(fValue)) {
      fValue *= $.oMySettings.fUnitElevationCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueLeft as Ui.Text).setText(sValue);

    // ... finesse
    (self.oRezValueCenter as Ui.Text).setColor(self.iColorText);
    if(LangUtils.notNaN($.oMyProcessing.fFinesse) and !$.oMyProcessing.bAscent) {
      fValue = $.oMyProcessing.fFinesse;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN2;
    }
    (self.oRezValueCenter as Ui.Text).setText(sValue);

    // ... heading
    (self.oRezValueRight as Ui.Text).setColor(self.iColorText);
    fValue = $.oMyProcessing.fHeading;

    if(LangUtils.notNaN(fValue)) {
      //fValue = ((fValue * 180.0f/Math.PI).toNumber()) % 360;
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
    (self.oRezValueRight as Ui.Text).setText(sValue);

    // ... variometer
    (self.oRezValueBottomLeft as Ui.Text).setColor(self.iColorText);
    fValue = $.oMyProcessing.fVariometer_filtered;
    if(LangUtils.notNaN(fValue)) {
      fValue *= $.oMySettings.fUnitVerticalSpeedCoefficient;
      if($.oMySettings.fUnitVerticalSpeedCoefficient < 100.0f) {
        sValue = fValue.format("%+.1f");
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.05f) {
            (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_DK_GREEN);
          }
          else if(fValue <= -0.05f) {
            (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_RED);
          }
        }
      }
      else {
        sValue = fValue.format("%+.0f");
        if($.oMyProcessing.iAccuracy > Pos.QUALITY_LAST_KNOWN) {
          if(fValue >= 0.5f) {
            (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_DK_GREEN);
          }
          else if(fValue <= -0.5f) {
            (self.oRezValueBottomLeft as Ui.Text).setColor(Gfx.COLOR_RED);
          }
        }
      }
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueBottomLeft as Ui.Text).setText(sValue);

    // ... ground speed
    (self.oRezValueBottomRight as Ui.Text).setColor(self.iColorText);
    fValue = $.oMyProcessing.fGroundSpeed;
    if(LangUtils.notNaN(fValue)) {
      fValue *= $.oMySettings.fUnitHorizontalSpeedCoefficient;
      sValue = fValue.format("%.0f");
    }
    else {
      sValue = $.MY_NOVALUE_LEN3;
    }
    (self.oRezValueBottomRight as Ui.Text).setText(sValue);
  }

  function onHide() {
    //Sys.println("DEBUG: MyViewGeneral.onHide()");
    MyViewGlobal.onHide();

    // Mute tones
    (App.getApp() as MyApp).muteTones();
  }

}

class MyViewGeneralDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewGeneralDelegate.onPreviousPage()");
    if ($.oMyActivity != null) { //Skip the log view if we're recording, e.g. in flight
      Ui.switchToView(new MyViewVarioplot(),
                new MyViewVarioplotDelegate(),
                Ui.SLIDE_IMMEDIATE);
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
    Ui.switchToView(new MyViewVariometer(),
                    new MyViewVariometerDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
