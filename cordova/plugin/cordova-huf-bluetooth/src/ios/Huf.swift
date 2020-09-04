import TACS
import SecureAccessBLE

@objc(Huf) class Huf : CDVPlugin {
    
    private var tacsManager: TACSManager!
    private var disposeBag: DisposeBag!
    private var callbackId: String!
    
    /**
     Register a callback id. This callback id is later used to send the events back to the javascript
      mapped to the corresponding request made.
     */
    @objc(registerCallbackId:)
    func registerCallbackId(command: CDVInvokedUrlCommand) {
        print("Registering callback id")
        callbackId = command.callbackId
    }
    
    /**
    Initialize the plugin by building the TACS Manager with necessary keyring provided by the app.
     Also register all subscriptions need to be present to observe any change in event from the TACS library.
    */
    @objc(initPlugin:)
    func initPlugin(command: CDVInvokedUrlCommand) {
        
        print("Initializing the plugin")
        
        let vehicleAccessGrantId: String = "MySampleAccessGrantId"
        let queue = DispatchQueue(label: "com.hufsm.blehandling")
        tacsManager = TACSManager(queue: queue)
        disposeBag = DisposeBag()
        let json = command.argument(at: 0) as! String
        let data = json.data(using: .utf8)
        let keyRing = try! JSONDecoder().decode(TACSKeyRing.self, from: data!)
        
        registerSubscriptions()
        
        // Prepare tacsmanager with vehicleAccessGrantId and appropriate keyring
        let useAccessGrantResult = tacsManager.useAccessGrant(with: vehicleAccessGrantId, from: keyRing)
        assert(useAccessGrantResult)
        
        if (useAccessGrantResult) {
            self.sendEventBackToJs(message: "Ready to connect")
        } else {
            self.sendEventBackToJs(message: "Keyring error")
        }
    }
    
    /**
     On connect BLE requested, the TACS library starts scanning for the device with the SORC ID
       that was present in the keyring.
     */
    @objc(connectBle:)
    func connectBle(command: CDVInvokedUrlCommand) {
        print("TACS Connect BLE requetsed")
        
        // Connect
        guard .poweredOn == tacsManager.bluetoothState.state else { return }
        if case .connected = tacsManager.connectionChange.state { return }
        // Start scanning for vehicles
        tacsManager.startScanningWithTimeout()
    }
    
    /**
     On disconnect BLE requested, the TACS library disconnects any active BLE connection
    */
    @objc(disconnectBle:)
    func disconnectBle(command: CDVInvokedUrlCommand) {
        print("TACS Disconnect BLE requested")
        
        // Disconnect
        guard .disconnected != tacsManager.connectionChange.state else { return }
        tacsManager.disconnect()
    }

    /**
     On location requested, the TACS library is requested for the location data of the sorc
    */
    @objc(executeLocation:)
    func executeLocation(command: CDVInvokedUrlCommand) {
        print("TACS execute Location")
        
        tacsManager.telematicsManager.requestLocationData()
    }

    /**
     On telematics requested, the TACS library is requested for the telematics data of the sorc
    */
    @objc(executeTelematics:)
    func executeTelematics(command: CDVInvokedUrlCommand) {
        print("TACS execute Telematics")
        
        tacsManager.telematicsManager.requestTelematicsData([.odometer, .fuelLevelAbsolute, .fuelLevelPercentage])
    }
    
    /**
     On lock requested, the TACS library is requested for the door lock
    */
    @objc(executeLock:)
    func executeLock(command: CDVInvokedUrlCommand) {
        print("TACS Executing lock")
        
        tacsManager.vehicleAccessManager.requestFeature(.lock)
        tacsManager.vehicleAccessManager.requestFeature(.lockStatus)
    }

    /**
     On engine off requested, the TACS library is requested for the engine off
    */
    @objc(executeEngineOff:)
    func executeEngineOff(command: CDVInvokedUrlCommand) {
        print("TACS Executing execute Engine Off")
        
        tacsManager.vehicleAccessManager.requestFeature(.disableIgnition)
        tacsManager.vehicleAccessManager.requestFeature(.ignitionStatus)
    }

    /**
     On engine off requested, the TACS library is requested for the engine off
    */
    @objc(executeEngineOn:)
    func executeEngineOn(command: CDVInvokedUrlCommand) {
        print("TACS Executing execute Engine On")
        
        tacsManager.vehicleAccessManager.requestFeature(.enableIgnition)
        tacsManager.vehicleAccessManager.requestFeature(.ignitionStatus)
    }
    
    /**
     On unlock requested, the TACS library is requested for the door unlock
    */
    @objc(executeUnlock:)
    func executeUnlock(command: CDVInvokedUrlCommand) {
        print("TACS Executing unlock")
        
        tacsManager.vehicleAccessManager.requestFeature(.unlock)
        tacsManager.vehicleAccessManager.requestFeature(.lockStatus)
    }
    
    /**
     Register all subscriptions such as for observing the -
     1. bluetooth state of the device
     2. Any SORC discovery change
     3.Any SORC connection change
     4. Any vehicle access change that includes door and engine status
     5. Any telematics data change that includes fuel and odometer values
     6. Any location data change that includes latitutde, longitude and accuracy values
    */
    private func registerSubscriptions() {
        
        // Subscribe to bluetooth state signal
        tacsManager.bluetoothState.subscribe { [weak self] bluetoothState in
            self?.onBluetoothStateChange(bluetoothState)
        }.disposed(by: disposeBag)
        
        // Subscribe to discovery change signal
        tacsManager.discoveryChange.subscribe { [weak self] discoveryChange in
            // handle discovery state changes
            self?.onDiscoveryChange(discoveryChange)
        }.disposed(by: disposeBag) // add disposable to a disposeBag which will take care about removing subscriptions on deinit
        
        // Subscribe to connection change signal
        tacsManager.connectionChange.subscribe { [weak self] connectionChange in
            self?.onConnectionChange(connectionChange)
        }.disposed(by: disposeBag)
        
        // Subscribe to vehicle access change signal
        tacsManager.vehicleAccessManager.vehicleAccessChange.subscribe { [weak self] vehicleAccessChange in
            // Handle vehicle access changes
            self?.onVehicleAccessFeatureChange(vehicleAccessChange)
        }.disposed(by: disposeBag)
        
        // Subscribe to telematics data change signal
        tacsManager.telematicsManager.telematicsDataChange.subscribe { [weak self] telematicsDataChange in
            self?.onTelematicsDataChange(telematicsDataChange)
        }.disposed(by: disposeBag)
        
        // Subscribe to location data change signal
        tacsManager.telematicsManager.locationDataChange.subscribe { [weak self] locationDataChange in
            self?.onLocationDataChange(locationDataChange)
        }.disposed(by: disposeBag)
    }
    
    /**
     On bluetooth state change, the event is sent back to the Huf.js
     */
    private func onBluetoothStateChange(_ bluetoothState: BluetoothState) {
        // Reflect on ble device change by providing necessary feedback to the user.
        // Running discoveries for vehicle or keyholder will automatically stop and notified via signals.
        DispatchQueue.main.async { [weak self] in
            self?.sendEventBackToJs(message: String(describing: bluetoothState))
        }
    }
    
    /**
     On discovery state change, the event is sent back to the Huf.js
    */
    private func onDiscoveryChange(_ discoveryChange: TACS.DiscoveryChange) {
        var discoveryStatus: String = ""
        switch discoveryChange.action {
        case .discoveryStarted(_):
            discoveryStatus = "Searching"
        case .discovered(_):
            // If the vehicle is discovered, we start connecting to the vehicle.
            discoveryStatus = "Connecting"
            tacsManager.connect()
        case .discoveryFailed:
            discoveryStatus = "Search Failed"
        default:
            break
        }
        self.sendEventBackToJs(message: discoveryStatus)
    }
    
    /**
     On connection state change, the event is sent back to the Huf.js
    */
    private func onConnectionChange(_ connectionChange: TACS.ConnectionChange) {
        let status: String
        
        switch connectionChange.state {
        case .connected: status = "Connected"
        case .connecting: status = "Connecting"
        case .disconnected: status = "Disconnected"
        }
        
        self.sendEventBackToJs(message: status)
    }
    
    /**
     On vehicle state change that includes door or engine status, the event is sent back to the Huf.js
    */
    private func onVehicleAccessFeatureChange(_ vehicleAccessFeatureChange: VehicleAccessFeatureChange) {
      var doorStatus: String = ""
        var engineStatus: String = ""
            switch vehicleAccessFeatureChange.action {
            case .initial: break
            case let .requestFeature(feature: feature, accepted: accepted):
                if (!accepted) {
                    switch feature {
                    case .lock, .unlock, .lockStatus:
                        doorStatus = "Not accepted, queue is full"
                        self.sendEventBackToJs(message: doorStatus)
                    case .enableIgnition, .disableIgnition, .ignitionStatus:
                        engineStatus = "Not accepted, queue is full"
                        self.sendEventBackToJs(message: engineStatus)
                    }
                }
            case .responseReceived(response: let response):
                switch response {
                case let .success(status: status):
                    if case let .ignitionStatus(enabled: enabled) = status {
                        engineStatus = enabled ? "Ignition enabled" : "Ignition disabled"
                        self.sendEventBackToJs(message: engineStatus)
                    } else if case let .lockStatus(locked: locked) = status {
                        doorStatus = locked ? "Doors locked" : "Doors unlocked"
                        self.sendEventBackToJs(message: doorStatus)
                    }
                case let .failure(feature: feature, error: error):
                    switch feature {
                    case .lock, .unlock, .lockStatus:
                        doorStatus = "Error: \(String(describing: error))"
                        self.sendEventBackToJs(message: doorStatus)
                    case .enableIgnition, .disableIgnition, .ignitionStatus:
                        engineStatus = "Error: \(String(describing: error))"
                        self.sendEventBackToJs(message: engineStatus)
                    }
                }
            }
    }
    
    /**
     On location state change, the event is sent back to the Huf.js
    */
    private func onLocationDataChange(_ locationDatachange: LocationDataChange) {
        DispatchQueue.main.async {
            if case let .responseReceived(response) = locationDatachange.action {
                switch response {
                case .success(let data):
                    self.updateLocationData(data)
                    break
                case .error(let error):
                    self.updateLocationError(error)
                    break
                }
            }
        }
    }
    
    /**
     On telematics state change, the event is sent back to the Huf.js
    */
    private func onTelematicsDataChange(_ telematicsDataChange: TelematicsDataChange) {
        DispatchQueue.main.async {
            if case let .responseReceived(responses) = telematicsDataChange.action {
                for response in responses {
                    switch response {
                    case .success(let data):
                        self.updateTelematicsData(data)
                        break
                    case let .error(type, error):
                        self.updateTelematicsError(error, type: type)
                        break
                    }
                }
            }
        }
    }
    
    private func updateLocationData(_ data: LocationData) {
        let latitude = String(format: "%f", data.latitude)
        let longitude = String(format: "%f", data.longitude)
        let accuracy = String(format: "%f", data.accuracy)
        let locationValue: String = latitude + ";" + longitude + ";" + accuracy
        self.sendEventBackToJs(message: locationValue)
    }
    
    private func updateLocationError(_ error: TelematicsDataError) {
        self.sendEventBackToJs(message: error.rawValue)
    }
    
    private func updateTelematicsData(_ data: TelematicsData) {
        var fuelAbsValue: String = "Not available"
        var fuelRelValue: String = "Not available"
        var odometerValue: String = "Not available"
        switch data.type {
        case .fuelLevelAbsolute:
            fuelAbsValue = "\(data.value) \(data.unit)"
        case .fuelLevelPercentage:
            fuelRelValue = "\(data.value) \(data.unit)"
        case .odometer:
            odometerValue = "\(data.value) \(data.unit)"
        }
        let telematicsData: String = fuelAbsValue + ";" + fuelRelValue + ";" + odometerValue
        self.sendEventBackToJs(message: telematicsData)
    }
    
    private func updateTelematicsError(_ error: TelematicsDataError, type: TelematicsDataType) {
        self.sendEventBackToJs(message: error.rawValue)
    }
    /**
     Send the events received from the TACS library back to the Huf.js that will forward it to the app
     */
    private func sendEventBackToJs(message: String) {
        var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "The Plugin Failed");
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message);
        pluginResult?.setKeepCallbackAs(true)
        self.commandDelegate!.send(pluginResult, callbackId: self.callbackId);
    }
}
