
/**
 * This is called when the Cordova is initialized. 
 * Once the cordova is initialized, we initialize the plugin that internally
 * initializes the TACS manager and builds the keyring and makes everything ready to connect
 */
const handleDeviceReady = () => {

    console.log("Running cordova-" + cordova.platformId + "@" + cordova.version)
    document.getElementById("deviceready").classList.add("ready")
   
    const connectionStatus = document.getElementById("connectionStatus")
    const doorStatus = document.getElementById("doorStatus")
    const ignitionStatus = document.getElementById("ignitionStatus")
    const telematicsStatus = document.getElementById("telematicsStatus")
    const locationStatus = document.getElementById("locationStatus")
    
    // Add actions
    document
        .getElementById("lock")
        .addEventListener("click", TACS.lock)
    
    document
        .getElementById("unlock")
        .addEventListener("click", TACS.unlock)
    
    document
        .getElementById("connect")
        .addEventListener("click", TACS.connect)
    
    document
        .getElementById("disconnect")
        .addEventListener("click", TACS.disconnect)
    
    document
        .getElementById("enableIgnition")
        .addEventListener("click", TACS.enableIgnition)
    
    document
        .getElementById("disableIgnition")
        .addEventListener("click", TACS.disableIgnition)
    
    document
        .getElementById("location")
        .addEventListener("click", TACS.requestLocation)
    
    document
        .getElementById("telematics")
        .addEventListener("click", TACS.requestTelematicsData)
    
    // Add event listeners
    document.addEventListener("tacs:connectionStateChanged", event => {
        connectionStatus.textContent = event.detail.state
    })
    
    document.addEventListener("tacs:doorStatusChanged", event => {
        doorStatus.textContent = event.detail.state
    })
    
    document.addEventListener("tacs:ignitionStatusChanged", event => {
        ignitionStatus.textContent = event.detail.state
    })
    
    document.addEventListener("tacs:telematicsDataChanged", event => {
        telematicsStatus.textContent = event.detail.type + " " + event.detail.value +  " " + event.detail.unit
    })
    
    document.addEventListener("tacs:locationChanged", event => {
        locationStatus.textContent = event.detail.latitude + ", " + event.detail.longitude +  " " + event.detail.accuracy
    })
    
    // Get the keyring json
    const keyring = getKeyring()

    // Build the keyring once the device is ready
    TACS.initialize("164c64fa-ffe2-44f0-9909-09bc90215e5b", keyring)
        .catch(() => alert("Initialization failed"))
}

document.addEventListener("deviceready", handleDeviceReady, false)

/**
 * Local function to get the keyring
 */
const getKeyring = () => {
    return {
        "tacsLeaseTokenTable": [
            {
                "leaseToken": {
                    "endTime": "2020-11-05T16:38:19.296Z",
                    "leaseId": "164c64fa-ffe2-44f0-9909-09bc90215e5b",
                    "leaseTokenDocumentVersion": "1",
                    "leaseTokenId": "5f01fb9b-5494-450b-a055-cdf14a2207e5",
                    "serviceGrantList": [
                        {
                            "serviceGrantId": "1",
                            "validators": {
                                "endTime": "2020-11-05T16:38:19.296018Z",
                                "startTime": "2020-10-06T06:38:19.296018Z"
                            }
                        },
                        {
                            "serviceGrantId": "2",
                            "validators": {
                                "endTime": "2020-11-05T16:38:19.296018Z",
                                "startTime": "2020-10-06T06:38:19.296018Z"
                            }
                        },
                        {
                            "serviceGrantId": "3",
                            "validators": {
                                "endTime": "2020-11-05T16:38:19.296018Z",
                                "startTime": "2020-10-06T06:38:19.296018Z"
                            }
                        },
                        {
                            "serviceGrantId": "4",
                            "validators": {
                                "endTime": "2020-11-05T16:38:19.296018Z",
                                "startTime": "2020-10-06T06:38:19.296018Z"
                            }
                        },
                        {
                            "serviceGrantId": "5",
                            "validators": {
                                "endTime": "2020-11-05T16:38:19.296018Z",
                                "startTime": "2020-10-06T06:38:19.296018Z"
                            }
                        },
                        {
                            "serviceGrantId": "6",
                            "validators": {
                                "endTime": "2020-11-05T16:38:19.296018Z",
                                "startTime": "2020-10-06T06:38:19.296018Z"
                            }
                        },
                        {
                            "serviceGrantId": "9",
                            "validators": {
                                "endTime": "2020-11-05T16:38:19.296018Z",
                                "startTime": "2020-10-06T06:38:19.296018Z"
                            }
                        },
                        {
                            "serviceGrantId": "10",
                            "validators": {
                                "endTime": "2020-11-05T16:38:19.296018Z",
                                "startTime": "2020-10-06T06:38:19.296018Z"
                            }
                        }
                    ],
                    "sorcAccessKey": "6b853a14d7b1b4b3d307523dd18f7616",
                    "sorcId": "9b1cee15-b483-4ae4-b31a-5e72e3eb7a91",
                    "startTime": "2020-10-06T06:38:19.296Z",
                    "userId": "Google:101826648922071619818"
                },
                "vehicleAccessGrantId": "164c64fa-ffe2-44f0-9909-09bc90215e5b"
            },
            {
                "leaseToken": {
                    "endTime": "2020-11-05T18:16:49.324Z",
                    "leaseId": "de80adcd-74ed-4c54-8c44-be1c0400e863",
                    "leaseTokenDocumentVersion": "1",
                    "leaseTokenId": "a9694b5a-02fd-4204-83c6-9d8b897e2585",
                    "serviceGrantList": [
                        {
                            "serviceGrantId": "1",
                            "validators": {
                                "endTime": "2020-11-05T18:16:49.324052Z",
                                "startTime": "2020-10-06T08:16:49.324052Z"
                            }
                        },
                        {
                            "serviceGrantId": "2",
                            "validators": {
                                "endTime": "2020-11-05T18:16:49.324052Z",
                                "startTime": "2020-10-06T08:16:49.324052Z"
                            }
                        },
                        {
                            "serviceGrantId": "3",
                            "validators": {
                                "endTime": "2020-11-05T18:16:49.324052Z",
                                "startTime": "2020-10-06T08:16:49.324052Z"
                            }
                        },
                        {
                            "serviceGrantId": "4",
                            "validators": {
                                "endTime": "2020-11-05T18:16:49.324052Z",
                                "startTime": "2020-10-06T08:16:49.324052Z"
                            }
                        },
                        {
                            "serviceGrantId": "5",
                            "validators": {
                                "endTime": "2020-11-05T18:16:49.324052Z",
                                "startTime": "2020-10-06T08:16:49.324052Z"
                            }
                        },
                        {
                            "serviceGrantId": "6",
                            "validators": {
                                "endTime": "2020-11-05T18:16:49.324052Z",
                                "startTime": "2020-10-06T08:16:49.324052Z"
                            }
                        },
                        {
                            "serviceGrantId": "9",
                            "validators": {
                                "endTime": "2020-11-05T18:16:49.324052Z",
                                "startTime": "2020-10-06T08:16:49.324052Z"
                            }
                        },
                        {
                            "serviceGrantId": "10",
                            "validators": {
                                "endTime": "2020-11-05T18:16:49.324052Z",
                                "startTime": "2020-10-06T08:16:49.324052Z"
                            }
                        }
                    ],
                    "sorcAccessKey": "56498b6be2c940e41cd52708bb610265",
                    "sorcId": "9b1cee15-b483-4ae4-b31a-5e72e3eb7a91",
                    "startTime": "2020-10-06T08:16:49.324Z",
                    "userId": "Google:101826648922071619818"
                },
                "vehicleAccessGrantId": "de80adcd-74ed-4c54-8c44-be1c0400e863"
            }
        ],
        "tacsLeaseTokenTableVersion": "1602060500795",
        "tacsSorcBlobTable": [
            {
                "blob": {
                    "blob": "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",
                    "blobMessageCounter": "587",
                    "sorcId": "9b1cee15-b483-4ae4-b31a-5e72e3eb7a91"
                },
                "externalVehicleRef": "okolowski@plcam",
                "tenantId": "default"
            },
            {
                "blob": {
                    "blob": "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",
                    "blobMessageCounter": "587",
                    "sorcId": "9b1cee15-b483-4ae4-b31a-5e72e3eb7a91"
                },
                "externalVehicleRef": "okolowski@plcam",
                "tenantId": "default"
            }
        ],
        "tacsSorcBlobTableVersion": "1602060500795"
    }
}
