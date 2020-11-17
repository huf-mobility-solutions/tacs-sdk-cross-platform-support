//
//  TACSManager+TrackingActionChange.swift
//  TACS
//
//  Created on 10.02.20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SecureAccessBLE

extension TACSManager {
    internal func trackDiscoveryChange(_ discoveryChange: DiscoveryChange) {
        var event: TrackingEvent
        var logLevel: LogLevel

        var parameters: [String: Any] = [:]
        if let vehicleSetup = activeVehicleSetup {
            parameters = [ParameterKey.sorcID.rawValue: vehicleSetup.sorcId.uuidString,
                          ParameterKey.vehicleRef.rawValue: vehicleSetup.extenralVehicleRef]
        }

        switch discoveryChange.action {
        case .discovered:
            event = .discoverySuccessful
            logLevel = .info
        case .lost:
            event = .discoveryLost
            logLevel = .info
        case .disconnected:
            event = .connectionDisconnected
            logLevel = .info
        case .startDiscovery, .discoveryStarted:
            event = .discoveryStarted
            logLevel = .info
        case .stopDiscovery:
            event = .discoveryStopped
            logLevel = .info
        case .discoveryFailed:
            event = .discoveryFailed
            logLevel = .error
        case .initial, .rediscovered, .disconnect, .reset, .missingBlobData:
            return
        }

        HSMTrack(event, parameters: parameters, loglevel: logLevel)
    }

    internal func trackConnectionChange(_ connectionChange: ConnectionChange) {
        var event: TrackingEvent
        var logLevel: LogLevel

        var parameters: [String: Any] = [:]
        if let vehicleSetup = activeVehicleSetup {
            parameters = [ParameterKey.sorcID.rawValue: vehicleSetup.sorcId.uuidString,
                          ParameterKey.vehicleRef.rawValue: vehicleSetup.extenralVehicleRef]
        }

        switch connectionChange.action {
        case .connect:
            event = .connectionStarted
            logLevel = .info
        case .connectionEstablished:
            event = .connectionEstablished
            logLevel = .info
        case let .connectingFailed(_, error):
            parameters[ParameterKey.error.rawValue] = String(describing: error)
            event = .connectionFailed
            logLevel = .error
        case .connectingFailedDataMissing:
            parameters[ParameterKey.error.rawValue] = "Failure in connecting due to missing data"
            event = .connectionFailed
            logLevel = .error
        case .disconnect:
            event = .connectionDisconnected
            logLevel = .info
        case let .connectionLost(error):
            parameters[ParameterKey.error.rawValue] = String(describing: error)
            event = .connectionFailed
            logLevel = .error
        case .initial, .physicalConnectionEstablished:
            return
        }

        HSMTrack(event, parameters: parameters, loglevel: logLevel)
    }
}
