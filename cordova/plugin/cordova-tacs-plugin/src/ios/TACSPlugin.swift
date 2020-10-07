import TACS
import SecureAccessBLE

@objc(TACSPlugin) class TACSPlugin : CDVPlugin {
    
    enum TACSError : Error {
        case bluetoothDisabled
        case connectionFailed
    }
    
    private var tacsManager: TACSManager!
    private var disposeBag: DisposeBag!
    private var callbackId: String!
    
    /**
     Register a callback id. This callback id is later used to send the events back to the javascript
      mapped to the corresponding request made.
     */
    @objc(setupEventChannel:)
    func setupEventChannel(command: CDVInvokedUrlCommand) {

        print("TACS setting up event channel...")
        
        self.callbackId = command.callbackId

        self.dispatchEvent("initialized")
    }
    
    /**
    Initialize the plugin by building the TACS Manager with necessary keyring provided by the app.
     Also register all subscriptions need to be present to observe any change in event from the TACS library.
    */
    @objc(initialize:)
    func initialize(command: CDVInvokedUrlCommand) {
        
        print("TACS initializing plugin...")
        
        // let vehicleAccessGrantId: String = "MySampleAccessGrantId"
        
        let queue = DispatchQueue(label: "com.hufsm.tacs")
        
        self.tacsManager = TACSManager(queue: queue)
        
        self.disposeBag = DisposeBag()

        let accessGrantId = command.argument(at: 0) as! String
        
        let keyringJson = command.argument(at: 1) as! String
        let keyringData = keyringJson.data(using: .utf8)
        let keyring = try! JSONDecoder().decode(TACSKeyRing.self, from: keyringData!)
        
        registerSubscriptions()
        
        let accessGrantIsValid = tacsManager.useAccessGrant(with: accessGrantId, from: keyring)

        if (accessGrantIsValid) {

            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Ready to connect")

            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)

        } else {

            let pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "Keyring invalid")

            self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    /**
     On connect BLE requested, the TACS library starts scanning for the device with the SORC ID
       that was present in the keyring.
     */
    @objc(connect:)
    func connect(command: CDVInvokedUrlCommand) {

        print("TACS connecting...")
        
        var discoverySubscription: Disposable?
        var connectionSubscription: Disposable?
        
        func handleResult(_ result: Result<Void, Error>) {
            
            discoverySubscription?.dispose()
            connectionSubscription?.dispose()
            
            switch result {
            case .success:
                
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "")

                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                
            case .failure(let error):
                
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: error.localizedDescription)

                self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }
        }
        
        let bluetoothState = self.tacsManager.bluetoothState.state
        
        if bluetoothState == .unknown || bluetoothState == .poweredOff {

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                handleResult(.failure(TACSError.bluetoothDisabled))
            }

            return
        }
        
        if case .connected = self.tacsManager.connectionChange.state {
            handleResult(.success(()))
            return
        }
        
        discoverySubscription = self.tacsManager.discoveryChange.subscribe { change in
            
            switch change.action {
            case .discovered:
                discoverySubscription?.dispose()
                self.tacsManager.connect()
            case .discoveryFailed:
                handleResult(.failure(TACSError.connectionFailed))
            default: break
            }
        }
        
        connectionSubscription = self.tacsManager.connectionChange.subscribe { change in
            
            switch change.action {
            case .connectionEstablished:
                handleResult(.success(()))
            case .connectingFailed(vehicleRef: _, error: let error):
                handleResult(.failure(error))
            default: break
            }
        }
        
        self.tacsManager.startScanningWithTimeout()
    }
    
    /**
     On disconnect BLE requested, the TACS library disconnects any active BLE connection
    */
    @objc(disconnect:)
    func disconnect(command: CDVInvokedUrlCommand) {

        print("TACS disconnecting...")
        
        // Disconnect
        guard .disconnected != tacsManager.connectionChange.state else { return }

        tacsManager.disconnect()

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "")

        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }

    /**
     On location requested, the TACS library is requested for the location data of the sorc
    */
    @objc(requestLocation:)
    func requestLocation(command: CDVInvokedUrlCommand) {

        print("TACS request location")
        
        tacsManager.telematicsManager.requestLocationData()

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "")

        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }

    /**
     On telematics requested, the TACS library is requested for the telematics data of the sorc
    */
    @objc(requestTelematicsData:)
    func requestTelematicsData(command: CDVInvokedUrlCommand) {

        print("TACS request telematics data")
        
        tacsManager.telematicsManager.requestTelematicsData([.odometer, .fuelLevelAbsolute, .fuelLevelPercentage])

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "")

        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
    
    /**
     On lock requested, the TACS library is requested for the door lock
    */
    @objc(lock:)
    func lock(command: CDVInvokedUrlCommand) {

        print("TACS engaging lock...")
        
        tacsManager.vehicleAccessManager.requestFeature(.lock)
        tacsManager.vehicleAccessManager.requestFeature(.lockStatus)

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "")

        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }

    /**
     On unlock requested, the TACS library is requested for the door unlock
    */
    @objc(unlock:)
    func unlock(command: CDVInvokedUrlCommand) {

        print("TACS disengaging lock...")
        
        tacsManager.vehicleAccessManager.requestFeature(.unlock)
        tacsManager.vehicleAccessManager.requestFeature(.lockStatus)

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "")

        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }

    /**
     On engine off requested, the TACS library is requested for the engine off
    */
    @objc(enableIgnition:)
    func enableIgnition(command: CDVInvokedUrlCommand) {

        print("TACS enable ignition...")
        
        tacsManager.vehicleAccessManager.requestFeature(.enableIgnition)
        tacsManager.vehicleAccessManager.requestFeature(.ignitionStatus)

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "")

        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }

    /**
     On engine off requested, the TACS library is requested for the engine off
    */
    @objc(disableIgnition:)
    func disableIgnition(command: CDVInvokedUrlCommand) {

        print("TACS disable ignition...")
        
        tacsManager.vehicleAccessManager.requestFeature(.disableIgnition)
        tacsManager.vehicleAccessManager.requestFeature(.ignitionStatus)

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "")

        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
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
            self?.dispatchEvent("bluetoothStateChanged", detail: ["state": String(describing: bluetoothState)])
        }
    }
    
    /**
     On discovery state change, the event is sent back to the Huf.js
    */
    private func onDiscoveryChange(_ discoveryChange: TACS.DiscoveryChange) {

        switch discoveryChange.action {
        case .discoveryStarted(_):
            self.dispatchEvent("discoveryStarted")
        case .discovered(_):
            self.dispatchEvent("discovered")
            tacsManager.connect()
        case .discoveryFailed:
            self.dispatchEvent("discoveryFailed")
        default:
            break
        }
    }
    
    /**
     On connection state change, the event is sent back to the Huf.js
    */
    private func onConnectionChange(_ connectionChange: TACS.ConnectionChange) {

        switch connectionChange.state {
        case .connected:
            self.dispatchEvent("connectionStateChanged", detail: ["state" : "connected"])
        case .connecting:
            self.dispatchEvent("connectionStateChanged", detail: ["state" : "connecting"])
        case .disconnected:
            self.dispatchEvent("connectionStateChanged", detail: ["state" : "disconnected"])
        }
    }
    
    /**
     On vehicle state change that includes door or engine status, the event is sent back to the Huf.js
    */
    private func onVehicleAccessFeatureChange(_ vehicleAccessFeatureChange: VehicleAccessFeatureChange) {
        switch vehicleAccessFeatureChange.action {
        case .initial: break
        case let .requestFeature(feature: feature, accepted: accepted):
            if (!accepted) {
                switch feature {
                case .lock, .unlock, .lockStatus:
                    self.dispatchEvent("doorStatusChanged", detail: [
                        "state": "error",
                        "message": "Could not request door status, queue is full.",
                    ])
                case .enableIgnition, .disableIgnition, .ignitionStatus:
                    self.dispatchEvent("engineStatusChanged", detail: [
                        "state": "error",
                        "message": "Could not request engine status, queue is full.",
                    ])
                }
            }
        case .responseReceived(response: let response):
            switch response {
            case let .success(status: status):
                if case let .ignitionStatus(enabled: enabled) = status {
                    self.dispatchEvent("ignitionStatusChanged", detail: [
                        "state": enabled ? "enabled" : "disabled",
                    ])
                } else if case let .lockStatus(locked: locked) = status {
                    self.dispatchEvent("doorStatusChanged", detail: [
                        "state": locked ? "locked" : "unlocked",
                    ])
                }
            case let .failure(feature: feature, error: error):
                switch feature {
                case .lock, .unlock, .lockStatus:
                    self.dispatchEvent("doorStatusChanged", detail: [
                        "state": "error",
                        "message": String(describing: error),
                    ])
                case .enableIgnition, .disableIgnition, .ignitionStatus:
                    self.dispatchEvent("ignitionStatusChanged", detail: [
                        "state": "error",
                        "message": String(describing: error),
                    ])
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
        
        self.dispatchEvent("locationChanged", detail: [
            "latitude": data.latitude,
            "longitude": data.longitude,
            "accuracy": data.accuracy,
        ])
    }
    
    private func updateLocationError(_ error: TelematicsDataError) {
        
        self.dispatchEvent("locationChanged", detail: [
            "error": error.rawValue
        ])
    }
    
    private func updateTelematicsData(_ data: TelematicsData) {

        self.dispatchEvent("telematicsDataChanged", detail: [
            "type": data.type.name,
            "unit": data.unit,
            "value": data.value,
        ])
    }
    
    private func updateTelematicsError(_ error: TelematicsDataError, type: TelematicsDataType) {
        
        self.dispatchEvent("telematicsDataChanged", detail: [
            "type": type.name,
            "error": error.rawValue,
        ])
    }

    private func dispatchEvent(_ type: String, detail: [String : Any] = [:]) {

        let event: [String : Any] = [
            "type": "tacs:\(type)",
            "detail": detail
        ]
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: event)

        pluginResult?.setKeepCallbackAs(true)

        self.commandDelegate!.send(pluginResult, callbackId: self.callbackId);
    }
}

extension TelematicsDataType {
    
    var name: String {
        switch self {
        case .fuelLevelAbsolute: return "fuelLevelAbsolute"
        case .fuelLevelPercentage: return "fuelLevelPercentage"
        case .odometer: return "odometer"
        }
    }
}
