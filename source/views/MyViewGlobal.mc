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
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class MyViewGlobal extends MyViewHeader {

  //
  // VARIABLES
  //

  // Resources
  // ... drawable
  protected var oRezDrawableGlobal as MyDrawableGlobal?;
  // ... fields
  protected var oRezValueTopLeft as Ui.Text?;
  protected var oRezValueTopRight as Ui.Text?;
  protected var oRezValueLeft as Ui.Text?;
  protected var oRezValueCenter as Ui.Text?;
  protected var oRezValueRight as Ui.Text?;
  protected var oRezValueBottomLeft as Ui.Text?;
  protected var oRezValueBottomRight as Ui.Text?;


  //
  // FUNCTIONS: MyViewHeader (override/implement)
  //

  function initialize() {
    MyViewHeader.initialize();

    // Display mode
    // ... internal
    self.bHeaderOnly = false;
  }

  function onLayout(_oDC) {
    MyViewHeader.onLayout(_oDC);

    // Load resources
    // ... drawable
    self.oRezDrawableGlobal = View.findDrawableById("MyDrawableGlobal") as MyDrawableGlobal;
    // ... fields
    self.oRezValueTopLeft = View.findDrawableById("valueTopLeft") as Ui.Text;
    self.oRezValueTopRight = View.findDrawableById("valueTopRight") as Ui.Text;
    self.oRezValueLeft = View.findDrawableById("valueLeft") as Ui.Text;
    self.oRezValueCenter = View.findDrawableById("valueCenter") as Ui.Text;
    self.oRezValueRight = View.findDrawableById("valueRight") as Ui.Text;
    self.oRezValueBottomLeft = View.findDrawableById("valueBottomLeft") as Ui.Text;
    self.oRezValueBottomRight = View.findDrawableById("valueBottomRight") as Ui.Text;
  }

}

class MyViewGlobalDelegate extends Ui.BehaviorDelegate {

  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() {
    //Sys.println("DEBUG: MyViewHeaderDelegate.onMenu()");
    Ui.pushView(new MyMenuGeneric(:menuSettings),
                new MyMenuGenericDelegate(:menuSettings),
                Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onSelect() {
    //Sys.println("DEBUG: MyViewHeaderDelegate.onSelect()");
    if($.oMyActivity == null) {
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
    //Sys.println("DEBUG: MyViewHeaderDelegate.onBack()");
    if($.oMyActivity != null) {

      return true;
    }
    return false;
  }

}
