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
using Toybox.System as Sys;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

class MyActiveLook
{
    //BLE and ActiveLook related variables
    var oBleOperations as BleOperations;
    public var abaCommandQueue = []; //Queue for write commands, as only one can be sent at a time
    public var bBleIsWriting as Boolean;
    public var bBleConnected as Boolean;
    public var bBleBufferWarning as Boolean;
    public var bReconnecting as Boolean;
    public var iTimer as Number = 100000;
    public var bExpectedDisconnect = false;
    public var iCommandCounter as Number = 0;
    public var baLastCommand = []b;
    public var iCurrentFirmwareMajor as Number = 5;
    public var iCurrentFirmwareMinor as Number = 6;

    //Display Data variables
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
    public var sOldTime as String = "  :  ";
    public var sTime as String = "--:--";
    public var sOldFlightTime as String = "  :  ";
    public var sFlightTime as String = "--:--";

    function init() {
        oBleOperations = new BleOperations();
        Ble.setDelegate(oBleOperations);
        bBleIsWriting = false;
        bBleConnected = false;
        bBleBufferWarning = false;
        bReconnecting = false;
        bExpectedDisconnect = false;
        iTimer = 100000;
        iCommandCounter = 0;
        iCurrentFirmwareMajor = 5;
        iCurrentFirmwareMinor = 6;
        setDefaults();
    }

    function onStart() {
    }

    public function setDefaults() {
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
        sOldTime = "  :   ";
        sTime = "--:--";
        sOldFlightTime = "  :  ";
        sFlightTime = "--:--";
    }

    public function processQueue(writeType as Number) {
        if(!bBleIsWriting && bBleConnected && !bBleBufferWarning && abaCommandQueue.size() > 0 && !bReconnecting) {
            var baCommandArray = abaCommandQueue[0];
            abaCommandQueue.remove(baCommandArray);
            bBleIsWriting = true;
            iTimer = 5;
            iCommandCounter++;
            try {
                oBleOperations.oBleCharacteristic.requestWrite(baCommandArray, {:writeType => writeType});
                baLastCommand = baCommandArray;
            }
            catch(ex) {
                iTimer = 100000;
                iCommandCounter--;
            }
        }
    }

    public function clearQueue() {
        abaCommandQueue = [];
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

    
    public function storeUpdate() {
        hold();
        setAltitude(self.sAltitude);
        setVerticalSpeed(self.sVerticalSpeed);
        setFinesse(self.sFinesse);
        setGroundSpeed(self.sGroundSpeed);
        setHeading(self.sHeading);
        self.sTime = getTime();
        setTime(self.sTime);
        self.sFlightTime = getFlightTime();
        setFlightTime(self.sFlightTime);
        flush();
    }

    public function writeUpdate() {
        if (!bBleBufferWarning && !bReconnecting && iCommandCounter >=8) {
            self.storeUpdate();
            processQueue(Ble.WRITE_TYPE_DEFAULT);
        }
    }
    
    public function getFlightTime() as String {
        if($.oMyActivity != null && $.oMyActivity.oTimeStart != null) {
            var iDurationSeconds = (Time.now().subtract($.oMyActivity.oTimeStart)).value();
            var iDurationHours = iDurationSeconds / 3600;
            var iDurationMinutes = (iDurationSeconds % 3600) / 60;
            return iDurationHours.format("%02d") + ":" + iDurationMinutes.format("%02d");
        }
        return "--:--";
    }

    public function getTime() as String {
        var oTimeInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        return format("$1$$2$$3$", [oTimeInfo.hour.format("%02d"), ":", oTimeInfo.min.format("%02d")]);
    }

    public function setFinesse(_finesse as String) {
        if(!self.sOldFinesse.equals(self.sFinesse)) {
            var baCommandArray = [0xFF,0x6A,0x00,0x0E,0x38,0x00,0x1E,0x53]b;
            baCommandArray.addAll(stringToByteArray(_finesse));
            baCommandArray.add(0xAA);
            self.abaCommandQueue.add(baCommandArray);
            self.sOldFinesse = self.sFinesse;
        }
    }

    public function setGroundSpeed(_groundSpeed as String) {
        if(!self.sOldGroundSpeed.equals(self.sGroundSpeed)){
            var baCommandArray = [0xFF,0x6A,0x00,0x0E,0x30,0x00,0x9D,0x21]b;
            baCommandArray.addAll(stringToByteArray(_groundSpeed));
            baCommandArray.add(0xAA);
            self.abaCommandQueue.add(baCommandArray);
            self.sOldGroundSpeed = self.sGroundSpeed;
        }
    }

    public function setHeading(_heading as String) {
        if(!self.sOldHeading.equals(self.sHeading)){
            var baCommandArray = [0xFF,0x6A,0x00,0x0E,0x2E,0x00,0x1E,0x21]b;
            if($.oMySettings.iUnitDirection == 1){
                baCommandArray.addAll(headingToByteArray(_heading)); //remove one space for alignment
            } else {
                baCommandArray.addAll(stringToByteArray(_heading));
            }
            baCommandArray.add(0xAA);
            self.abaCommandQueue.add(baCommandArray);
            self.sOldHeading = self.sHeading;
        }
    }

    public function setAltitude(_altitude as String) {
        if(!self.sOldAltitude.equals(self.sAltitude)) {
            var baCommandArray = [0xFF,0x69,0x00,0x0B,0x7C]b;
            baCommandArray.addAll(stringToByteArray(_altitude)); 
            baCommandArray.add(0xAA);
            self.abaCommandQueue.add(baCommandArray);
            self.sOldAltitude = self.sAltitude;
        }
    }

    public function setVerticalSpeed(_verticalSpeed as String) {
        if(!self.sOldVerticalSpeed.equals(self.sVerticalSpeed)) {
            var baCommandArray = [0xFF,0x6A,0x00,0x0E,0x2F,0x00,0x9D,0x53]b;
            baCommandArray.addAll(stringToByteArray(_verticalSpeed));
            baCommandArray.add(0xAA);
            self.abaCommandQueue.add(baCommandArray);
            self.sOldVerticalSpeed = self.sVerticalSpeed;
        }
    }

    public function setTime(_time as String) {
        if(!self.sOldTime.equals(self.sTime)) {
            var baCommandArray = [0xFF,0x62,0x00,0x0B,0x0A]b;
            baCommandArray.addAll(stringToByteArray(_time));
            baCommandArray.add(0xAA);
            self.abaCommandQueue.add(baCommandArray);
            self.sOldTime = self.sTime;
        }
    }

    public function setFlightTime(_time as String) {
        if(!self.sOldFlightTime.equals(self.sFlightTime)) {
            var baCommandArray = [0xFF,0x6A,0x00,0x0E,0x0A,0x00,0xCD,0xCD]b;
            baCommandArray.addAll(stringToByteArray(_time));
            baCommandArray.add(0xAA);
            self.abaCommandQueue.add(baCommandArray);
            self.sOldFlightTime = self.sFlightTime;
        }
    }

    public function hold() {
        var baCommandArray = [0xFF,0x39,0x00,0x06,0x00,0xAA]b;
        self.abaCommandQueue.add(baCommandArray);
    }

    public function flush() {
        var baCommandArray = [0xFF,0x39,0x00,0x06,0x01,0xAA]b;
        self.abaCommandQueue.add(baCommandArray);
    }

    public function resetFlush() {
        var baCommandArray = [0xFF,0x39,0x00,0x06,0xFF,0xAA]b;
        self.abaCommandQueue.add(baCommandArray);
    }

    public function clearScreen() {
        var baCommandArray = [0xFF,0x01,0x00,0x05,0xAA]b;
        self.abaCommandQueue.add(baCommandArray);
    }

    public function powerScreen() {
        var baCommandArray = [0xFF,0x00,0x00,0x06,0x01,0xAA]b;
        self.abaCommandQueue.add(baCommandArray);
    }

    public function resetConnection() {
        if(!bReconnecting) {
            bReconnecting = true;
            Sys.println(Time.now().value()+": Resetting connection! Last command:"+baLastCommand.toString());
            if(isScanning()) {
                Ble.setScanState(Ble.SCAN_STATE_OFF);
            }
            bExpectedDisconnect = true;   
            unPair();
            iTimer = 100000;
            bBleConnected = false;
            bBleIsWriting = false;
            bBleBufferWarning = false;
            iCommandCounter = 0;
            clearQueue();
            $.oMyProcessing.timeElapsed = 0;    //Reset scanning timeout to attempt to reconnect to device
            findAndPair();
        }
    }

    function stringToByteArray(_text as String) as ByteArray {
        var caNumberAsChars = _text.toCharArray();
        var baNumberAsByteArray = []b;
        
        if(caNumberAsChars.size() == 0) {
            return baNumberAsByteArray;
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
            return baNumberAsByteArray;
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

    public function firmwareCheck(_version as String) {
        var major = 0;
        var minor = 0;
        //var patch = 0;
        var offset = _version.find("v");
        if (offset == null) { offset = -1; }
        var subStr = _version.substring(offset + 1, _version.length());
        major = subStr.toNumber();
        offset = subStr.find(".");
        if (offset != null) {
            subStr = subStr.substring(offset + 1, subStr.length());
            minor = subStr.toNumber();
            offset = subStr.find(".");
            if (offset != null) {
                subStr = subStr.substring(offset + 1, subStr.length());
                //patch = subStr.toNumber();
            }
        }
        major -= self.iCurrentFirmwareMajor;
        minor -= self.iCurrentFirmwareMinor;
        if(major < 0 || (major == 0 && minor < 0)) {
            Ui.switchToView(new MyViewFwUpdate(),
                    new MyViewFwUpdateDelegate(),
                    Ui.SLIDE_IMMEDIATE);
        }
    }
}

 
class BleOperations extends Ble.BleDelegate
{
    public var _scanState as Number;
    public var _profileRegistered = false;
    public var oBleDevice;
    public var oBleService;
    public var oBleCharacteristic;
    public var oControlNotificationCharacteristic;
    public var oDeviceInformationService;
    public var oFirmwareVersionCharacteristic;

    //! Custom Service (ActiveLook® Commands Interface)
    private static const BLE_SERV_ACTIVELOOK               as Ble.Uuid = Ble.longToUuid(0x0783B03E8535B5A0l, 0x7140A304D2495CB7l);
    //! Custom Service (ActiveLook® Commands Interface) Characteristics
    private static const BLE_CHAR_ACTIVELOOK_TX            as Ble.Uuid = Ble.longToUuid(0x0783B03E8535B5A0l, 0x7140A304D2495CB8l);
    private static const BLE_CHAR_ACTIVELOOK_RX            as Ble.Uuid = Ble.longToUuid(0x0783B03E8535B5A0l, 0x7140A304D2495CBAl);
    private static const BLE_CHAR_ACTIVELOOK_FLOW_CONTROL  as Ble.Uuid = Ble.longToUuid(0x0783B03E8535B5A0l, 0x7140A304D2495CB9l);

    //! Device Information Service
    private static const BLE_SERV_DEVICE_INFORMATION       as Ble.Uuid = Ble.longToUuid(0x0000180A00001000l, 0x800000805F9B34FBl);
    //! Device Information Service Characteristics
    private static const BLE_CHAR_FIRMWARE_VERSION         as Ble.Uuid = Ble.longToUuid(0x00002A2600001000l, 0x800000805F9B34FBl);

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
            oBleDevice = device;
            // Device information service to get firmware
            oDeviceInformationService = oBleDevice.getService(BLE_SERV_DEVICE_INFORMATION);
            if(oDeviceInformationService != null) {
                oFirmwareVersionCharacteristic = oDeviceInformationService.getCharacteristic(BLE_CHAR_FIRMWARE_VERSION);
                if(oFirmwareVersionCharacteristic != null) {
                    oFirmwareVersionCharacteristic.requestRead();
                }
            }

            // Custom ActiveLook service
            oBleService = oBleDevice.getService(BLE_SERV_ACTIVELOOK );
            if(oBleService != null) {
                oBleCharacteristic = oBleService.getCharacteristic(BLE_CHAR_ACTIVELOOK_RX ); //Rx Server characteristic
                if (oBleCharacteristic != null) {
                    $.oMyActiveLook.bBleConnected = true;
                    $.oMyActiveLook.clearQueue();
                    $.oMyActiveLook.clearScreen(); //Queueing the initial startup commands
                    if($.oMyActiveLook.bReconnecting) {
                        $.oMyActiveLook.resetFlush();
                    }
                    $.oMyActiveLook.setDefaults();
                    $.oMyActiveLook.storeUpdate();
                }
                oControlNotificationCharacteristic = oBleService.getCharacteristic(BLE_CHAR_ACTIVELOOK_FLOW_CONTROL); //Control characteristic
                if (oControlNotificationCharacteristic != null) {
                    var oCccd = oControlNotificationCharacteristic.getDescriptor(BluetoothLowEnergy.cccdUuid()); // Control descriptor
                    if (oCccd != null) {
                        $.oMyActiveLook.bBleIsWriting = true;
                        oCccd.requestWrite([0x01,0x00]b); //Turn notifications on to get flow control messages
                    }
                }
            }
        } else if (state == Ble.CONNECTION_STATE_DISCONNECTED) {
            if($.oMyActiveLook.bExpectedDisconnect) {
                $.oMyActiveLook.bExpectedDisconnect = false;
            } else {
                $.oMyActiveLook.resetConnection();
            }
        }
    }

    function onCharacteristicWrite(characteristic, status) {
        $.oMyActiveLook.iTimer = 100000;
        $.oMyActiveLook.bBleIsWriting = false;
        $.oMyActiveLook.processQueue(Ble.WRITE_TYPE_DEFAULT); //Will keep processing command queue until nothing left in
    }

    function onDescriptorWrite(descriptor, status) {
        $.oMyActiveLook.bBleIsWriting = false;
        $.oMyActiveLook.bReconnecting = false;
        $.oMyActiveLook.processQueue(Ble.WRITE_TYPE_DEFAULT); //This will do the initial queue processing (Clear screen, initial values)
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
                try {
                    Ble.pairDevice(scanResult);
                } catch (ex){
                }
            }
            scanResult = scanResults.next();
        }
    }
 
    function registerProfiles() {
        var profileActiveLook = ({
            :uuid => BLE_SERV_ACTIVELOOK,
            :characteristics => [
                { :uuid => BLE_CHAR_ACTIVELOOK_RX },
                { :uuid => BLE_CHAR_ACTIVELOOK_TX, :descriptors => [Toybox.BluetoothLowEnergy.cccdUuid()] },
                { :uuid => BLE_CHAR_ACTIVELOOK_FLOW_CONTROL, :descriptors => [Toybox.BluetoothLowEnergy.cccdUuid()] },
            ]
        });
        Ble.registerProfile(profileActiveLook);
        var profileDeviceInfo = ({
            :uuid => BLE_SERV_DEVICE_INFORMATION,
            :characteristics => [
                { :uuid => BLE_CHAR_FIRMWARE_VERSION }
            ]
        });
        Ble.registerProfile(profileDeviceInfo);
    }
 
    function onCharacteristicChanged(characteristic, value) {
        if(characteristic.getUuid().equals(BLE_CHAR_ACTIVELOOK_FLOW_CONTROL) && value != null && value.size() > 0) { // Flow control characteristic
            if(value[0] == 0x01) {
                $.oMyActiveLook.bBleBufferWarning = false;
            } 
            if(value[0] == 0x02 || value[0] == 0x04) {  //Flow control! Stop sending commands
                $.oMyActiveLook.clearQueue();
                $.oMyActiveLook.bBleBufferWarning = true;
            } 
        }
    }

    function onCharacteristicRead(characteristic, status, value) {
        if(value != null && characteristic.getUuid().equals(BLE_CHAR_FIRMWARE_VERSION)) {
            $.oMyActiveLook.firmwareCheck(byteArrayToString(value));            
        }
    }

    function byteArrayToString(byte_array) {
        var options = {
            :fromRepresentation => StringUtil.REPRESENTATION_BYTE_ARRAY,
            :toRepresentation => StringUtil.REPRESENTATION_STRING_PLAIN_TEXT,
            :encoding => StringUtil.CHAR_ENCODING_UTF8
        };
        var result = StringUtil.convertEncodedString(byte_array, options);
        return result; 
    }

    function onScanStateChange(scanState, status) {
        _scanState = scanState;
    }
 
    public function isScanning() {
        return _scanState != Ble.SCAN_STATE_OFF;
    }
}