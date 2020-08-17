//
//  TrackingEvent.swift
//  TACS
//
//  Created on 06.02.20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

internal enum TrackingEvent: String {
    case interfaceInitialized
    case accessGrantAccepted
    case accessGrantRejected

    case discoveryStartedByApp
    case discoveryStarted
    case discoveryCancelledbyApp
    case discoveryStopped
    case discoverySuccessful
    case discoveryFailed
    case discoveryDisconnected
    case discoveryLost

    case connectionStartedByApp
    case connectionStarted
    case connectionEstablished
    case connectionFailed
    case connectionCancelledByApp
    case connectionDisconnected

    case doorsLockRequested
    case doorsLocked
    case doorsLockFailed
    case doorsUnlockRequested
    case doorsUnlocked
    case doorsUnlockFailed

    case engineEnableRequested
    case engineEnabled
    case engineEnableFailed
    case engineDisableRequested
    case engineDisabled
    case engineDisableFailed

    case doorsStatusRequested
    case doorsStatusReceived
    case doorsStatusFailed
    case engineStatusRequested
    case engineStatusReceived
    case engineStatusFailed

    case telematicsRequested
    case telematicsReceived
    case telematicsRequestFailed

    case locationRequested
    case locationReceived
    case locationRequestFailed

    case keyholderStatusRequested
    case keyholderStatusReceived
    case keyholderStatusFailed

    var group: String {
        switch self {
        case .interfaceInitialized,
             .accessGrantAccepted,
             .accessGrantRejected:
            return "Setup"
        case .discoveryStartedByApp,
             .discoveryStarted,
             .discoveryCancelledbyApp,
             .discoveryStopped,
             .discoverySuccessful,
             .discoveryDisconnected,
             .discoveryFailed,
             .discoveryLost:
            return "Discovery"
        case .connectionStartedByApp,
             .connectionStarted,
             .connectionEstablished,
             .connectionFailed,
             .connectionCancelledByApp,
             .connectionDisconnected:
            return "Connection"
        case .doorsLockRequested,
             .doorsLocked,
             .doorsLockFailed,
             .doorsUnlockRequested,
             .doorsUnlocked,
             .doorsUnlockFailed,
             .engineEnableRequested,
             .engineEnabled,
             .engineEnableFailed,
             .engineDisableRequested,
             .engineDisabled,
             .engineDisableFailed,
             .doorsStatusRequested,
             .doorsStatusReceived,
             .doorsStatusFailed,
             .engineStatusRequested,
             .engineStatusReceived,
             .engineStatusFailed:
            return "VehicleAccess"
        case .telematicsRequested,
             .telematicsReceived,
             .telematicsRequestFailed:
            return "Telematics"
        case .locationReceived,
             .locationRequested,
             .locationRequestFailed:
            return "Location"
        case .keyholderStatusRequested,
             .keyholderStatusReceived,
             .keyholderStatusFailed:
            return "Keyholder"
        }
    }

    var message: String {
        switch self {
        case .discoveryStartedByApp:
            return "Discovery was started by App"
        case .discoveryStarted:
            return "Discovery was started"
        case .discoveryCancelledbyApp:
            return "Discovery was cancelled by App"
        case .discoveryStopped:
            return "Discovery was stopped"
        case .discoverySuccessful:
            return "Discovery was successful"
        case .discoveryFailed:
            return "Failure in discovering"
        case .discoveryLost:
            return "Discovery was lost"
        case .discoveryDisconnected:
            return "Discovery was disconnected"
        case .connectionStartedByApp:
            return "Connection requested by App"
        case .connectionStarted:
            return "Connection requested"
        case .connectionEstablished:
            return "Connection is established"
        case .connectionFailed:
            return "Failure in connecting"
        case .connectionCancelledByApp:
            return "Connection is cancelled by App"
        case .connectionDisconnected:
            return "Connection is disconnected"
        case .doorsLockRequested:
            return "Door lock was requested"
        case .doorsLocked:
            return "Door is locked"
        case .doorsLockFailed:
            return "Failure in locking door"
        case .doorsUnlockRequested:
            return "Door unlock was requested"
        case .doorsUnlocked:
            return "Door is unlocked"
        case .doorsUnlockFailed:
            return "Failure in unlocking door"
        case .engineEnableRequested:
            return "Engine enable was requested"
        case .engineEnabled:
            return "Engine is enabled"
        case .engineEnableFailed:
            return "Failure in engine enabling"
        case .engineDisableRequested:
            return "Engine disable was requested"
        case .engineDisabled:
            return "Engine is disabled"
        case .engineDisableFailed:
            return "Failure in engine disabling"
        case .doorsStatusRequested:
            return "Door status is requested"
        case .doorsStatusReceived:
            return "Door status is recieved"
        case .doorsStatusFailed:
            return "Failure in fetching Door status"
        case .engineStatusRequested:
            return "Engine status is requested"
        case .engineStatusReceived:
            return "Engine status is recieved"
        case .engineStatusFailed:
            return "Failure in fetching Engine status"
        case .telematicsRequested:
            return "Telematics data is requested"
        case .telematicsReceived:
            return "Telematics data is recieved"
        case .telematicsRequestFailed:
            return "Failure in fetching telematics data"
        case .locationRequested:
            return "Location data is requested"
        case .locationReceived:
            return "Location data is recieved"
        case .locationRequestFailed:
            return "Failure in fetching location data"
        case .keyholderStatusRequested:
            return "Keyholder status is requested"
        case .keyholderStatusReceived:
            return "Keyholder status is recieved"
        case .keyholderStatusFailed:
            return "Failure in fetching keyholder status"
        case .interfaceInitialized:
            return "Interface initialized"
        case .accessGrantAccepted:
            return "Access grant is accepted"
        case .accessGrantRejected:
            return "Access grant is rejected"
        }
    }

    var defaultParameters: [String: Any] {
        return [
            ParameterKey.group.rawValue: group,
            ParameterKey.message.rawValue: message
        ]
    }
}
