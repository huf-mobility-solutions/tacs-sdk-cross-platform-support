//
//  TACSManager+Tracking.swift
//  TACS
//
//  Created on 06.02.20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SecureAccessBLE

extension TACSManager {
    internal func setUpTracking() {
        setUpLocationTracking()
        setUpTelematicsTracking()
        setUpVehicleAccessTracking()
        setupKeyholderTracking()
    }

    private func setUpLocationTracking() {
        telematicsManager.locationDataChange.subscribe { [activeVehicleSetup] change in
            var parameters: [String: Any] = [:]
            if let vehicleSetup = activeVehicleSetup {
                parameters = [ParameterKey.sorcID.rawValue: vehicleSetup.sorcId.uuidString,
                              ParameterKey.vehicleRef.rawValue: vehicleSetup.extenralVehicleRef]
            }
            switch change.action {
            case let .requestingData(accepted: accepted):
                if !accepted {
                    parameters[ParameterKey.error.rawValue] = "Queue is full"
                    HSMTrack(.locationRequestFailed, parameters: parameters, loglevel: .error)
                }
            case let .responseReceived(response: response):
                self.trackLocationResponse(response, defaultParameters: parameters)
            default: return
            }

        }.disposed(by: disposeBag)
    }

    func trackLocationResponse(_ response: LocationDataResponse, defaultParameters: [String: Any]) {
        let event: TrackingEvent
        let logLevel: LogLevel
        var parameters = defaultParameters
        switch response {
        case let .error(error):
            event = .locationRequestFailed
            logLevel = .error
            parameters[ParameterKey.error.rawValue] = String(describing: error)
        case let .success(data):
            event = .locationReceived
            logLevel = .info
            parameters[ParameterKey.data.rawValue] = data.loggableData()
        }
        HSMTrack(event, parameters: parameters, loglevel: logLevel)
    }

    private func setUpTelematicsTracking() {
        telematicsManager.telematicsDataChange.subscribe { [activeVehicleSetup] change in
            var parameters: [String: Any] = [:]
            if let vehicleSetup = activeVehicleSetup {
                parameters = [ParameterKey.sorcID.rawValue: vehicleSetup.sorcId.uuidString,
                              ParameterKey.vehicleRef.rawValue: vehicleSetup.extenralVehicleRef]
            }
            switch change.action {
            case let .requestingData(_, accepted):
                if !accepted {
                    parameters[ParameterKey.error.rawValue] = "Queue is full"
                    HSMTrack(.telematicsRequestFailed, parameters: parameters, loglevel: .error)
                }
            case let .responseReceived(responses):
                responses.forEach { telematicsDataResponse in
                    self.trackTelematicsResponse(telematicsDataResponse: telematicsDataResponse,
                                                 defaultParameters: parameters)
                }
            default:
                return
            }
        }.disposed(by: disposeBag)
    }

    private func trackTelematicsResponse(telematicsDataResponse: TelematicsDataResponse,
                                         defaultParameters: [String: Any]) {
        var event: TrackingEvent
        var parameters = defaultParameters
        var logLevel: LogLevel
        switch telematicsDataResponse {
        case let .success(data):
            event = .telematicsReceived
            logLevel = .info
            parameters[ParameterKey.data.rawValue] = data.loggableData()
        case let .error(data, error):
            event = .telematicsRequestFailed
            logLevel = .error
            parameters[ParameterKey.data.rawValue] = String(describing: data)
            parameters[ParameterKey.error.rawValue] = String(describing: error)
        }
        HSMTrack(event, parameters: parameters, loglevel: logLevel)
    }
}

extension LocationData {
    func loggableData() -> [String: String] {
        return [
            "lat": String(latitude),
            "long": String(longitude),
            "timestamp": timestamp,
            "accuracy": String(accuracy)
        ]
    }
}

extension TelematicsData {
    func loggableData() -> [String: String] {
        return [
            "type": String(describing: self.type),
            "timestamp": self.timestamp,
            "value": String(self.value),
            "unit": unit
        ]
    }
}
