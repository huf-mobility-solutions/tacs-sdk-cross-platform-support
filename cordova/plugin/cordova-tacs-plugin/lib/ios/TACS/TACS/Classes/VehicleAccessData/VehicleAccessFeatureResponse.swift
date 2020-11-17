// VehicleAccessFeatureResponse.swift
// TACS

// Created on 25.04.19.
// Copyright © 2019 Huf Secure Mobile. All rights reserved.

import SecureAccessBLE

/// Response which can be retrieved from `VehicleAccessManager` via signal change.
public enum VehicleAccessFeatureResponse: Equatable {
    /// Success response containing `VehicleAccessFeatureStatus`
    case success(status: VehicleAccessFeatureStatus)
    /// Failure state for a requested `VehicleAccessFeature` with `VehicleAccessFeatureError` which led to failure
    case failure(feature: VehicleAccessFeature, error: VehicleAccessFeatureError)
    internal init?(feature: VehicleAccessFeature, response: ServiceGrantResponse) {
        guard response.responseData != FeatureResult.keyDestroyed.rawValue else {
            self = .failure(feature: feature, error: .keyDestroyed)
            return
        }
        switch response.status {
        case .invalidTimeFrame:
            self = .failure(feature: feature, error: .denied)
        case .failure, .notAllowed:
            self = .failure(feature: feature, error: .remoteFailed)
        case .success:
            if let featureStatus = VehicleAccessFeatureStatus(feature: feature, serviceGrantResponseData: response.responseData) {
                self = .success(status: featureStatus)
            } else {
                self = .failure(feature: feature, error: .remoteFailed)
            }
        case .pending:
            return nil
        }
    }
}

/// Status of a feature which is retrieved in a `.success` case of `VehicleAccessFeatureResponse`
public enum VehicleAccessFeatureStatus: Equatable {
    /// Lock doors command was accepted
    case lock
    /// Unlock doors command was accepted
    case unlock
    /// Enable ignition command was accepted
    case enableIgnition
    /// Disable ignition comand was accepted
    case disableIgnition
    /// Lock status was retrieved
    case lockStatus(locked: Bool)
    /// Ignition status was retrieved
    case ignitionStatus(enabled: Bool)

    // swiftlint:disable:next cyclomatic_complexity
    init?(feature: VehicleAccessFeature, serviceGrantResponseData: String) {
        switch feature {
        case .lock:
            self = .lock
        case .unlock:
            self = .unlock
        case .enableIgnition:
            self = .enableIgnition
        case .disableIgnition:
            self = .disableIgnition
        case .lockStatus:
            let featureResult = FeatureResult(responseData: serviceGrantResponseData)
            switch featureResult {
            case .locked:
                self = .lockStatus(locked: true)
            case .unlocked:
                self = .lockStatus(locked: false)
            default:
                return nil
            }
        case .ignitionStatus:
            let featureResult = FeatureResult(responseData: serviceGrantResponseData)
            switch featureResult {
            case .enabled:
                self = .ignitionStatus(enabled: true)
            case .disabled:
                self = .ignitionStatus(enabled: false)
            default:
                return nil
            }
        }
    }
}

/// Error which led to `.failure` case of `VehicleAccessFeatureResponse`
public enum VehicleAccessFeatureError {
    /// Query failed, because the vehicle is not connected
    case notConnected
    /// Query failed, because the lease does not permit access to telematics data
    case denied
    /// Query failed, because the remote CAM encountered an internal error
    case remoteFailed
    /// Query failed, because the key was destroyed
    case keyDestroyed
}

private enum FeatureResult: String {
    // key was destroyed
    case keyDestroyed = "KEY_DESTROYED"
    // door was locked
    case locked = "LOCKED"
    // door was unlocked
    case unlocked = "UNLOCKED"
    // ignition enabled
    case enabled = "ENABLED"
    // ignition disabled
    case disabled = "DISABLED"
    // unknown result
    case unknown = "UNKNOWN"

    init(responseData: String) {
        guard !responseData.isEmpty, let result = FeatureResult(rawValue: responseData) else {
            self = .unknown
            return
        }
        self = result
    }
}
