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
using Toybox.Math;
using Toybox.System as Sys;

//
// CLASS
//

// We use Simple Moving Average (SMA) to smoothen the sensor values over
// the user-specified "time constant" or time period.

class MyFilter {

  //
  // CONSTANTS
  //

  // Filter (maximum) size / time constant + 1
  private const MAX_SIZE = 61;

  // Filter "refresh" counter
  private const REFRESH_COUNTER = 300;  // every 5 minutes (if values are fed every second)

  // Filters (<-> sensors)
  public const ALTIMETER = 0;
  public const GROUNDSPEED = 1;
  public const VARIOMETER = 2;
  public const ACCELERATION = 3;
  public const HEADING_X = 4;
  public const HEADING_Y = 5;
  public const RATEOFTURN = 6;
  private const FILTERS = 7;


  //
  // VARIABLES
  //

  // Filters
  private var aaFilters as Array<Array>;


  //
  // FUNCTIONS: self
  //

  function initialize() {
    // Initialze the filters container array
    aaFilters = new Array<Array>[self.FILTERS];

    // Loop through each filter
    for(var F=0; F<self.FILTERS; F++) {
      // Create the filter array, containing:
      // [0] refresh counter
      // [1] filter length
      // [2] current value index (starting form 0)
      // [3] sum of all values
      // [4+] values history
      self.aaFilters[F] = new Array[self.MAX_SIZE+4];
      self.aaFilters[F][0] = Math.rand() % self.REFRESH_COUNTER;  // let's no refresh all filters at the same time
      self.aaFilters[F][1] = 1;
      self.resetFilter(F);
    }
  }

  function importSettings() as Void {
    // Retrieve the new filter length (user-defined time constant + 1)
    var iFilterLength_new = $.oMySettings.iGeneralTimeConstant+1;

    // Loop through each filter
    for(var F=0; F<self.FILTERS; F++) {
      if(self.aaFilters[F][1] != iFilterLength_new) {
        // Store the filter length
        self.aaFilters[F][1] = iFilterLength_new;

        // Reset the filter (values)
        self.resetFilter(F);
      }
    }
  }

  function resetFilter(_F as Number) as Void {
    //Sys.println(format("DEBUG: MyFilter.resetFilter($1$)", [_F]));

    // Reset the current value index
    self.aaFilters[_F][2] = 0;

    // Reset the sum of all values
    self.aaFilters[_F][3] = 0;

    // Reset the values history
    for(var i=0; i<self.aaFilters[_F][1]; i++) {
      self.aaFilters[_F][4+i] = null;
    }
  }

  function filterValue(_F as Number, _fValue as Float) as Float {
    //Sys.println(format("DEBUG: MyFilter.filterValue($1$, $2$)", [_F, _fValue]));

    // Check the refresh counter
    if(self.aaFilters[_F][0] == 0) {
      // Re-compute the sum of all values, which may diverge over time (given numeric imprecisions)
      //Sys.println(format("DEBUG: (Filter[$1$]) Refreshing", [_F]));
      self.aaFilters[_F][3] = 0.0f;
      for(var i=0; i<self.aaFilters[_F][1]; i++) {
        if(self.aaFilters[_F][4+i] == null) {
          break;
        }
        self.aaFilters[_F][3] += self.aaFilters[_F][4+i];
      }

      // Reset the refresh counter
      self.aaFilters[_F][0] = self.REFRESH_COUNTER;
    }
    else {
      // Decrease the refresh counter
      self.aaFilters[_F][0] -= 1;
    }

    // Retrieve the previous "current" value and store the new one in its place
    var fValue_previous = self.aaFilters[_F][4+self.aaFilters[_F][2]];
    self.aaFilters[_F][4+self.aaFilters[_F][2]] = _fValue;

    // Update the sum of all values, by:
    // 1. adding the new (current) value
    // 2. substracting the previous "current" value (if available)
    // WARNING: numeric imprecisions will creep in and make the sum diverge over time!
    var iValues_quantity;
    self.aaFilters[_F][3] += _fValue;
    if(fValue_previous != null) {
      self.aaFilters[_F][3] -= fValue_previous;
      iValues_quantity = self.aaFilters[_F][1];
    }
    else {
      iValues_quantity = self.aaFilters[_F][2] + 1;
    }
    //Sys.println(format("DEBUG: (Filter[$1$]) Sum/Length = $2$/$3$", [_F, self.aaFilters[_F][3], iValues_quantity]));

    // Increase the current value index
    self.aaFilters[_F][2] = (self.aaFilters[_F][2] + 1) % self.aaFilters[_F][1];

    // Return the SMA-filtered value (sum of all values divided by quantity of values)
    return self.aaFilters[_F][3]/iValues_quantity;
  }

}
