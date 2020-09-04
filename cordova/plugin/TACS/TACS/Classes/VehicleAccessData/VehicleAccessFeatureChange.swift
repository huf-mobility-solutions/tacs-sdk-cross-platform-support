// VehicleAccessFeatureChange.swift
// TACS

// Created on 25.04.19.
// Copyright © 2019 Huf Secure Mobile. All rights reserved.

import Foundation
import SecureAccessBLE

/// Describes vehicle access feature change
public struct VehicleAccessFeatureChange: ChangeType {
    /// Array of `VehicleAccessFeature`s which are currently being requested
    public var state: State
    /// Action which led to state
    public var action: Action

    /// :nodoc:
    public static func initialWithState(_ state: [VehicleAccessFeature]) -> VehicleAccessFeatureChange {
        return VehicleAccessFeatureChange(state: state, action: .initial)
    }

    /// Array of `VehicleAccessFeature`s which are currently being requested
    public typealias State = [VehicleAccessFeature]
}

extension VehicleAccessFeatureChange {
    /// Action which led to a change
    public enum Action: Equatable {
        /// Initial action
        case initial
        /// Emitted if a feature request for a `VehicleAccessFeature` is sent.
        /// Accepted describes if a request was accepted or not.
        /// The request is not accepted if too many requests are enqueued simultaneously.
        case requestFeature(feature: VehicleAccessFeature, accepted: Bool)
        /// Response received with associated `VehicleAccessFeatureResponse`
        case responseReceived(response: VehicleAccessFeatureResponse)
    }
}

extension VehicleAccessFeatureChange: Equatable {}
