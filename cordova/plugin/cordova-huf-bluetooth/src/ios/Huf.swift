import TACS
import SecureAccessBLE

@objc(Huf) class Huf : CDVPlugin {
    
    private var tacsManager: TACSManager!
    private var disposeBag: DisposeBag!
    
    @objc(buildKeyring:)
    func buildKeyring(command: CDVInvokedUrlCommand) {
        
        print("Building Keyring")
        
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
        
        // Set the plugin result to fail.
        var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "The Plugin Failed");
        
        // Set the plugin result to succeed.
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "The plugin succeeded");
        
        // Send the function result back to Cordova.
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }
    
    @objc(connectBle:)
    func connectBle(command: CDVInvokedUrlCommand) {
        print("TACS Connecting BLE")
        
        // Connect
        guard .poweredOn == tacsManager.bluetoothState.state else { return }
        if case .connected = tacsManager.connectionChange.state { return }
        // Start scanning for vehicles
        tacsManager.startScanningWithTimeout()
        
        // Set the plugin result to fail.
        var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "The Plugin Failed");
        
        // Set the plugin result to succeed.
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "The plugin succeeded");
        
        // Send the function result back to Cordova.
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }
    
    @objc(disconnectBle:)
    func disconnectBle(command: CDVInvokedUrlCommand) {
        print("TACS Disconnecting BLE")
        
        // Disconnect
        guard .disconnected != tacsManager.connectionChange.state else { return }
        tacsManager.disconnect()
        
        // Set the plugin result to fail.
        var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "The Plugin Failed");
        
        // Set the plugin result to succeed.
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "The plugin succeeded");
        
        // Send the function result back to Cordova.
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }
    
    @objc(executeLock:)
    func executeLock(command: CDVInvokedUrlCommand) {
        print("TACS Executing lock")
        
        tacsManager.vehicleAccessManager.requestFeature(.lock)
        tacsManager.vehicleAccessManager.requestFeature(.lockStatus)
        
        // Set the plugin result to fail.
        var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "The Plugin Failed");
        
        // Set the plugin result to succeed.
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "The plugin succeeded");
        
        // Send the function result back to Cordova.
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }
    
    @objc(executeUnlock:)
    func executeUnlock(command: CDVInvokedUrlCommand) {
        print("TACS Executing unlock")
        
        tacsManager.vehicleAccessManager.requestFeature(.unlock)
        tacsManager.vehicleAccessManager.requestFeature(.lockStatus)
        
        // Set the plugin result to fail.
        var pluginResult = CDVPluginResult (status: CDVCommandStatus_ERROR, messageAs: "The Plugin Failed");
        
        // Set the plugin result to succeed.
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "The plugin succeeded");
        
        // Send the function result back to Cordova.
        self.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
    }
    
    
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
        
        //Subscribe to keyholder state change signal
        tacsManager.keyholderManager.keyholderChange.subscribe { [weak self] change  in
            self?.onKeyholderStatusChange(change)
        }.disposed(by: disposeBag)
    }
    
    private func onBluetoothStateChange(_ bluetoothState: BluetoothState) {
        // Reflect on ble device change by providing necessary feedback to the user.
        // Running discoveries for vehicle or keyholder will automatically stop and notified via signals.
        DispatchQueue.main.async { [weak self] in
            print("Bluetooth state is")
            print(bluetoothState)
        }
    }
    
    private func onDiscoveryChange(_ discoveryChange: TACS.DiscoveryChange) {
        switch discoveryChange.action {
        case .discoveryStarted(_):
            DispatchQueue.main.async { [weak self] in
                print("Discovering...")
            }
        case .discovered(_):
            // If the vehicle is discovered, we start connecting to the vehicle.
            tacsManager.connect()
        case .discoveryFailed:
            DispatchQueue.main.async { [weak self] in
                print("Discovering failed...")
            }
        default:
            break
        }
    }
    
    private func onConnectionChange(_ connectionChange: TACS.ConnectionChange) {
        let status: String
        
        switch connectionChange.state {
        case .connected: status = "Connected"
        case .connecting: status = "Connecting"
        case .disconnected: status = "Disconnected"
        }
        
        DispatchQueue.main.async {
            print("On connection change")
            print(status)
        }
    }
    
    private func onVehicleAccessFeatureChange(_ vehicleAccessFeatureChange: VehicleAccessFeatureChange) {
        DispatchQueue.main.async {
            switch vehicleAccessFeatureChange.action {
            case .initial: break
            case let .requestFeature(feature: feature, accepted: accepted):
                if (!accepted) {
                    switch feature {
                    case .lock, .unlock, .lockStatus:
                        break
                    case .enableIgnition, .disableIgnition, .ignitionStatus:
                        break
                    }
                }
            case .responseReceived(response: let response):
                switch response {
                case let .success(status: status):
                    if case let .ignitionStatus(enabled: enabled) = status {
                        break
                    } else if case let .lockStatus(locked: locked) = status {
                        break
                    }
                case let .failure(feature: feature, error: error):
                    switch feature {
                    case .lock, .unlock, .lockStatus:
                        break
                    case .enableIgnition, .disableIgnition, .ignitionStatus:
                        break
                    }
                }
            }
        }
    }
    
    private func onLocationDataChange(_ locationDatachange: LocationDataChange) {
        DispatchQueue.main.async {
            if case let .responseReceived(response) = locationDatachange.action {
                switch response {
                case .success(let data):
                    break
                case .error(let error):
                    break
                }
            }
        }
    }
    
    private func onTelematicsDataChange(_ telematicsDataChange: TelematicsDataChange) {
        DispatchQueue.main.async {
            if case let .responseReceived(responses) = telematicsDataChange.action {
                for response in responses {
                    switch response {
                    case .success(let data):
                        break
                    case let .error(type, error):
                        break
                    }
                }
            }
        }
    }
    
    private func onKeyholderStatusChange(_ change: KeyholderStatusChange) {
        DispatchQueue.main.async {
            switch change.action {
            case .discoveryStarted:
                break
            case .discovered(let info):
                break
            case .failed(let error):
                break
            case .initial: break
            }
        }
    }
}
