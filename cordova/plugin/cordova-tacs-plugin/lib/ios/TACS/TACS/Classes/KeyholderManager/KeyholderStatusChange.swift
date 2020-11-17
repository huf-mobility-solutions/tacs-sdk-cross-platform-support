// KeyholderStatusChange.swift
// TACS

// Created on 21.05.19.
// Copyright © 2019 Huf Secure Mobile. All rights reserved.

import Foundation
import SecureAccessBLE

/// A change that describes keyholder status
public struct KeyholderStatusChange: ChangeType, Equatable {
    /// :nodoc:
    public static func initialWithState(_ state: KeyholderStatusChange.State) -> KeyholderStatusChange {
        return KeyholderStatusChange(state: state, action: .initial)
    }

    /// State in which the change currently is
    public let state: State

    /// Action which led to current state
    public let action: Action
}

extension KeyholderStatusChange {
    /// Action of keyholder change
    public enum Action: Equatable {
        /// Initial action
        case initial
        /// Action notifying that discovery has started
        case discoveryStarted
        /// Action notifying that keyholder was discovered with associated keyholder info
        case discovered(KeyholderInfo)
        /// Action notifying that an error occured
        case failed(KeyholderStatusError)
    }

    /// State a change can be in
    public enum State: Equatable {
        /// Searching for keyholder
        case searching
        /// Not searching for keyholder
        case stopped
    }
}

/// Error in retrieving keyholder status
public enum KeyholderStatusError: Equatable {
    /// Bluetooth interface is not available. This can have various reasons like unauthorized or disabled by user
    case bluetoothOff
    /// Keyholder id is missing. This can occure if the keyring was not set on `TacsManager` or
    /// if the selected key does not contain a keyholder id which is e.g. the case for passive start vehicles
    case keyholderIdMissing
    /// Keyholder could not be discovered due to time out
    case scanTimeout
}
