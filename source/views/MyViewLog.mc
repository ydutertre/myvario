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
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

//
// GLOBALS
//

// Current view/log index
var iMyViewLogIndex as Number = -1;


//
// CLASS
//

class MyViewLog extends MyViewGlobal {

  //
  // VARIABLES
  //

  // Resources (cache)
  // ... fields (units)
  private var oRezUnitLeft as Ui.Text?;
  private var oRezUnitRight as Ui.Text?;
  private var oRezUnitBottomRight as Ui.Text?;
  // ... strings
  private var sTitle as String = "Log";
  private var sUnitElevation_fmt as String = "[m]";

  // Internals
  // ... fields
  private var bTitleShow as Boolean = true;
  private var iFieldIndex as Number = 0;
  private var iFieldEpoch as Number = -1;
  // ... log
  private var iLogIndex as Number = -1;
  private var dictLog as Dictionary?;


  //
  // FUNCTIONS: MyViewGlobal (override/implement)
  //

  function initialize() {
    MyViewGlobal.initialize();

    // Current view/log index
    $.iMyViewLogIndex = $.iMyLogIndex;

    // Internals
    // ... fields
    self.iFieldEpoch = Time.now().value();
  }

  function onUpdate(_oDC as Gfx.Dc) as Void {
    //Sys.println("DEBUG: MyViewLog.onUpdate()");

    // Load log
    if(self.iLogIndex != $.iMyViewLogIndex) {
      self.loadLog();
    }

    // Done
    MyViewGlobal.onUpdate(_oDC);
  }

  function prepare() as Void {
    //Sys.println("DEBUG: MyViewLog.prepare()");
    MyViewGlobal.prepare();

    // Load resources
    // ... fields (units)
    self.oRezUnitLeft = View.findDrawableById("unitLeft") as Ui.Text;
    self.oRezUnitRight = View.findDrawableById("unitRight") as Ui.Text;
    self.oRezUnitBottomRight = View.findDrawableById("unitBottomRight") as Ui.Text;
    // ... strings
    self.sTitle = Ui.loadResource(Rez.Strings.titleViewLog) as String;
    self.sUnitElevation_fmt = format("[$1$]", [$.oMySettings.sUnitElevation]);

    // Set labels, units and colors
    // ... start time
    (View.findDrawableById("labelTopLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelStart) as String);
    (View.findDrawableById("unitTopLeft") as Ui.Text).setText($.MY_NOVALUE_BLANK);
    (self.oRezValueTopLeft as Ui.Text).setColor(self.iColorText);
    // ... stop time
    (View.findDrawableById("labelTopRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelStop) as String);
    (View.findDrawableById("unitTopRight") as Ui.Text).setText($.MY_NOVALUE_BLANK);
    (self.oRezValueTopRight as Ui.Text).setColor(self.iColorText);
    // ... minimum altitude / time (dynamic label)
    (View.findDrawableById("labelLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelAltitudeMin) as String);
    (self.oRezValueLeft as Ui.Text).setColor(self.iColorText);
    // ... distance
    (View.findDrawableById("labelCenter") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelDistance) as String);
    (self.oRezValueCenter as Ui.Text).setColor(self.iColorText);
    // ... maximum altitude / time (dynamic label)
    (View.findDrawableById("labelRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelAltitudeMax) as String);
    (self.oRezValueRight as Ui.Text).setColor(self.iColorText);
    // ... elapsed time
    (View.findDrawableById("labelBottomLeft") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelElapsed) as String);
    (View.findDrawableById("unitBottomLeft") as Ui.Text).setText($.MY_NOVALUE_BLANK);
    (self.oRezValueBottomLeft as Ui.Text).setColor(self.iColorText);
    // ... ascent / elapsed (dynamic label)
    (View.findDrawableById("labelBottomRight") as Ui.Text).setText(Ui.loadResource(Rez.Strings.labelAscent) as String);
    (self.oRezValueBottomRight as Ui.Text).setColor(self.iColorText);
    // ... title
    self.bTitleShow = true;
    (self.oRezValueFooter as Ui.Text).setColor(Gfx.COLOR_DK_GRAY);
    (self.oRezValueFooter as Ui.Text).setText(Ui.loadResource(Rez.Strings.titleViewLog) as String);
  }

  function updateLayout(_b as Boolean) as Void {
    //Sys.println("DEBUG: MyViewLog.updateLayout()");
    MyViewGlobal.updateLayout(false);

    // Fields
    var iEpochNow = Time.now().value();
    if(iEpochNow - self.iFieldEpoch >= 2) {
      self.bTitleShow = false;
      self.iFieldIndex = (self.iFieldIndex + 1) % 2;
      self.iFieldEpoch = iEpochNow;
    }

    // No log ?
    if(self.dictLog == null) {
      (self.oRezValueTopLeft as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueTopRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueLeft as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueCenter as Ui.Text).setText($.MY_NOVALUE_LEN2);
      (self.oRezValueRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueBottomLeft as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueBottomRight as Ui.Text).setText($.MY_NOVALUE_LEN3);
      (self.oRezValueFooter as Ui.Text).setColor(Gfx.COLOR_DK_GRAY);
      (self.oRezValueFooter as Ui.Text).setText(self.sTitle);
      return;
    }

    // Set values
    // ... time: start
    (self.oRezValueTopLeft as Ui.Text).setText((self.dictLog as Dictionary)["timeStart"] as String);
    // ... time: stop
    (self.oRezValueTopRight as Ui.Text).setText((self.dictLog as Dictionary)["timeStop"] as String);
    // ... altitude: minimum
    if(self.iFieldIndex == 0) {  // ... altitude
      (self.oRezUnitLeft as Ui.Text).setText(self.sUnitElevation_fmt);
      (self.oRezValueLeft as Ui.Text).setText((self.dictLog as Dictionary)["altitudeMin"] as String);
    }
    else {  // ... time
      (self.oRezUnitLeft as Ui.Text).setText($.MY_NOVALUE_BLANK);
      (self.oRezValueLeft as Ui.Text).setText((self.dictLog as Dictionary)["timeAltitudeMin"] as String);
    }
    // ... distance
    (self.oRezValueCenter as Ui.Text).setText((self.dictLog as Dictionary)["distance"] as String);
    // ... altitude: maximum
    if(self.iFieldIndex == 0) {  // ... altitude
      (self.oRezUnitRight as Ui.Text).setText(self.sUnitElevation_fmt);
      (self.oRezValueRight as Ui.Text).setText((self.dictLog as Dictionary)["altitudeMax"] as String);
    }
    else {  // ... time
      (self.oRezUnitRight as Ui.Text).setText($.MY_NOVALUE_BLANK);
      (self.oRezValueRight as Ui.Text).setText((self.dictLog as Dictionary)["timeAltitudeMax"] as String);
    }
    // ... elapsed
    (self.oRezValueBottomLeft as Ui.Text).setText((self.dictLog as Dictionary)["elapsed"] as String);
    // ... ascent
    if(self.iFieldIndex == 0) {  // ... altitude
      (self.oRezUnitBottomRight as Ui.Text).setText(self.sUnitElevation_fmt);
      (self.oRezValueBottomRight as Ui.Text).setText((self.dictLog as Dictionary)["ascent"] as String);
    }
    else {  // ... elapsed
      (self.oRezUnitBottomRight as Ui.Text).setText($.MY_NOVALUE_BLANK);
      (self.oRezValueBottomRight as Ui.Text).setText((self.dictLog as Dictionary)["elapsedAscent"] as String);
    }
    // ... footer
    if(!self.bTitleShow) {
      (self.oRezValueFooter as Ui.Text).setColor(self.iColorText);
      (self.oRezValueFooter as Ui.Text).setText((self.dictLog as Dictionary)["date"] as String);
    }
  }


  //
  // FUNCTIONS: self
  //

  function loadLog() as Void {
    //Sys.println("DEBUG: MyViewLog.loadLog()");

    // Check index
    if($.iMyViewLogIndex < 0) {
      self.iLogIndex = -1;
      self.dictLog = null;
      return;
    }

    // Load log entry
    self.iLogIndex = $.iMyViewLogIndex;
    var s = self.iLogIndex.format("%02d");
    var d = App.Storage.getValue(format("storLog$1$", [s])) as Dictionary?;
    if(d == null) {
      self.dictLog = null;
      return;
    }

    // Validate/textualize log entry
    var oTimeStart = null;
    var oTimeStop = null;
    var fValue;
    // ... time: start (and date)
    if(d.get("timeStart") != null) {
      oTimeStart = new Time.Moment(d["timeStart"] as Number);
      d["timeStart"] = LangUtils.formatTime(oTimeStart, $.oMySettings.bUnitTimeUTC, false);
      d["date"] = LangUtils.formatDate(oTimeStart, $.oMySettings.bUnitTimeUTC);
    } else {
      d["timeStart"] = $.MY_NOVALUE_LEN3;
      d["date"] = $.MY_NOVALUE_LEN4;
    }
    // ... time: stop
    if(d.get("timeStop") != null) {
      oTimeStop = new Time.Moment(d["timeStop"] as Number);
      d["timeStop"] = LangUtils.formatTime(oTimeStop, $.oMySettings.bUnitTimeUTC, false);
    } else {
      d["timeStop"] = $.MY_NOVALUE_LEN3;
    }
    // ... elapsed
    if(oTimeStart != null and oTimeStop != null) {
      d["elapsed"] = LangUtils.formatElapsedTime(oTimeStart, oTimeStop, false);
    }
    else {
      d["elapsed"] = $.MY_NOVALUE_LEN3;
    }
    // ... distance
    if(d.get("distance") != null) {
      fValue = (d["distance"] as Float) * $.oMySettings.fUnitDistanceCoefficient;
      d["distance"] = fValue.format("%.0f");
    } else {
      d["distance"] = $.MY_NOVALUE_LEN2;
    }
    // ... ascent (and elasped)
    if(d.get("ascent") != null) {
      fValue = (d["ascent"] as Float) * $.oMySettings.fUnitElevationCoefficient;
      d["ascent"] = fValue.format("%.0f");
    } else {
      d["ascent"] = $.MY_NOVALUE_LEN3;
    }
    if(d.get("elapsedAscent") != null) {
      d["elapsedAscent"] = LangUtils.formatElapsed(d["elapsedAscent"] as Number, false);
    } else {
      d["elapsedAscent"] = $.MY_NOVALUE_LEN3;
    }
    // ... altitude: minimum (and time)
    if(d.get("altitudeMin") != null) {
      fValue = (d["altitudeMin"] as Float) * $.oMySettings.fUnitElevationCoefficient;
      d["altitudeMin"] = fValue.format("%.0f");
    } else {
      d["altitudeMin"] = $.MY_NOVALUE_LEN3;
    }
    if(d.get("timeAltitudeMin") != null) {
      d["timeAltitudeMin"] = LangUtils.formatTime(new Time.Moment(d["timeAltitudeMin"] as Number), $.oMySettings.bUnitTimeUTC, false);
    } else {
      d["timeAltitudeMin"] = $.MY_NOVALUE_LEN3;
    }
    // ... altitude: maximum (and time)
    if(d.get("altitudeMax") != null) {
      fValue = (d["altitudeMax"] as Float) * $.oMySettings.fUnitElevationCoefficient;
      d["altitudeMax"] = fValue.format("%.0f");
    } else {
      d["altitudeMax"] = $.MY_NOVALUE_LEN3;
    }
    if(d.get("timeAltitudeMax") != null) {
      d["timeAltitudeMax"] = LangUtils.formatTime(new Time.Moment(d["timeAltitudeMax"] as Number), $.oMySettings.bUnitTimeUTC, false);
    } else {
      d["timeAltitudeMax"] = $.MY_NOVALUE_LEN3;
    }

    // Done
    self.dictLog = d;
  }

}

class MyViewLogDelegate extends MyViewGlobalDelegate {

  function initialize() {
    MyViewGlobalDelegate.initialize();
  }

  function onSelect() {
    //Sys.println("DEBUG: MyViewLogDelegate.onSelect()");
    if($.iMyViewLogIndex < 0) {
      $.iMyViewLogIndex = $.iMyLogIndex;
    }
    else {
      $.iMyViewLogIndex = ($.iMyViewLogIndex + 1) % $.MY_STORAGE_SLOTS;
    }
    Ui.requestUpdate();
    return true;
  }

  function onBack() {
    //Sys.println("DEBUG: MyViewLogDelegate.onBack()");
    if($.iMyViewLogIndex < 0) {
      $.iMyViewLogIndex = $.iMyLogIndex;
    }
    else {
      $.iMyViewLogIndex = ($.iMyViewLogIndex - 1 + $.MY_STORAGE_SLOTS) % $.MY_STORAGE_SLOTS;
    }
    Ui.requestUpdate();
    return true;
  }

  function onPreviousPage() {
    //Sys.println("DEBUG: MyViewLogDelegate.onPreviousPage()");
    Ui.switchToView(new MyViewVarioplot(),
                    new MyViewVarioplotDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onNextPage() {
    //Sys.println("DEBUG: MyViewLogDelegate.onNextPage()");
    Ui.switchToView(new MyViewGeneral(),
                    new MyViewGeneralDelegate(),
                    Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
