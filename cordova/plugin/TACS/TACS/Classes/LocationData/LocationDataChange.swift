//
//  LocationDataChange.swift
//  TACS
//
//  Created on 28.10.19.
//  Copyright © 2019 Huf Secure Mobile GmbH. All rights reserved.
//

import Foundation
import SecureAccessBLE

/// Describes the Location data change
public struct LocationDataChange: ChangeType {
    /// State which represents if a location request is pending or not
    public let state: State

    /// Action which led to change
    public let action: Action

    public typealias State = Bool

    public static func initialWithState(_: Bool) -> LocationDataChange {
        return LocationDataChange(state: false, action: .initial)
    }
}

extension LocationDataChange {
    /// Action which can lead to a change
    public enum Action: Equatable {
        /// Initial action
        case initial
        /// Action notifying that data is being requested
        case requestingData(accepted: Bool)
        /// Action notifying that response was received
        case responseReceived(response: LocationDataResponse)
    }
}

extension LocationDataChange: Equatable {}
