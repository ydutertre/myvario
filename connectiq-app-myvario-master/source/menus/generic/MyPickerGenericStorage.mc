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
using Toybox.WatchUi as Ui;

class MyPickerGenericStorage extends Ui.Picker {

  //
  // FUNCTIONS: Ui.Picker (override/implement)
  //

  function initialize(_storage as Symbol, _action as Symbol) {
    // Retrieve object from storage <-> Picker
    var oPickerDictionary = null;
    var aiStorageKeys = new Array<Number>[$.MY_STORAGE_SLOTS];
    var asStorageValues = new Array<String>[$.MY_STORAGE_SLOTS];
    var iStorageUsed = 0;
    // ... storage specifics
    var sStorageName = MY_NOVALUE_BLANK;
    var sObjectName = "name";
    // ... action specifics
    var sStorageAction = MY_NOVALUE_BLANK;
    if(_action == :actionSave) {

      sStorageAction = Ui.loadResource(Rez.Strings.titleStorageSave) as String;
      // ... populate all slots
      for(var n=0; n<$.MY_STORAGE_SLOTS; n++) {
        var s = n.format("%02d");
        var d = App.Storage.getValue(format("stor$1$$2$", [sStorageName, s])) as Dictionary?;
        aiStorageKeys[n] = n;
        if(d != null) {
          asStorageValues[n] = format("[$1$]\n$2$", [s, d.get(sObjectName)]);
        }
        else {
          asStorageValues[n] = format("[$1$]\n---", [s]);
        }
        iStorageUsed++;
      }
      oPickerDictionary = new PickerFactoryDictionary(aiStorageKeys, asStorageValues, {:font => Gfx.FONT_TINY});
    }
    else if(_action == :actionLoad or _action == :actionDelete) {

      sStorageAction =
        _action == :actionLoad
        ? Ui.loadResource(Rez.Strings.titleStorageLoad) as String
        : Ui.loadResource(Rez.Strings.titleStorageDelete) as String;
      // ... pick existing objects/slots
      for(var n=0; n<$.MY_STORAGE_SLOTS; n++) {
        var s = n.format("%02d");
        var d = App.Storage.getValue(format("stor$1$$2$", [sStorageName, s])) as Dictionary?;
        if(d != null) {
          aiStorageKeys[iStorageUsed] = n;
          asStorageValues[iStorageUsed] = format("[$1$]\n$2$", [s, d.get(sObjectName)]);
          }
          iStorageUsed++;
        }
      }
      if(iStorageUsed > 0) {
        aiStorageKeys = aiStorageKeys.slice(0, iStorageUsed);
        asStorageValues = asStorageValues.slice(0, iStorageUsed);
        oPickerDictionary = new PickerFactoryDictionary(aiStorageKeys, asStorageValues, {:font => Gfx.FONT_TINY});
      }
      else {
        oPickerDictionary = new PickerFactoryDictionary([null], ["-"], {:color => Gfx.COLOR_DK_GRAY});
      }

    // Initialize picker
    if(oPickerDictionary != null) {
      Picker.initialize({
          :title => new Ui.Text({
              :text => sStorageAction,
              :font => Gfx.FONT_TINY,
              :locX=>Ui.LAYOUT_HALIGN_CENTER,
              :locY=>Ui.LAYOUT_VALIGN_BOTTOM,
              :color => Gfx.COLOR_BLUE}),
          :pattern => [oPickerDictionary]});
    }
  }

}

class MyPickerGenericStorageDelegate extends Ui.PickerDelegate {

  //
  // VARIABLES
  //

  private var storage as Symbol = :storageNone;
  private var action as Symbol = :actionNone;


  //
  // FUNCTIONS: Ui.PickerDelegate (override/implement)
  //

  function initialize(_storage as Symbol, _action as Symbol) {
    PickerDelegate.initialize();
    self.storage = _storage;
    self.action = _action;
  }

  function onAccept(_amValues) {
    // Save/load/delete object to/from storage
    if(_amValues[0] != null) {
      var s = (_amValues[0] as Number).format("%02d");
      // ... storage specifics
      var sStorageName = MY_NOVALUE_BLANK;
      if(sStorageName.length() > 0) {
        if(self.action == :actionSave) {

          var d = App.Storage.getValue(format("stor$1$InUse", [sStorageName])) as Dictionary?;
          if(d != null) {
            App.Storage.setValue(format("stor$1$$2$", [sStorageName, s]), LangUtils.copy(d) as App.PropertyValueType);  // WARNING: We MUST store a new (different) dictionary instance (deep copy)!
          }

        }
        else if(self.action == :actionLoad) {

          var d = App.Storage.getValue(format("stor$1$$2$", [sStorageName, s])) as Dictionary?;
          if(d != null) {
            App.Storage.setValue(format("stor$1$InUse", [sStorageName]), LangUtils.copy(d) as App.PropertyValueType);  // WARNING: We MUST store a new (different) dictionary instance (deep copy)!
          }
          Ui.popView(Ui.SLIDE_IMMEDIATE);  // one less button press to go back to main view

        }
        else if(self.action == :actionDelete) {

          App.Storage.deleteValue(format("stor$1$$2$", [sStorageName, s]));

        }
      }
    }

    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

  function onCancel() {
    // Exit
    Ui.popView(Ui.SLIDE_IMMEDIATE);
    return true;
  }

}
