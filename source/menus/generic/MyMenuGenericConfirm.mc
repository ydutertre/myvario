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
using Toybox.Position as Pos;
using Toybox.WatchUi as Ui;

class MyMenuConfirmDiscard extends Ui.View {

  function initialize() {
    View.initialize();
  }

  function onLayout(_oDC) {
    View.setLayout(Rez.Layouts.DeleteConfirmationPage(_oDC));
  }

  function onUpdate(_oDC) {
    View.onUpdate(_oDC);
  }
}

class MyMenuConfirmDiscardDelegate extends Ui.InputDelegate {

  var action as Symbol = :actionNone;
  var popout as Boolean = true;
  
  function initialize(_action as Symbol, _popout as Boolean) {
    InputDelegate.initialize();

    self.action = _action;
    self.popout = _popout;
  }
  (:icon)
  function onKey(evt as Ui.KeyEvent) as Boolean {
    if (Rez.Styles.confirmation_input__delete has :button && evt.getKey() == Rez.Styles.confirmation_input__delete.button) {
    // if (evt.getKey() == KEY_ENTER) {
      if(action == :actionDiscard) {
        ($.oMyActivity as MyActivity).stop(false);
        $.oMyActivity = null;
      } else if(action == :actionClearLogs) {
        (App.getApp() as MyApp).clearStorageLogs();
      }
      if(self.popout) {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
      }
      Ui.popView( Ui.SLIDE_IMMEDIATE );
      return true;
    } 
    else if(Rez.Styles.confirmation_input__keep has :button && evt.getKey() == Rez.Styles.confirmation_input__keep.button) {
    // else if([KEY_ENTER, KEY_UP, KEY_CLOCK].indexOf(evt.getKey()) < 0) {
      // doRejectAction();
      Ui.popView(Ui.SLIDE_LEFT);
      return true;
    } 
    return false;
  }
}

class MyMenuGenericConfirmDelegate extends Ui.MenuInputDelegate {

  private var context as Symbol = :contextNone;
  private var action as Symbol = :actionNone;
  private var popout as Boolean = true;

  function initialize(_context as Symbol, _action as Symbol, _popout as Boolean) {
      ConfirmationDelegate.initialize();
      self.context = _context;
      self.action = _action;
      self.popout = _popout;
  }

  function onResponse(response) {
    if (response == Ui.CONFIRM_YES) {
      if(context == :contextActivity) {
        if(action == :actionStart) {
          if ($.oMyActivity == null) {
            $.oMyActivity = new MyActivity();
            ($.oMyActivity as MyActivity).start();
          }
        }
        else if(action == :actionSave) {
          if($.oMyActivity != null) {
            ($.oMyActivity as MyActivity).stop(true);
            $.oMyActivity = null;
            // Ui.popView(Ui.SLIDE_IMMEDIATE);
            // Ui.popView(Ui.SLIDE_IMMEDIATE);
            // Ui.switchToView(new MyViewLog(), new MyViewLogDelegate(), Ui.SLIDE_BLINK);
            // Ui.pushView(new MyViewLog(), null, Ui.SLIDE_BLINK);
          }
        }
        else if(action == :actionDiscard) {
          if($.oMyActivity != null) {
            ($.oMyActivity as MyActivity).stop(false);
            $.oMyActivity = null;
            Ui.popView( Ui.SLIDE_IMMEDIATE );
          }
        }
      }
      else if(context == :contextStorage) {
        if(action == :actionClearLogs) {
          (App.getApp() as MyApp).clearStorageLogs();
          Ui.popView( Ui.SLIDE_IMMEDIATE );
          
        }
      }
      if(self.popout) {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
      }
      return true;
    }
    return false;
  }

}
