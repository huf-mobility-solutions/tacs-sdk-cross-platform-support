//
//  TACSManager+TrackingVehicleAccess.swift
//  TACS
//
//  Created on 07.02.20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SecureAccessBLE

extension TACSManager {
    internal func setUpVehicleAccessTracking() {
        vehicleAccessManager.vehicleAccessChange.subscribe { [activeVehicleSetup] change in
            var parameters: [String: Any] = [:]
            if let vehicleSetup = activeVehicleSetup {
                parameters = [ParameterKey.sorcID.rawValue: vehicleSetup.sorcId.uuidString,
                              ParameterKey.vehicleRef.rawValue: vehicleSetup.extenralVehicleRef]
            }
            switch change.action {
            case let .requestFeature(feature, accepted):
                if !accepted {
                    parameters[ParameterKey.error.rawValue] = "Queue is full"
                    self.trackVehicleAccessRequestFailed(for: feature,
                                                         parameters: parameters)
                }
            case let .responseReceived(response):
                switch response {
                case let .success(status):
                    self.trackVehicleAccessResponse(for: status, defaultParameters: parameters)
                case let .failure(feature, error):
                    parameters[ParameterKey.error.rawValue] = String(describing: error)
                    self.trackVehicleAccessRequestFailed(for: feature,
                                                         parameters: parameters)
                }
            default:
                break
            }
        }.disposed(by: disposeBag)
    }

    private func trackVehicleAccessResponse(for status: VehicleAccessFeatureStatus,
                                            defaultParameters: [String: Any]) {
        var event: TrackingEvent
        var parameters = defaultParameters
        switch status {
        case .lock:
            event = .doorsLocked
        case .unlock:
            event = .doorsUnlocked
        case .enableIgnition:
            event = .engineEnabled
        case .disableIgnition:
            event = .engineDisabled
        case let .lockStatus(locked):
            event = .doorsStatusReceived
            parameters[ParameterKey.data.rawValue] = locked ? "Locked" : "Unlocked"
        case let .ignitionStatus(enabled):
            event = .engineStatusReceived
            parameters[ParameterKey.data.rawValue] = enabled ? "Enabled" : "Disabled"
        }
        HSMTrack(event, parameters: parameters, loglevel: .info)
    }

    private func trackVehicleAccessRequestFailed(for feature: VehicleAccessFeature,
                                                 parameters: [String: Any]) {
        var event: TrackingEvent

        switch feature {
        case .unlock:
            event = .doorsUnlockFailed
        case .lock:
            event = .doorsLockFailed
        case .enableIgnition:
            event = .engineEnableFailed
        case .disableIgnition:
            event = .engineDisableFailed
        case .lockStatus:
            event = .doorsStatusFailed
        case .ignitionStatus:
            event = .engineStatusFailed
        }
        HSMTrack(event, parameters: parameters, loglevel: .error)
    }
}

extension VehicleAccessManager {
    internal func trackVehicleAccessRequested(for feature: VehicleAccessFeature,
                                              defaultParameters: [String: Any]) {
        var event: TrackingEvent
        switch feature {
        case .unlock:
            event = .doorsUnlockRequested
        case .lock:
            event = .doorsLockRequested
        case .enableIgnition:
            event = .engineEnableRequested
        case .disableIgnition:
            event = .engineDisableRequested
        case .lockStatus:
            event = .doorsStatusRequested
        case .ignitionStatus:
            event = .engineStatusRequested
        }

        HSMTrack(event, parameters: defaultParameters, loglevel: .info)
    }
}
