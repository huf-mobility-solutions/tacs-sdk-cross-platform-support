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

// Wait for the deviceready event before using any of Cordova's device APIs.
// See https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready
document.addEventListener('deviceready', onDeviceReady, false);
document.getElementById("lock").addEventListener("click", lockButtonClick);
document.getElementById("unlock").addEventListener("click", unlockButtonClick);
document.getElementById("connect").addEventListener("click", connectButtonClick);
document.getElementById("disconnect").addEventListener("click", disconnectButtonClick);
document.getElementById("engineOff").addEventListener("click", engineOffButtonClick);
document.getElementById("engineOn").addEventListener("click", engineOnButtonClick);
document.getElementById("location").addEventListener("click", locationButtonClick);
document.getElementById("telematics").addEventListener("click", telematicsButtonClick);

/**
 * This is called when the Cordova is initialized. 
 * Once the cordova is initialized, we initialize the plugin that internally
 * initializes the TACS manager and builds the keyring and makes everything ready to connect
 */
function onDeviceReady() {
    // Cordova is now initialized. Have fun!

    // Get the keyring json
    const keyringData = getKeyringJson()

    // Build the keyring once the device is ready
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("connectionStatus").textContent = success.arguments[0]
    }
    var error = function () {
        document.getElementById("connectionStatus").textContent = "Error"
    }
    hufPlugin.initPlugin(success, error, JSON.stringify(keyringData))

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');
}

/**
 * On lock button click, we request the plugin to execute the lock command
 * and on receiving the plugin result as 'success' we update the UI with the lock status
 */
function lockButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("doorStatus").textContent = success.arguments[0]
    }
    var error = function () {
        document.getElementById("doorStatus").textContent = "Error"
    }
    hufPlugin.executeLockCommand(success, error)
}

/**
 * On unlock button click, we request the plugin to execute the unlock command
 * and on receiving the plugin result as 'success' we update the UI with the unlock status
 */
function unlockButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("doorStatus").textContent = success.arguments[0]
    }
    var error = function () {
        document.getElementById("doorStatus").textContent = "Error"
    }
    hufPlugin.executeUnlockCommand(success, error)
}

/**
 * On connect button click, we request the plugin to execute the connect command
 * and on receiving the plugin result as 'success' we update the UI with the connecting 
 * or connected status.
 */
function connectButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("connectionStatus").textContent = success.arguments[0]
    }
    var error = function () {
        document.getElementById("connectionStatus").textContent = "Error"
    }
    hufPlugin.connectToCAM(success, error)
}

/**
 * On disconnect button click, we request the plugin to execute the disconnect command
 * and on receiving the plugin result as 'success' we update the UI with the disconnected 
 * status.
 */
function disconnectButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("connectionStatus").textContent = success.arguments[0]
    }
    var error = function () {
        document.getElementById("connectionStatus").textContent = "Error"
    }
    hufPlugin.disconnectFromCAM(success, error)
}

/**
 * On engine off button click, we request the plugin to execute the engine off command
 * and on receiving the plugin result as 'success' we update the UI with the engine off status
 */
function engineOffButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("engineStatus").textContent = success.arguments[0]
    }
    var error = function () {
        document.getElementById("engineStatus").textContent = "Error"
    }
    hufPlugin.executeEngineOffCommand(success, error)
}

/**
 * On engine on button click, we request the plugin to execute the engine on command
 * and on receiving the plugin result as 'success' we update the UI with the engine on status
 */
function engineOnButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("engineStatus").textContent = success.arguments[0]
    }
    var error = function () {
        document.getElementById("engineStatus").textContent = "Error"
    }
    hufPlugin.executeEngineOnCommand(success, error)
}

/**
 * On location button click, we request the plugin to execute the location command
 * and on receiving the plugin result as 'success' we update the UI with the location data
 */
function locationButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("locationStatus").textContent = success.arguments[0]
    }
    var error = function () {
        document.getElementById("locationStatus").textContent = "Error"
    }
    hufPlugin.executeLocationCommand(success, error)
}

/**
 * On telematics button click, we request the plugin to execute the telematics command
 * and on receiving the plugin result as 'success' we update the UI with the telematics data
 */
function telematicsButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("telematicsStatus").textContent = success.arguments[0]
    }
    var error = function () {
        document.getElementById("telematicsStatus").textContent = "Error"
    }
    hufPlugin.executeTelematicsCommand(success, error)
}

/**
 * Local function to get the keyring
 */
function getKeyringJson() {
    return {
        "tacsLeaseTokenTableVersion": "1597993145518",
        "tacsLeaseTokenTable": [
            {
                "vehicleAccessGrantId": "MySampleAccessGrantId",
                "leaseToken": {
                    "leaseId": "c80b677f-c1b0-4c1c-823e-adccfa1d1b2a",
                    "userId": "1",
                    "sorcId": "b36e70cd-dce6-49b9-b4cf-8e56a24a4668",
                    "serviceGrantList": [
                        {
                            "serviceGrantId": "1",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "2",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "3",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "4",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "5",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "6",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "7",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "8",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "9",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "10",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "11",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "12",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "13",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "14",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "15",
                            "validators": {
                                "startTime": "2019-04-25T01:00:00.000Z",
                                "endTime": "2025-01-01T01:00:00.000Z"
                            }
                        }
                    ],
                    "leaseTokenDocumentVersion": "1",
                    "leaseTokenId": "544a6c7d-0351-46ab-97b2-84b19e45d857",
                    "sorcAccessKey": "ee91c3314b95ee10a1df3d0c419d0953",
                    "startTime": "2019-04-25T01:00:00.000Z",
                    "endTime": "2025-01-01T01:00:00.000Z"
                }
            }
        ],
        "tacsSorcBlobTableVersion": "1597993145518",
        "tacsSorcBlobTable": [
            {
                "tenantId": "default",
                "externalVehicleRef": "onboardingVehicle_b2bgreenmotion_76998",
                "blob": {
                    "sorcId": "b36e70cd-dce6-49b9-b4cf-8e56a24a4668",
                    "blob": "AbNucM3c5km5tM+OVqJKRmgBABgAAACaJwrnFK76/8+Fij6UbLgL66imeseJi8azYJ0CoP1tKCmcMBpIgpR3STPm9RtYBy3W3ed1OSqsuOxBZ9GKhn8+rwRg4fPsK6jjAVVZ43Y80CaOksOCp+W24HjsN6sYmluYXTWCNROXykNxzUSpygE9b+G/4Q6oZry67ATH8s6Skf1qyPpkRUWyoCSKz278rfeUV3npKIbnFBo9cjJbUjNQYuMQ6bo8BLsrycRMBK45eNi3wZSRGU+exNW4nlImak2pJPwzWDE+9HKKvI9fCrZf6HNiwZmQmCkBRXufNhmJGc5Nqz+5axFk/OrupPcJ+YAf9njr99EQUZTXqws0TdaRveXwTTkAKkZv28yQveKznR015YERYnNs+lXs+1E4y0P4lMaqdFp7lyOHfyzQLq1Ne/kkQdoJsnXw9nrmJgz5fqnRKU7Z/Qv4v6eMlVl3+D5rPLvwbAYpI7xGQmjvP8Ewm8L0rrJGpBzGSdK1Nt5ACm0wxKWL054ESEtuuIwKS9RpWDiazmyS1U+0QTSB5ArwObi/swYZL7XBhpYec16j/MFW+Ube5TWPiFm6+91wBmC4pFS8oirDbub+zhIrIIJLZDPLWZXOA7acK9+BM7cvOmBnGLP2JDAQoNbrLZNegjmYxJsUMDiei1YDOLMBdlPETkH3rWKIESwxlTlVO8y74MpCwqq5sXzTAn0dyBphLtzpDWqNN9tXyFqm5J2hxLkaU30WX9u4ThaH4S586Z93JTIuAG8NZx8k1iZobniX6gqCTpZ8fn7iJhcoLyeT7RLixdPYLkmnAt9uCEZ7dAd1cN4n0GLqwBo7O62EvFNf6Lvct+JYfzvEdLDGyC+7N16zRVWhhj+QwllDQmfcrUJCvh9jYICQZxaQhbwt3U47ROJT3EqvoX94wD5poYqunsXXBu7+trCKldsBS8AY8iUAUhIVshTyLBflSqqhauePMir8Teg/K4uOYBjpauaNEjVyXsATgmqnldZHjFvIYeNBMpxnAoMEowSBPIevoquoS227F4qTu2/YoU+R/PtkebIiiccBGzsX+liozyKEFhVT0w8I44w6qnn3g7QJ7vVXD/oymx6cS4HL9bT8L1dtFEQpld6VAobwAGKOM13MFI631g31OpiVx/U3iUC/qxUJ7r4/cmdZKlvuInLe9aY0Fw/RNwTJqYVwLQURIpO3kKPEBcqRD/2yjViD6FgAdQCo8XE6X7ERr4+CD+j/5YufdNR/YI3EbzaIPypbU4b0mmg0CPykVNm6LAwkLi7wB9q7MuT16TrG3jiWP+7q4bVKU2buwQ94NHhbG+wGWz7H57i75+qiDcEbUScSqiKfo8oRi06hol8/t3M/z6drx7yKn6mewzW7fMw5KQrvuEpE9SwW+w==",
                    "blobMessageCounter": "24"
                }
            }
        ]
    }
}
