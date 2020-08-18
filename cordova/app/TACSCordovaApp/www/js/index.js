/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

const { connectToCAM, disconnectFromCAM } = require("../../../../plugin/cordova-huf-bluetooth/www/Huf");

// Wait for the deviceready event before using any of Cordova's device APIs.
// See https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready
document.addEventListener('deviceready', onDeviceReady, false);
document.getElementById("lock").addEventListener("click", lockClick);
document.getElementById("unlock").addEventListener("click", unlockClick);
document.getElementById("connect").addEventListener("click", connectClick);
document.getElementById("disconnect").addEventListener("click", disconnectClick);

function onDeviceReady() {
    // Cordova is now initialized. Have fun!

    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    hufPlugin.buildKeyring()

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');
}

function lockClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    hufPlugin.executeLockCommand()
}

function unlockClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    hufPlugin.executeUnlockCommand()
}

function connectClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    hufPlugin.connectToCAM()
}

function disconnectClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    hufPlugin.disconnectFromCAM()
}
