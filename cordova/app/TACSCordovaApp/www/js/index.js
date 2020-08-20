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
document.getElementById("immobilizerOn").addEventListener("click", immobilizerOnButtonClick);
document.getElementById("immobilizerOff").addEventListener("click", immobilizerOffButtonClick);

function onDeviceReady() {
    // Cordova is now initialized. Have fun!
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");

    //Get the json
    const data = getKeyringJson()
    hufPlugin.buildKeyring(JSON.stringify(data))

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');
}

function lockButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var successLock = function () {
        console.log("Success lock")
        document.getElementById("doorStatus").textContent = success.arguments[0]
    }
    var failLock = function () {
        document.getElementById("doorStatus").textContent = "Failure"
    }
    hufPlugin.executeLockCommand(successLock, failLock)
}

function unlockButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var successUnlock = function () {
        console.log("Success unlock")
        document.getElementById("doorStatus").textContent = success.arguments[0]
    }
    var failUnlock = function () {
        document.getElementById("doorStatus").textContent = "Failure"
    }
    hufPlugin.executeUnlockCommand(successUnlock, failUnlock)
}

function connectButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("connectionStatus").textContent = success.arguments[0]
    }
    var fail = function () {
        document.getElementById("connectionStatus").textContent = "Failure"
    }
    hufPlugin.connectToCAM(success, fail)
}

function disconnectButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("connectionStatus").textContent = success.arguments[0]
    }
    var fail = function () {
        document.getElementById("connectionStatus").textContent = "Failure"
    }
    hufPlugin.disconnectFromCAM(success, fail)
}

function immobilizerOnButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("engineStatus").textContent = success.arguments[0]
    }
    var fail = function () {
        document.getElementById("engineStatus").textContent = "Failure"
    }
    hufPlugin.executeImmobilizerOnCommand(success, fail)
}

function immobilizerOffButtonClick() {
    const hufPlugin = cordova.require("com.playmoove.huf.Huf");
    var success = function () {
        document.getElementById("engineStatus").textContent = success.arguments[0]
    }
    var fail = function () {
        document.getElementById("engineStatus").textContent = "Failure"
    }
    hufPlugin.executeImmobilizerOffCommand(success, fail)
}

function getKeyringJson() {
    return {
        "tacsLeaseTokenTableVersion": "1576748075346",
        "tacsLeaseTokenTable": [
            {
                "vehicleAccessGrantId": "MySampleAccessGrantId",
                "leaseToken": {
                    "leaseId": "95df9275-d069-4d41-bd5b-c76543963a30",
                    "userId": "1",
                    "sorcId": "84766600-deec-4099-8145-2e0e645997ea",
                    "serviceGrantList": [
                        {
                            "serviceGrantId": "1",
                            "validators": {
                                "startTime": "2019-10-22T01:00:00.000Z",
                                "endTime": "2025-10-22T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "2",
                            "validators": {
                                "startTime": "2019-10-22T01:00:00.000Z",
                                "endTime": "2025-10-22T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "3",
                            "validators": {
                                "startTime": "2019-10-22T01:00:00.000Z",
                                "endTime": "2025-10-22T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "4",
                            "validators": {
                                "startTime": "2019-10-22T01:00:00.000Z",
                                "endTime": "2025-10-22T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "5",
                            "validators": {
                                "startTime": "2019-10-22T01:00:00.000Z",
                                "endTime": "2025-10-22T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "6",
                            "validators": {
                                "startTime": "2019-10-22T01:00:00.000Z",
                                "endTime": "2025-10-22T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "7",
                            "validators": {
                                "startTime": "2019-10-22T01:00:00.000Z",
                                "endTime": "2025-10-22T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "8",
                            "validators": {
                                "startTime": "2019-10-22T01:00:00.000Z",
                                "endTime": "2025-10-22T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "9",
                            "validators": {
                                "startTime": "2019-10-22T01:00:00.000Z",
                                "endTime": "2025-10-22T01:00:00.000Z"
                            }
                        },
                        {
                            "serviceGrantId": "10",
                            "validators": {
                                "startTime": "2019-10-22T01:00:00.000Z",
                                "endTime": "2025-10-22T01:00:00.000Z"
                            }
                        }
                    ],
                    "leaseTokenDocumentVersion": "1",
                    "leaseTokenId": "89d01b02-30f6-458c-bc90-627e8e79e116",
                    "sorcAccessKey": "f6ecc866321aae055d4799494d2ffd85",
                    "startTime": "2019-10-22T01:00:00.000Z",
                    "endTime": "2025-10-22T01:00:00.000Z"
                }
            }
        ],
        "tacsSorcBlobTableVersion": "1576748075346",
        "tacsSorcBlobTable": [
            {
                "tenantId": "default",
                "externalVehicleRef": "onboardingVehicle_b2bsixt_39536",
                "blob": {
                    "sorcId": "84766600-deec-4099-8145-2e0e645997ea",
                    "blob": "AYR2ZgDe7ECZgUUuDmRZl+oBAAQDAAAoOz7p5XkYRBqsWrgDv6nWHBh1kUqqCFxClvdWIxnEwpkJAkL5E8g0yHHzU6bpJNkyzSocKGIA95Ib0fxJBwGquA5qGLJa2lDP9lTsAb1fOUBPOwblTDbXYPB00eYSMnkEFUy6+n7lhuArrDcvrfoAdXMSrLbbvhlq19ki3WT7x0BOFibZ9fxtJMxosYedsFEqfU4vYNnglW9a0fKAxAa0QTevmkQxlJQKQxz2VH/0O1v2DiCMNUXHxGnB6OXwf5oOqP0GILUWRZC6fkVHpSnlYFiQqnXwxVmQeWduKyt1u/EDAxzeIZW67YK3gO2upE7pWCKnu3s50prnpDBrcUX7ImXS2P58/YBqdnFrUyGMzRdLZwOyrtKCtRTEBES34TNQwAr7e1fkGAUaupt5VOxhOc4askCF6TvqGCxgKBANlO6rJSYbIa29BrHiALUj/XuYqxpUDmYUiAiNBS29QJpqYaE9ob3j+OsfF+6lOXXYHGoQh2Qq9FMURhQ1WJJwZ/dtJ3cIWRJ4fWwj70/Hvb0YlCe09vdv+ZMZK6rusD3qhyLJhjcfDtxByEJbnbr1WfSk6JJet5RE7TZHa5lfD2uoQ/3dZ72PZqaLjVN7zafrvohPE6GLJc7fmsbpaiy12AW4sSSGZD8HaPUvjTAuVVzchk58ji8uqMU8FWx3I6WEfbdgEUW18M2lLw8oCFhR9kgfAq3tpIiT93kdDThdpKPQ5nSL6oVdILTcMIb85cQgRYBWzfgArKGNc0fgepjlA8jH6lWDaDimXdCRbXCrdBCiiwQ33OQ1p4L3ob7+JSRJ/Ow/Ved9Lj9g4VSn25xyg9sGTkkoZVENqGkKsX7dMQPhdOlHtjdMRzJbFAECOufHPWkRKmvNTgaoWXL4z01PFcHkFbGDKm/4J+a3Xiev2dbyNqwm5QAdWLbc1JH05M/2WOpVXoW/k3QkJYFF0Dlc7cNX70lgNKt5LSQ5QiZg0eUTqOi1t8b2RN7Naj+GeNj0J2+WaadLc2W5bKHq/wVLaZMMHFEXfyWocpRriBgp5p1vWnef0ppDusthLxjHszCnITD/vBP6AW+1E9WwpAJqtWP0oCkmFPHU6XIUZhgnT3yWfSQ/QLC5Ju/wKrOXQhuHFEH5SyKAnp2RKBqNvZBF9NUdfJH0I80gLblBDRzDAAbdwN+T8wDNc18+rHSLGrtaC73Jytx20yw/4nBrz3mOtPqTOlRM1FJ5/3/PkMvOFXN6cFVjN7vky4cqMgD60U61obhO2Lnjvb/HR8UNpugGwYUcO9UISpezGMgewGkTE1H/R2vC/1q+6f7Hp1BK1d3QB8YbUqCU16/2H5pavzQQkDgaql7E5+eueqYN//MwrY3yWn7DZaM5pBnyTgeUzgANha5/F+Hco4SQ+VtTSfzhDXm9qoFtUr3DMke1QK+u9jXuafjUZrIaRUT1UF5WlkhrrK/7HkrSMXBAToNipj7hq81fdIifidP8UQomal+0NQCNzO10w+vJfZ6343EBSz18N0FU2tuWdNeXRdgXy9V90qvBZje7IwUKqS0RXljEE3JDEZ26tatxSjGlwZHWtRiBtvyyQrqsWwpTbNrDfwRqOJn7cvLBys+CUIJyuKq4ZMbYQrS2M/qeAl8Z+9BP646FVLm/JKq1LplVrdLa45ECMiwTsoBUw8WfO/YKepBVMEGA",
                    "blobMessageCounter": "772"
                }
            }
        ]
    }
}
