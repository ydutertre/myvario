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

class MyVectorVario
{
    //BLE and VectorVario related variables
    var oBleOperations as BleOperationsVV;
    public var abaCommandQueue = []; //Queue for write commands, as only one can be sent at a time
    public var bBleIsWriting as Boolean;
    public var bBleConnected as Boolean;
    public var bReconnecting as Boolean;
    public var bExpectedDisconnect = false;
    public var fWindSpeed = 0.0f;
    public var iWindDirection = 0;
    public var fVario = 0.0f;

    function init() {
        oBleOperations = new BleOperationsVV();
        Ble.setDelegate(oBleOperations);
        bBleIsWriting = false;
        bBleConnected = false;
        bReconnecting = false;
        bExpectedDisconnect = false;
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
    
    public function resetConnection() {
        if(!bReconnecting) {
            bReconnecting = true;
            //Sys.println(Time.now().value()+": Resetting connection! Last command:"+baLastCommand.toString());
            if(isScanning()) {
                Ble.setScanState(Ble.SCAN_STATE_OFF);
            }
            bExpectedDisconnect = true;   
            unPair();
            bBleConnected = false;
            bBleIsWriting = false;
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
}

 
class BleOperationsVV extends Ble.BleDelegate
{
    public var _scanState as Number;
    public var _profileRegistered = false;
    public var oBleDevice;
    public var oVectorVarioVarioService;
    public var oBleCharacteristic;
    public var oControlNotificationCharacteristic;
    public var oDeviceInformationService;
    public var oWindSpeedCharacteristic;
    public var oWindDirectionCharacteristic;
    public var oVarioCharacteristic;
    private var bVarioReady = false;
    private var bWindSpeedReady = false;
    private var bWindDirectionReady = false;

    //! Custom Service
    private static const BLE_VECTORVARIO_SERVICE_SENSING as Ble.Uuid = Ble.longToUuid(0x0000181A00001000l, 0x800000805F9B34FBl);
    private static const BLE_VECTORVARIO_SERVICE_VARIO as Ble.Uuid = Ble.longToUuid(0x2FCE4890019747E0l, 0xA825D4777B9A5D67l);
    //! Custom Service Characteristics
    private static const BLE_VECTORVARIO_WINDSPEED as Ble.Uuid = Ble.longToUuid(0x00002A7000001000l, 0x800000805F9B34FBl);
    private static const BLE_VECTORVARIO_WINDDIRECTION as Ble.Uuid = Ble.longToUuid(0x00002A7100001000l, 0x800000805F9B34FBl);
    private static const BLE_VECTORVARIO_VARIO as Ble.Uuid = Ble.longToUuid(0x2FCE4891019747E0l, 0xA825D4777B9A5D67l);

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
            $.oMyVectorVario.bBleConnected = true;
            // Device information service to get Wind information
            oDeviceInformationService = oBleDevice.getService(BLE_VECTORVARIO_SERVICE_SENSING);
            if(oDeviceInformationService != null) {
                oWindSpeedCharacteristic = oDeviceInformationService.getCharacteristic(BLE_VECTORVARIO_WINDSPEED);
                oWindDirectionCharacteristic = oDeviceInformationService.getCharacteristic(BLE_VECTORVARIO_WINDDIRECTION);
            }

            // Device information service to get Vario information
            oVectorVarioVarioService = oBleDevice.getService(BLE_VECTORVARIO_SERVICE_VARIO);
            if(oVectorVarioVarioService != null) {
                oVarioCharacteristic = oVectorVarioVarioService.getCharacteristic(BLE_VECTORVARIO_VARIO);
                if (oVarioCharacteristic != null) {
                    var oCccd = oVarioCharacteristic.getDescriptor(BluetoothLowEnergy.cccdUuid()); // Control descriptor
                    if (oCccd != null) {
                        try{ oCccd.requestWrite([0x01,0x00]b); } catch(e) {} //Turn notifications on to vario, this will trigger turning notifications on for other services via "onCharacteristicChanged()" event
                    }
                }
            }
        } else if (state == Ble.CONNECTION_STATE_DISCONNECTED) {
            if($.oMyVectorVario.bExpectedDisconnect) {
                $.oMyVectorVario.bExpectedDisconnect = false;
            } else {
                $.oMyVectorVario.resetConnection();
            }
        }
    }

    public function readChar() {
        if(oVarioCharacteristic != null) {
            oVarioCharacteristic.requestRead();
        }
    }
 
    function onScanResults(scanResults) { 
        // add/update result
        var scanResult = scanResults.next();
        // var raw = scanResult.getRawData();
        // var options = {
        //     :offset => 0,
        //     :endianness => 0
        // };
        // var rawNumber=raw.decodeNumber(5,options);

        while (scanResult != null) {
            var serviceUuids=scanResult.getServiceUuids();
            var serviceUuid=serviceUuids.next();
            var bVectorVarioFound = false;
            var i = 0;
            while (serviceUuid != null && !bVectorVarioFound && i < 8) {
                if(serviceUuid.equals(BLE_VECTORVARIO_SERVICE_SENSING)) {
                    bVectorVarioFound = true;
                }
                serviceUuids.next();
                i++;
            }
            if(bVectorVarioFound) { //rawNumber == 84279554
                if(!_profileRegistered) {
                    registerProfiles();
                    _profileRegistered = true;
                }
                Ble.setScanState(Ble.SCAN_STATE_OFF);
                try {
                    Ble.pairDevice(scanResult);
                } catch (ex){
                    bVectorVarioFound = false;
                }
            }
            scanResult = scanResults.next();
        }
    }
 
    function registerProfiles() {
        var profileVectorVarioWind = ({
            :uuid => BLE_VECTORVARIO_SERVICE_SENSING,
            :characteristics => [
                { :uuid => BLE_VECTORVARIO_WINDSPEED},
                { :uuid => BLE_VECTORVARIO_WINDDIRECTION},
            ]
        });
        Ble.registerProfile(profileVectorVarioWind);
        var profileVectorVarioVario = ({
            :uuid => BLE_VECTORVARIO_SERVICE_VARIO,
            :characteristics => [
                { :uuid => BLE_VECTORVARIO_VARIO, :descriptors => [Toybox.BluetoothLowEnergy.cccdUuid()]}
            ]
        });
        Ble.registerProfile(profileVectorVarioVario);
    }
 
    // Only writes for Vector Vario are to turn characteristics on
    function onCharacteristicWrite(characteristic, status) {
        // Keep track of notifications requested
        if (status == 0) {
            if (characteristic.getUuid().equals(BLE_VECTORVARIO_WINDSPEED)) {
                bWindSpeedReady = true;
            } else if (characteristic.getUuid().equals(BLE_VECTORVARIO_WINDDIRECTION)) {
                bWindDirectionReady = true;
            } else {
                bVarioReady = true;
            }
        }
        // Keep writing until everything is done
        var oCccd;
        if(!bVarioReady) {
            oCccd = oVarioCharacteristic.getDescriptor(BluetoothLowEnergy.cccdUuid()); // Control descriptor
            if (oCccd != null) {
                try { oCccd.requestWrite([0x01,0x00]b); } catch(e){}
            }
        } else if (!bWindSpeedReady) {
            oCccd = oWindSpeedCharacteristic.getDescriptor(BluetoothLowEnergy.cccdUuid()); // Control descriptor
            if (oCccd != null) {
                try { oCccd.requestWrite([0x01,0x00]b); } catch(e){}
            }
        } else if (!bWindDirectionReady) {
            oCccd = oWindDirectionCharacteristic.getDescriptor(BluetoothLowEnergy.cccdUuid()); // Control descriptor
            if (oCccd != null) {
                try { oCccd.requestWrite([0x01,0x00]b); } catch(e){}
            }
        }
    }

    function onCharacteristicChanged(characteristic, value) {
        if (characteristic.getUuid().equals(BLE_VECTORVARIO_WINDSPEED)) {
            $.oMyVectorVario.fWindSpeed = value.decodeNumber(Toybox.Lang.NUMBER_FORMAT_UINT16,{:offset => 0, :endianness => 0}) / 100.0f; //Wind speed in m/s
        } else if (characteristic.getUuid().equals(BLE_VECTORVARIO_WINDDIRECTION)) {
            $.oMyVectorVario.iWindDirection = (value.decodeNumber(Toybox.Lang.NUMBER_FORMAT_UINT16,{:offset => 0, :endianness => 0})/100).toNumber(); //Wind Origin direction in degrees
        } else {
            $.oMyVectorVario.fVario = value.decodeNumber(Toybox.Lang.NUMBER_FORMAT_SINT32,{:offset => 0, :endianness => 0})/10.0f; //Variometer in m/s
        }
    }

    function onScanStateChange(scanState, status) {
        _scanState = scanState;
    }
 
    public function isScanning() {
        return _scanState != Ble.SCAN_STATE_OFF;
    }
}