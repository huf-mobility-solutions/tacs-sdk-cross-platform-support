// DiscoveryChange.swift
// TACS

// Created on 02.05.19.
// Copyright © 2019 Huf Secure Mobile. All rights reserved.

import Foundation
import SecureAccessBLE

struct SorcToVehicleRefMapFailed: Error {}

/// Change of discovery
public struct DiscoveryChange: ChangeType, Equatable {
    /// The state a `DiscoveryChange` can be in
    public let state: State

    /// The action which led to the state change
    public let action: Action

    /// :nodoc:
    public static func initialWithState(_ state: State) -> DiscoveryChange {
        return DiscoveryChange(state: state, action: .initial)
    }

    /// :nodoc:
    public init(state: State, action: Action) {
        self.state = state
        self.action = action
    }

    init(from change: SecureAccessBLE.DiscoveryChange, sorcToVehicleRefMap: SorcToVehicleRefMap) throws {
        let state = State(from: change.state, sorcToVehicleRefMap: sorcToVehicleRefMap)
        let action = try Action(from: change.action, sorcToVehicleRefMap: sorcToVehicleRefMap)
        self.init(state: state, action: action)
    }
}

extension DiscoveryChange {
    /// The state a `DiscoveryChange` can be in
    public struct State: Equatable {
        /// A list of currently discovered Vehicle Infos
        public let discoveredVehicles: VehicleInfos

        public init(discoveredVehicles: VehicleInfos) {
            self.discoveredVehicles = discoveredVehicles
        }

        init(from state: SecureAccessBLE.DiscoveryChange.State, sorcToVehicleRefMap: SorcToVehicleRefMap) {
            let vehicleInfos = VehicleInfos(from: state.discoveredSorcs, sorcToVehicleRefMap: sorcToVehicleRefMap)
            self.init(discoveredVehicles: vehicleInfos)
        }
    }
}

extension DiscoveryChange {
    /// An action which led to a discovery change
    public enum Action: Equatable {
        /// Initial action (sent automatically on `subscribe`)
        case initial

        /// Discovery for specific VehicleRef started
        case discoveryStarted(vehicleRef: VehicleRef)

        /// The vehicle was discovered
        case discovered(vehicleRef: VehicleRef)

        /// The vehicle was discovered again or its info changed.
        ///
        /// Note: Can produce a lot of updates as a result of RSSI changes.
        /// Consider filtering this action out if you don't need it.
        case rediscovered(vehicleRef: VehicleRef)

        /// Discovered vehicles were not discovered recently and hence considered lost
        /// - warning: Deprecated. Will only be notified if `startScanning()` was executed.
        /// Instead, use `startScanningWithTimeout(_:)` which will stop discovery
        /// as soon as the vehicle is found.
        @available(*, deprecated, message: """
        Will only be notified if `startScanning()` was executed.
        Instead, use `startScanningWithTimeout(_:)` which will
        stop discovery as soon as the vehicle is found.
        """)
        case lost(vehicleRefs: Set<VehicleRef>)

        /// Discovery failed. Happens if the discovery couldn't successfully finish before timeout.
        case discoveryFailed

        /// The disconnect was triggered manually
        case disconnect(vehicleRef: VehicleRef)

        /// The vehicle was disconnected or disconnected on its own
        case disconnected(vehicleRef: VehicleRef)

        /// Discovered vehicles were cleared
        case reset

        /// Discovery started
        /// Will be executed if the discovery was started without specific timeout.
        /// Won't be used if scanning was started with timeout.
        ///
        /// - warning: Deprecated. Will only be notified if `startScanning()` was executed.
        /// If  `startScanningWithTimeout(_:)`  is used,
        /// then `discoveryStarted(vehicleRef: VehicleRef)` action will be notified.
        @available(*, deprecated, message: """
        Will only be notified if `startScanning()` was executed.
        If `startScanningWithTimeout(_:)` is used,
        then `discoveryStarted(vehicleRef: VehicleRef)` action will be notified.
        """)
        case startDiscovery

        /// Discovery stopped
        case stopDiscovery

        /// Discovery could not be started due to missing data in key ring
        case missingBlobData

        // swiftlint:disable:next cyclomatic_complexity
        init(from action: SecureAccessBLE.DiscoveryChange.Action, sorcToVehicleRefMap: SorcToVehicleRefMap) throws {
            switch action {
            case .initial:
                self = .initial
            case let .discoveryStarted(sorcID: sorcID):
                guard let vehicleRef = sorcToVehicleRefMap[sorcID] else { throw SorcToVehicleRefMapFailed() }
                self = .discoveryStarted(vehicleRef: vehicleRef)
            case let .discovered(sorcID):
                guard let vehicleRef = sorcToVehicleRefMap[sorcID] else { throw SorcToVehicleRefMapFailed() }
                self = .discovered(vehicleRef: vehicleRef)
            case let .rediscovered(sorcID):
                guard let vehicleRef = sorcToVehicleRefMap[sorcID] else { throw SorcToVehicleRefMapFailed() }
                self = .rediscovered(vehicleRef: vehicleRef)
            case let .lost(sorcIDs):
                var vehicleRefs = Set<VehicleRef>()
                for sorcID in sorcIDs {
                    guard let vehicleRef = sorcToVehicleRefMap[sorcID] else { throw SorcToVehicleRefMapFailed() }
                    vehicleRefs.insert(vehicleRef)
                }
                self = .lost(vehicleRefs: vehicleRefs)
            case .discoveryFailed:
                self = .discoveryFailed
            case let .disconnect(sorcID):
                guard let vehicleRef = sorcToVehicleRefMap[sorcID] else { throw SorcToVehicleRefMapFailed() }
                self = .disconnect(vehicleRef: vehicleRef)
            case let .disconnected(sorcID):
                guard let vehicleRef = sorcToVehicleRefMap[sorcID] else { throw SorcToVehicleRefMapFailed() }
                self = .disconnected(vehicleRef: vehicleRef)
            case .reset:
                self = .reset
            case .startDiscovery:
                self = .startDiscovery
            case .stopDiscovery:
                self = .stopDiscovery
            }
        }
    }
}

/// Container for information related to a SORC
public struct VehicleInfo: Equatable {
    /// The ID of the vehicle reference
    public let vehicleRef: VehicleRef

    /// The date on which the vehicle was discovered
    public let discoveryDate: Date

    /// The received signal strength indicator
    public let rssi: Int

    /// :nodoc:
    public init(vehicleRef: VehicleRef, discoveryDate: Date, rssi: Int) {
        self.vehicleRef = vehicleRef
        self.discoveryDate = discoveryDate
        self.rssi = rssi
    }
}

/// Container for Vehicle infos
public struct VehicleInfos: Equatable {
    private var vehicleInfoByID: [VehicleRef: VehicleInfo]

    /// All vehicle refs in the container
    public var vehicleRefs: [VehicleRef] {
        return Array(vehicleInfoByID.keys)
    }

    /// Returns `true` if the container is empty
    public var isEmpty: Bool {
        return vehicleInfoByID.isEmpty
    }

    /// Checks if the container has the provided vehicle reference
    ///
    /// - Parameter vehicleRef: vehicle reference id
    /// - Returns: `true` if provided `VehicleRef` is contained
    public func contains(_ vehicleRef: VehicleRef) -> Bool {
        return vehicleInfoByID.keys.contains(vehicleRef)
    }

    /// Subscript operator to get `VehicleInfo` for given `VehicleRef`
    ///
    /// - Parameter vehicleRef: The vehicle reference
    /// - Returns: `VehicleInfo` if found
    public subscript(vehicleRef: VehicleRef) -> VehicleInfo? {
        get {
            return vehicleInfoByID[vehicleRef]
        }
        set {
            vehicleInfoByID[vehicleRef] = newValue
        }
    }

    /// :nodoc:
    public init(_ vehicleInfoByID: [VehicleRef: VehicleInfo] = [:]) {
        self.vehicleInfoByID = vehicleInfoByID
    }

    init(from sorcInfos: SorcInfos, sorcToVehicleRefMap: SorcToVehicleRefMap) {
        var vehicleInfoById: [VehicleRef: VehicleInfo] = [:]
        for sorcID in sorcInfos.sorcIDs {
            if let vehicleRef = sorcToVehicleRefMap[sorcID], let sorcInfo = sorcInfos[sorcID] {
                vehicleInfoById[vehicleRef] = VehicleInfo(vehicleRef: vehicleRef, discoveryDate: sorcInfo.discoveryDate, rssi: sorcInfo.rssi)
            }
        }
        self.init(vehicleInfoById)
    }
}
