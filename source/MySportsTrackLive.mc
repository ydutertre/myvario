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

import Toybox.Lang;
using Toybox.Cryptography as Crypt;
using Toybox.Math;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.System as Sys;
using Toybox.Communications as Comms;
using Toybox.WatchUi as Ui;
using Toybox.StringUtil as Su;

//
// CLASS
//

class MySportsTrackLive {

  //
  // CONSTANTS
  //
  

  //
  // VARIABLES
  //
  public var sLoginEmail as String = "";
  public var sPassword as String = "";
  public var sSessionToken as String = "";
  public var bLivetrackStateful as Boolean = false;
  public var bWebRequestPending as Boolean = false;
  public var bWrongCredentials = false;
  public var adPoints as Array<Dictionary>;
  public var iTrackId as Number = 0;
  public var iCounter as Number = 0;
  public var timeout as Number = 0;
  private var secretKey as String = "censored"; //REMOVE BEFORE GITHUB!!

  //
  // FUNCTIONS: self
  //

  function init(_sLoginEmail as String, _sPassword as String) as Void {
    self.sLoginEmail = _sLoginEmail;
    self.sPassword = _sPassword;
    self.adPoints = new Array<Dictionary>[$.oMySettings.iSportsTrackLiveFrequencySeconds];
  }

  function reset() {
    self.sSessionToken = "";
    self.iTrackId = 0;
    self.bWrongCredentials = false;
    self.bWebRequestPending = false;
    self.bLivetrackStateful = false;
    self.iCounter = 0;
    self.timeout = 0;
    self.adPoints = new Array<Dictionary>[$.oMySettings.iSportsTrackLiveFrequencySeconds];
  }

  function getUserToken() {
    var url = "https://api.sportstracklive.com/v1/auth";
    
    var params = {
      "email" => self.sLoginEmail,
      "password" => self.sPassword,
      "origin" => "external"
    };

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :headers => {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
        "X-STL-Secret-Key" => self.secretKey
      }
    };

    self.bWebRequestPending = true;
    Comms.makeWebRequest(url, params, options, method(:onReceiveUserId));
  }

  function startSession(_fLat as Float, _fLon as Float, _iAlt as Number, _iSpeed as Number, _iCourse as Number) {
    var url = "https://api.sportstracklive.com/v1/track";
    
    var params = {
      "track" => {
        "category_name" => "paragliding",
        "track_type" => "live_track"
      },
      "location" => {
        "latitude" => _fLat,
        "longitude" => _fLon,
        "speed" => _iSpeed,
        "bearing" => _iCourse,
        "altitude" => _iAlt,
        "date" => self.getTime()
      }
    };
    
    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_POST,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :headers => {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
        "X-STL-Token" => self.sSessionToken,
        "X-STL-Secret-Key" => self.secretKey
      }
    };

    self.bWebRequestPending = true;
    Comms.makeWebRequest(url, params, options, method(:onReceiveStartTrack));
  }

  function updateSession() {
    var url = "https://api.sportstracklive.com/v1/track/"+self.iTrackId.toString()+"/points";
    
    var params = {
      "points" => self.adPoints
    };

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_PUT,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :headers => {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
        "X-STL-Token" => self.sSessionToken
      }
    };

    Comms.makeWebRequest(url, params, options, method(:onReceiveDoNothing));
  }

  function stopSession() {
    var url = "https://api.sportstracklive.com/v1/track/"+self.iTrackId.toString()+"/end_live";
    
    var params = {};

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_PUT,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
      :headers => {
        "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
        "X-STL-Token" => self.sSessionToken
      }
    };

    Comms.makeWebRequest(url, params, options, method(:onReceiveDoNothing));
    self.bLivetrackStateful = false;
    self.bWebRequestPending = true;
  }

  function onReceiveUserId(_responseCode, _data) {
    if(_responseCode == 200 && _data != null) {
      self.sSessionToken = _data.get("token");
      if(self.sSessionToken == "") {
        self.bWrongCredentials = true;
      }
    } else {
      self.bWrongCredentials = true;
    }
    self.bWebRequestPending = false;
    self.timeout = 0;
  }

  function onReceiveStartTrack(_responseCode, _data) {
    if(_responseCode == 200 && _data != null) {
      self.bLivetrackStateful = true;
      self.iTrackId = _data.get("track").get("id");
    }
    self.bWebRequestPending = false;
    self.timeout = 0;
  }

  function onReceiveDoNothing(_responseCode, _data) {
    return;
  }

  function getTime() as String {
    var now = Gregorian.utcInfo(Time.now(), Time.FORMAT_SHORT);
    var dateString = "";
    dateString = Lang.format(
    "$1$-$2$-$3$ $4$:$5$:$6$ +0000",
    [
      now.year.format("%04u"),
      now.month.format("%02u"),
      now.day.format("%02u"),
      now.hour.format("%02u"),
      now.min.format("%02u"),
      now.sec.format("%02u"),
    ]
    );
    return dateString;
  }

  function addPoint(_fLat as Float, _fLon as Float, _iAlt as Number, _iSpeed as Number, _iCourse as Number) {
    adPoints.add(
      {
        "latitude" => _fLat,
        "longitude" => _fLon,
        "speed" => _iSpeed,
        "bearing" => _iCourse,
        "altitude" => _iAlt,
        "date" => getTime()
      }
    );
  }
}
