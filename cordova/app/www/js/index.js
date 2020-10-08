
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
    const locationStatus = document.getElementById("locationStatus")
    const odometerStatus = document.getElementById("odometerStatus")
    const fuelLevelAbsoluteStatus = document.getElementById("fuelLevelAbsoluteStatus")
    const fuelLevelPercentageStatus = document.getElementById("fuelLevelPercentageStatus")
    const longitudeStatus = document.getElementById("longitudeStatus")
    const latitudeStatus = document.getElementById("latitudeStatus")
    const accuracyStatus = document.getElementById("accuracyStatus")
    
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
        switch (event.detail.type) {
            case "odometer":
                odometerStatus.textContent = event.detail.value + " " + event.detail.unit
                break
            case "fuelLevelAbsolute":
                fuelLevelAbsoluteStatus.textContent = event.detail.value + " " + event.detail.unit
                break
            case "fuelLevelPercentage":
                fuelLevelPercentageStatus.textContent = event.detail.value + " " + event.detail.unit
                break
        }
        telematicsStatus.textContent = event.detail.type + " " + event.detail.value +  " " + event.detail.unit
    })
    
    document.addEventListener("tacs:locationChanged", event => {
        longitudeStatus.textContent = event.detail.longitude
        latitudeStatus.textContent = event.detail.latitude
        accuracyStatus.textContent = event.detail.accuracy
    })
    
    // Get the keyring json
    const keyring = getKeyring()

    // Build the keyring once the device is ready
    TACS.initialize("164c64fa-ffe2-44f0-9909-09bc90215e5b", keyring)
        .catch(() => alert("Initialization failed"))
}

document.addEventListener("deviceready", handleDeviceReady, false)

/**
 * Local function to get the keyring. Paste your own keyring here.
 */
const getKeyring = () => {
    return {
        "tacsLeaseTokenTable": [],
        "tacsLeaseTokenTableVersion": "",
        "tacsSorcBlobTable": [],
        "tacsSorcBlobTableVersion": ""
    }
}
