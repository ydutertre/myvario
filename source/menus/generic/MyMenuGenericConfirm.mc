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
using Toybox.Position as Pos;
using Toybox.WatchUi as Ui;

// NOTE: Since Ui.Confirmation does not allow to pre-select "Yes" as an answer,
//       let's us our own "confirmation" menu and save one key press
class MyMenuGenericConfirm extends Ui.Menu {

  //
  // FUNCTIONS: Ui.Menu (override/implement)
  //

  function initialize(_context as Symbol, _action as Symbol) {
    Menu.initialize();
    Menu.setTitle(Ui.loadResource(Rez.Strings.titleConfirm) as String);
    if(_context == :contextActivity) {
      if(_action == :actionStart) {
        Menu.addItem(format("$1$ ?", [Ui.loadResource(Rez.Strings.titleActivityStart)]), :menuNone);
      }
      else if(_action == :actionSave) {
        Menu.addItem(format("$1$ ?", [Ui.loadResource(Rez.Strings.titleActivitySave)]), :menuNone);
      }
      else if(_action == :actionDiscard) {
        Menu.addItem(format("$1$ ?", [Ui.loadResource(Rez.Strings.titleActivityDiscard)]), :menuNone);
      }
    }
    else if(_context == :contextStorage) {
      if(_action == :actionClearLogs) {
        Menu.addItem(format("$1$ ?", [Ui.loadResource(Rez.Strings.titleStorageClearLogs)]), :menuNone);
      }
    }
  }

}

class MyMenuGenericConfirmDelegate extends Ui.MenuInputDelegate {

  //
  // VARIABLES
  //

  private var context as Symbol = :contextNone;
  private var action as Symbol = :actionNone;
  private var popout as Boolean = true;


  //
  // FUNCTIONS: Ui.MenuInputDelegate (override/implement)
  //

  function initialize(_context as Symbol, _action as Symbol, _popout as Boolean) {
    MenuInputDelegate.initialize();
    self.context = _context;
    self.action = _action;
    self.popout = _popout;
  }

  function onMenuItem(_item as Symbol) {
    if(self.context == :contextActivity) {
      if(self.action == :actionStart) {
        if($.oMyActivity == null) {
          $.oMyActivity = new MyActivity();
          ($.oMyActivity as MyActivity).start();
        }
      }
      else if(self.action == :actionSave) {
        if($.oMyActivity != null) {
          ($.oMyActivity as MyActivity).stop(true);
          $.oMyActivity = null;
        }
      }
      else if(self.action == :actionDiscard) {
        if($.oMyActivity != null) {
          ($.oMyActivity as MyActivity).stop(false);
          $.oMyActivity = null;
        }
      }
    }
    else if(self.context == :contextStorage) {
      if(self.action == :actionClearLogs) {
        (App.getApp() as MyApp).clearStorageLogs();
      }
    }
    if(self.popout) {
      Ui.popView(Ui.SLIDE_IMMEDIATE);
    }
  }

}
