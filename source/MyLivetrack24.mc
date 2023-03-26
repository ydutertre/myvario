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

import Toybox.Lang;
using Toybox.Cryptography as Crypt;
using Toybox.Math;
using Toybox.Time;
using Toybox.Timer;
using Toybox.System as Sys;
using Toybox.Communications as Comms;
using Toybox.WatchUi as Ui;
using Toybox.StringUtil as Su;

//
// CLASS
//

class MyLivetrack24 {

  //
  // CONSTANTS
  //
  

  //
  // VARIABLES
  //
  public var sLoginName as String = "";
  public var sPassword as String = "";
  public var sEquipment as String = "";
  public var iUserId as Number = 0;
  public var iSessionId as Long = 1l;
  public var bLivetrackStateful as Boolean = false;
  public var bWebRequestPending as Boolean = false;
  private var iPacketNumber as Number = 0;
  public var iCounter as Number = 0;
  public var bWrongCredentials = false;
  public var timeout as Number = 0;

  //
  // FUNCTIONS: self
  //

  function init(_sLoginName as String, _sPassword as String, _sEquipment as String) as Void {
    self.sLoginName = _sLoginName;
    self.sPassword = _sPassword;
    self.sEquipment = _sEquipment;
  }

  function reset() {
    self.iSessionId = 1;
    self.bWrongCredentials = false;
    self.iCounter = 0;
    self.iPacketNumber = 0;
    self.iUserId = 0;
    self.bWebRequestPending = false;
    self.bLivetrackStateful = false;
    self.timeout = 0;
  }

  function getUserId() {
    var url = "https://t2.livetrack24.com/client.php";
    
    var params = {
      "op" => "login",
      "user" => self.sLoginName,
      "pass" => self.sPassword
    };

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
    };

    self.bWebRequestPending = true;
    Comms.makeWebRequest(url, params, options, method(:onReceiveUserId));
  }

  function startSession() {
    var url = "https://t2.livetrack24.com/track.php";
    
    var params = {
      "leolive" => "2",
      "sid" => self.iSessionId.toString(),
      "pid" => self.iPacketNumber.toString(),
      "client" => "GarminMyVario",
      "user" => self.sLoginName,
      "pass" => self.sPassword,
      "v" => "1",
      "trk1" => $.oMySettings.iLivetrack24FrequencySeconds.toString(),
      "phone" => "GarminWatch",
      "gps" => "GarminGPS",
      "vname" => self.sEquipment,
      "vtype" => "1"
    };

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
    };
    self.iPacketNumber++;
    self.bWebRequestPending = true;
    Comms.makeWebRequest(url, params, options, method(:onReceiveStartTrack));
  }

  function updateSession(_fLat as Float, _fLon as Float, _iAlt as Number, _iSpeed as Number, _iCourse as Number, _iTimestamp as Number) {
    var url = "https://t2.livetrack24.com/track.php";
    
    var params = {
      "leolive" => "4",
      "sid" => self.iSessionId.toString(),
      "pid" => self.iPacketNumber.toString(),
      "lat" => _fLat.toString(),
      "lon" => _fLon.toString(),
      "alt" => _iAlt.toString(),
      "sog" => _iSpeed.toString(),
      "cog" => _iCourse.toString(),
      "tm" => _iTimestamp.toString()
    };

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
    };
    self.iPacketNumber++;
    Comms.makeWebRequest(url, params, options, method(:onReceiveDoNothing));
  }

  function stopSession() {
    var url = "https://t2.livetrack24.com/track.php";
    
    var params = {
      "leolive" => "3",
      "sid" => self.iSessionId.toString(),
      "pid" => self.iPacketNumber.toString(),
      "prid" => "0"
    };

    var options = {
      :method => Communications.HTTP_REQUEST_METHOD_GET,
      :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
    };
    self.iPacketNumber++;
    Sys.println(self.iPacketNumber.toString());
    Comms.makeWebRequest(url, params, options, method(:onReceiveDoNothing));
    self.bLivetrackStateful = false;
    self.bWebRequestPending = true;
  }

  function onReceiveUserId(_responseCode, _data) {
    if(_responseCode == 200 && _data != null) {
      self.iUserId = _data.toNumber();
      if(self.iSessionId != 0) {
        self.generateSessionId();
      } else {
        self.bWrongCredentials = true;
      }
    }
    self.bWebRequestPending = false;
    self.timeout = 0;
  }

  function onReceiveStartTrack(_responseCode, _data) {
    self.bLivetrackStateful = true;
    self.bWebRequestPending = false;
    self.timeout = 0;
  }

  function onReceiveDoNothing(_responseCode, _data) {
    return;
  }

  function generateSessionId() {
    var byteArray = Crypt.randomBytes(4);
    var rnd = byteArray.decodeNumber(Lang.NUMBER_FORMAT_UINT32, {:offset => 0, :endiannness => Lang.ENDIAN_LITTLE});
    self.iSessionId = (( rnd & 0x7F000000 ) | ( self.iUserId & 0x00ffffff) | 0x80000000) & 0x7fffffff;
    byteArray.encodeNumber(self.iSessionId, Lang.NUMBER_FORMAT_UINT32, {:offset => 0, :endiannness => Lang.ENDIAN_LITTLE});
    self.iSessionId = byteArray.decodeNumber(Lang.NUMBER_FORMAT_UINT32, {:offset => 0, :endiannness => Lang.ENDIAN_LITTLE});
  }

}
