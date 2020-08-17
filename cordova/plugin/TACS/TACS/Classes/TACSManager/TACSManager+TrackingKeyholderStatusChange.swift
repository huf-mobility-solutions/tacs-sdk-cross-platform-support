//
//  TACSManager+TrackingKeyholderStatusChange.swift
//  TACS
//
//  Created by Priya Khatri on 12.02.20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SecureAccessBLE

extension TACSManager {
    internal func setupKeyholderTracking() {
        keyholderManager.keyholderChange.subscribe { [activeVehicleSetup] change in
            var event: TrackingEvent
            var logLevel: LogLevel
            var parameters: [String: Any] = [:]
            if let vehicleSetup = activeVehicleSetup {
                parameters = [ParameterKey.keyholderID.rawValue: vehicleSetup.keyholderId?.uuidString ?? "",
                              ParameterKey.vehicleRef.rawValue: vehicleSetup.extenralVehicleRef]
            }
            switch change.action {
            case let .discovered(keyholderInfo):
                parameters[ParameterKey.data.rawValue] = ["isCardInserted": keyholderInfo.isCardInserted,
                                                          "activationCount": keyholderInfo.activationCount,
                                                          "batteryChangeCount": keyholderInfo.batteryChangeCount,
                                                          "batteryVoltage": keyholderInfo.batteryVoltage]
                event = .keyholderStatusReceived
                logLevel = .info
            case let .failed(error):
                parameters[ParameterKey.error.rawValue] = String(describing: error)
                event = .keyholderStatusFailed
                logLevel = .error
            default:
                return
            }
            HSMTrack(event, parameters: parameters, loglevel: logLevel)
        }.disposed(by: disposeBag)
    }
}
