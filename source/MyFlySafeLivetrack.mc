// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (C) 2022-2024 Yannick Dutertre <https://yannickd9.wixsite.com/myvario>
//                         and contributors:
//                         Lenart Kos <lenart@wgn.si> 
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

using Toybox.System as Sys;
using Toybox.Communications as Comms;
import Toybox.Lang;
import Toybox.Position;
import Toybox.Math;

//
// CLASS
//

class MyFlySafeLivetrack {

  //
  // CONSTANTS
  //
  private const FLYSAFE_LIVETRACK_URL = "https://flysafe.pro/mobile/loc";

  //
  // VARIABLES
  //
  private var sUserId as Lang.String = "";
  private var sUserToken as Lang.String = "";
  private var xAuthToken as Lang.String = "";
  public var iCounter as Lang.Integer = 0;

  //
  // FUNCTIONS: self
  //

  function init(_sUserId as Lang.String, _sUserToken as Lang.String) as Void {
    if (_sUserId == null || _sUserToken == null ||
        _sUserId.equals("") || _sUserToken.equals("") ||
        _sUserId.equals("UserID") || _sUserToken.equals("Token")) {
      // Sys.println("DEBUG: No user ID or user token, not sending data");
      xAuthToken = "";
      return;
    }
    if (_sUserId.equals(sUserId) && _sUserToken.equals(sUserToken)) {
      // Sys.println("DEBUG: User ID and user token unchanged");
      return;
    }
    sUserId = _sUserId;
    sUserToken = _sUserToken;
    xAuthToken = Lang.format("$1$__$2$", [_sUserId, _sUserToken]);
    // Sys.println("DEBUG: Auth token: " + xAuthToken);
  }

  function reset() {
    xAuthToken = "";
    iCounter = 0;
  }

  function updatePosition(_info as Position.Info, _location as Position.Location, _fAltitude as Lang.Float) as Void {
    // Sys.println("DEBUG: FlySafe updating position");
    if (xAuthToken.equals("") || _info.accuracy == Position.QUALITY_NOT_AVAILABLE) {
      // Sys.println("DEBUG: No auth token or no GPS fix, not sending data");
      return;
    }

    // Estimate accuracy from enum...
    var iAccuracy = 9999;
    switch (_info.accuracy) {
      case Position.QUALITY_GOOD:
        iAccuracy = 10;
        break;
      case Position.QUALITY_USABLE:
        iAccuracy = 50;
        break;
      case Position.QUALITY_POOR:
        iAccuracy = 300;
        break;
    }

    var locDeg = _location.toDegrees();
    var headingDeg = Math.toDegrees(_info.heading);

    // Send data to FlySafe
    // Use string concatenation, no json library available
    var parameters = {
      "data" => "[{" +
        Lang.format("\"id\": \"$1$\", ", [xAuthToken])  +   // Auth token
        Lang.format("\"lat\": $1$, ", [locDeg[0]])      +   // Latitude in degrees
        Lang.format("\"lon\": $1$, ", [locDeg[1]])      +   // Longitude in degrees
        Lang.format("\"accuracy\": $1$, ", [iAccuracy]) +   // Accuracy in meters
        Lang.format("\"alt\": $1$, ", [_fAltitude])     +   // Altitude in meters
        Lang.format("\"speed\": $1$, ", [_info.speed])  +   // Speed in m/s
        Lang.format("\"heading\": $1$, ", [headingDeg]) +   // Heading in degrees
        Lang.format("\"time\": $1$000, ", [_info.when.value()]) + // Unix time in milliseconds (3 zeros added to the end),
                                                                  // NOTE: This will break in 2038, but this is a Garmin problem for the whole SDK... LOL!
        "\"track\": \"gps GarminMyVario\", " + // Location provider and device name
        "\"livetrack\": true, " +   // Flag to indicate that this is a live track
        "\"public\": true" +        // Flag to indicate that this is a public track
      "}]"
    };

    // Sys.println("DEBUG: Sending data to FlySafe '" + parameters["data"] + "'");
    var options = {
      :method => Comms.HTTP_REQUEST_METHOD_POST,
      :responseType => Comms.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN,
      :headers => {
        "Content-Type" => Comms.REQUEST_CONTENT_TYPE_URL_ENCODED
      }
    };
    Comms.makeWebRequest(FLYSAFE_LIVETRACK_URL, parameters, options, method(:onReceiveDoNothing));
  }

  function onReceiveDoNothing(_responseCode, _data) as Void {
    // Intentionally empty
  }
}
