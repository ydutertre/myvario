// -*- mode:java; tab-width:2; c-basic-offset:2; intent-tabs-mode:nil; -*- ex: set tabstop=2 expandtab:

// My Vario
// Copyright (C) 2023 Yannick Dutertre <https://yannickd9.wixsite.com/myvario>
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
using Toybox.Application;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.WatchUi;
using Toybox.BluetoothLowEnergy as Ble;

class MyActiveLook
{
    var oBleOperations as BleOperations;
    public var bBleIsWriting as Boolean;
    public var bBleConnected as Boolean;
    public var bBleBufferWarning as Boolean;
    public var sOldAltitude as String = "";
    public var sAltitude as String = "--";
    public var sOldVerticalSpeed as String = "";
    public var sVerticalSpeed as String = "--";
    public var sOldFinesse as String = "";
    public var sFinesse as String = "--";
    public var sOldGroundSpeed as String = "";
    public var sGroundSpeed as String = "--";
    public var sOldHeading as String = "";
    public var sHeading as String = "--";

    function init() {
        oBleOperations = new BleOperations();
        Ble.setDelegate(oBleOperations);
        bBleIsWriting = false;
        bBleConnected = false;
        bBleBufferWarning = false;
        sOldAltitude = "";
        sAltitude = "--";
        sOldVerticalSpeed = "";
        sVerticalSpeed = "--";
        sOldFinesse = "";
        sFinesse = "--";
        sOldGroundSpeed = "";
        sGroundSpeed = "--";
        sOldHeading = "";
        sHeading = "--";
    }

    function onStart() {
    }

    public function findAndPair() {
        Ble.setScanState(Ble.SCAN_STATE_SCANNING);
    }

    public function isScanning() {
        return oBleOperations.isScanning();
    }

    public function stopScanning() {
        Ble.setScanState(Ble.SCAN_STATE_OFF);
    }

    public function writeUpdate() {
        if(!self.sOldAltitude.equals(self.sAltitude)) {
            setAltitude(self.sAltitude);
        }
        if(!self.sOldVerticalSpeed.equals(self.sVerticalSpeed)) {
            setVerticalSpeed(self.sVerticalSpeed);
        }
        if(!self.sOldFinesse.equals(self.sFinesse)) {
            setFinesse(self.sFinesse);
        }
        if(!self.sOldGroundSpeed.equals(self.sGroundSpeed)) {
            setGroundSpeed(self.sGroundSpeed);
        }
        if(!self.sOldHeading.equals(self.sHeading)) {
            setHeading(self.sHeading);
        }
    }

    public function setFinesse(_finesse as String) {
        if(!bBleIsWriting && bBleConnected && !bBleBufferWarning){
            var baCommandArray = [0xFF,0x6A,0x00,0x0E,0x38,0x00,0x1E,0x5F]b;
            baCommandArray.addAll(stringToByteArray(_finesse));
            baCommandArray.add(0xAA);
            bBleIsWriting = true;
            oBleOperations.oBleCharacteristic.requestWrite(baCommandArray, {:writeType => Ble.WRITE_TYPE_DEFAULT});
            self.sOldFinesse = self.sFinesse;
        }
    }

    public function setGroundSpeed(_groundSpeed as String) {
        if(!bBleIsWriting && bBleConnected && !bBleBufferWarning){
            var baCommandArray = [0xFF,0x6A,0x00,0x0E,0x30,0x00,0x9D,0x21]b;
            baCommandArray.addAll(stringToByteArray(_groundSpeed));
            baCommandArray.add(0xAA);
            bBleIsWriting = true;
            oBleOperations.oBleCharacteristic.requestWrite(baCommandArray, {:writeType => Ble.WRITE_TYPE_DEFAULT});
            self.sOldGroundSpeed = self.sGroundSpeed;
        }
    }

    public function setHeading(_heading as String) {
        if(!bBleIsWriting && bBleConnected && !bBleBufferWarning){
            var baCommandArray = [0xFF,0x6A,0x00,0x0E,0x2E,0x00,0x1E,0x21]b;
            if($.oMySettings.iUnitDirection == 1){
                baCommandArray.addAll(headingToByteArray(_heading)); //remove one space for alignment
            } else {
                baCommandArray.addAll(stringToByteArray(_heading));
            }
            baCommandArray.add(0xAA);
            bBleIsWriting = true;
            oBleOperations.oBleCharacteristic.requestWrite(baCommandArray, {:writeType => Ble.WRITE_TYPE_DEFAULT});
            self.sOldHeading = self.sHeading;
        }
    }

    public function setAltitude(_altitude as String) {
        if(!bBleIsWriting && bBleConnected && !bBleBufferWarning){
            var baCommandArray = [0xFF,0x69,0x00,0x0B,0x7C]b;
            baCommandArray.addAll(stringToByteArray(_altitude)); 
            baCommandArray.add(0xAA);
            bBleIsWriting = true;
            oBleOperations.oBleCharacteristic.requestWrite(baCommandArray, {:writeType => Ble.WRITE_TYPE_DEFAULT});
            self.sOldAltitude = self.sAltitude;
        }
    }

    public function setVerticalSpeed(_verticalSpeed as String) {
        if(!bBleIsWriting && bBleConnected && !bBleBufferWarning){
            var baCommandArray = [0xFF,0x6A,0x00,0x0E,0x2F,0x00,0x9D,0x5F]b;
            baCommandArray.addAll(stringToByteArray(_verticalSpeed));
            baCommandArray.add(0xAA);
            bBleIsWriting = true;
            oBleOperations.oBleCharacteristic.requestWrite(baCommandArray, {:writeType => Ble.WRITE_TYPE_DEFAULT});
            self.sOldVerticalSpeed = self.sVerticalSpeed;
        }
    }

    public function hold() {
        if(!bBleIsWriting && bBleConnected && !bBleBufferWarning){
            var baCommandArray = [0xFF,0x39,0x00,0x06,0x00,0xAA]b;
            bBleIsWriting = true;
            oBleOperations.oBleCharacteristic.requestWrite(baCommandArray, {:writeType => Ble.WRITE_TYPE_DEFAULT});
        }
    }

    public function flush() {
        if(!bBleIsWriting && bBleConnected && !bBleBufferWarning){
            var baCommandArray = [0xFF,0x39,0x00,0x06,0x00,0xAA]b;
            bBleIsWriting = true;
            oBleOperations.oBleCharacteristic.requestWrite(baCommandArray, {:writeType => Ble.WRITE_TYPE_DEFAULT});
        }
    }

    public function shutDown() {
        if(!bBleIsWriting && bBleConnected && !bBleBufferWarning){
            var baCommandArray = [0xFF,0xE0,0x00,0x09,0x6F,0x7F,0xC4,0xEE,0xAA]b;
            bBleIsWriting = true;
            oBleOperations.oBleCharacteristic.requestWrite(baCommandArray, {:writeType => Ble.WRITE_TYPE_DEFAULT});
        }
    }

    public function clearScreen() {
        if(!bBleIsWriting && bBleConnected && !bBleBufferWarning){
            var baCommandArray = [0xFF,0x01,0x00,0x05,0xAA]b;
            bBleIsWriting = true;
            oBleOperations.oBleCharacteristic.requestWrite(baCommandArray, {:writeType => Ble.WRITE_TYPE_DEFAULT});
        }
    }

    function stringToByteArray(_text as String) as ByteArray {
        var caNumberAsChars = _text.toCharArray();
        var baNumberAsByteArray = []b;
        
        if(caNumberAsChars.size() == 0) {
            return null;
        }
        else if(caNumberAsChars.size() == 1) {
            baNumberAsByteArray.addAll(['&','$','$','$']);
        }
        else if (caNumberAsChars.size() == 2) {
            baNumberAsByteArray.addAll(['&','$','$']);
        }
        else if(caNumberAsChars.size() == 3) {
            baNumberAsByteArray.addAll(['&','$']);
        }
        else if (caNumberAsChars.size() == 4) {
            baNumberAsByteArray.add('&');
        }
        for(var i = 0; i < caNumberAsChars.size(); i++) {
            if (i > 4) { break; }
            baNumberAsByteArray.add(caNumberAsChars[i]);
        }
        return baNumberAsByteArray;
    }

    function headingToByteArray(_text as String) as ByteArray {
        var caNumberAsChars = _text.toCharArray();
        var baNumberAsByteArray = []b;
        
        if(caNumberAsChars.size() == 0) {
            return null;
        }
        else if(caNumberAsChars.size() == 1) {
            baNumberAsByteArray.addAll(['&','&','&','&']);
        }
        else if (caNumberAsChars.size() == 2) {
            baNumberAsByteArray.addAll(['&','&','&']);
        }
        else if(caNumberAsChars.size() == 3) {
            baNumberAsByteArray.addAll(['&','&']);
        }
        else if (caNumberAsChars.size() == 4) {
            baNumberAsByteArray.add('&');
        }
        for(var i = 0; i < caNumberAsChars.size(); i++) {
            if (i > 4) { break; }
            baNumberAsByteArray.add(caNumberAsChars[i]);
        }
        return baNumberAsByteArray;
    }

    function unPair() {
        if(oBleOperations.oBleDevice != null) {
            Ble.unpairDevice(oBleOperations.oBleDevice);
        }
    }
}

 
class BleOperations extends Ble.BleDelegate
{
    hidden var _scanState as Number;
    hidden var _profileRegistered = false;
    public var oBleDevice;
    public var oBleService;
    public var oBleCharacteristic;
    public var oNotificationCharacteristic;
 
    function initialize() {
        BleDelegate.initialize();
        _scanState = Ble.SCAN_STATE_OFF;
    }
 
    function onStart() {
    }
 
    function onStop() {
    }
 
    public function onConnectedStateChanged(device as Ble.Device, state as Ble.ConnectionState) as Void {
        if(state == Ble.CONNECTION_STATE_CONNECTED && device != null){
            oBleDevice = device;
            oBleService = oBleDevice.getService(Ble.stringToUuid("0783b03e-8535-b5a0-7140-a304d2495cb7"));
            if(oBleService != null) {
                oBleCharacteristic = oBleService.getCharacteristic(Ble.stringToUuid("0783b03e-8535-b5a0-7140-a304d2495cbA")); //Rx Server characteristic
                oNotificationCharacteristic = oBleService.getCharacteristic(Ble.stringToUuid("0783b03e-8535-b5a0-7140-a304d2495cb9")); //Control characteristic
                var oCccd = oNotificationCharacteristic.getDescriptor(BluetoothLowEnergy.cccdUuid()); // Control descriptor
                $.oMyActiveLook.bBleIsWriting = true;
                oCccd.requestWrite([0x01,0x00]b); //Turn notifications on
                $.oMyActiveLook.bBleConnected = true;
                $.oMyActiveLook.clearScreen();
            }
        }
        if(state == Ble.CONNECTION_STATE_DISCONNECTED) {
            $.oMyActiveLook.bBleConnected = false;
            $.oMyProcessing.timeElapsed = 0;    //Reset scanning timeout to attempt to reconnect to device
            $.oMyActiveLook.findAndPair();
        }
    }

    function onCharacteristicWrite(characteristic, status) {
        $.oMyActiveLook.bBleIsWriting = false;
        $.oMyActiveLook.writeUpdate();
    }

    function onDescriptorWrite(descriptor, status) {
        $.oMyActiveLook.bBleIsWriting = false;
        $.oMyActiveLook.clearScreen();
    }
 
    function onScanResults(scanResults) { 
        // add/update result
        var scanResult = scanResults.next();

        while (scanResult != null) {
            var manufacturerInfo = scanResult.getManufacturerSpecificDataIterator().next();
            if(manufacturerInfo != null && manufacturerInfo.get(:data).decodeNumber(Lang.NUMBER_FORMAT_UINT16, {:offset => 0, :endianness => Lang.ENDIAN_BIG}) == 2290) { //Search for ActiveLook manufacturer
                if(!_profileRegistered) {
                    registerProfiles();
                    _profileRegistered = true;
                }
                Ble.setScanState(Ble.SCAN_STATE_OFF);
                Ble.pairDevice(scanResult);
            }
            scanResult = scanResults.next();
        }
     }
 
    function registerProfiles() {
        var profile = {                                                  
           :uuid => Ble.stringToUuid("0783b03e-8535-b5a0-7140-a304d2495cb7"), //Activelook Custom Service UUID
           :characteristics => [ {                                     
                   :uuid => Ble.stringToUuid("0783b03e-8535-b5a0-7140-a304d2495cbA"),     //Activelook RX writable characteristic
                   :descriptors => [                                    
                       Ble.stringToUuid("00002902-0000-1000-8000-00805F9B34FB"),       //Configuration descriptor
                       Ble.stringToUuid("00002901-0000-1000-8000-00805F9B34FB") ] },
                    {                                     
                   :uuid => Ble.stringToUuid("0783b03e-8535-b5a0-7140-a304d2495cb9"),     //Activelook Control Notification characteristic
                   :descriptors => [                                    
                       Ble.stringToUuid("00002902-0000-1000-8000-00805F9B34FB"),       //Configuration descriptor
                       Ble.stringToUuid("00002901-0000-1000-8000-00805F9B34FB") ] }]   //Server Rx Data descriptor
       };
       // Make the registerProfile call
       Ble.registerProfile( profile );
    }
 
    function onCharacteristicChanged(characteristic, value) {
        if(value != null && value.size() > 0) {
            if(value[0] == 0x01) { $.oMyActiveLook.bBleBufferWarning = false; }
            if(value[0] == 0x02) { $.oMyActiveLook.bBleBufferWarning = true; }
        }
    }

    function onScanStateChange(scanState, status) {
        _scanState = scanState;
    }
 
    public function isScanning() {
        return _scanState != Ble.SCAN_STATE_OFF;
    }
}