//
//  TACSTrackingManager.swift
//  TACS
//
//  Created on 07.02.20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import SecureAccessBLE

public protocol TACSEventTracker {
    func trackEvent(_ event: String, parameters: [String: Any], loglevel: LogLevel)
}

internal enum ParameterKey: String {
    // default parameters, present in every event
    case group
    case message
    case timestamp

    // additional data
    case sorcID
    case sorcIDs
    case vehicleRef
    case keyholderID
    case accessGrantID
    case leaseTokenID
    case error
    case timeout

    // generic payload data
    case data

    // system data
    case secureAccessFrameworkVersion
    case TACSFrameworkVersion
    case phoneModel
    case osVersion
    case os
}

public class TACSTrackingManager {
    class SATracker: SAEventTracker {
        typealias EventCallBack = (_: String, _: [String: Any], _: LogLevel) -> Void
        var onEvent: EventCallBack?

        func trackEvent(_ event: String, parameters: [String: Any], loglevel: LogLevel) {
            onEvent?(event, parameters, loglevel)
        }
    }

    private var tracker: TACSEventTracker?

    private var logLevel: LogLevel = .info
    private let systemClock: SystemClockType
    /// Static (singleton) instance of the `TACSTrackingManager`
    public static var shared = TACSTrackingManager()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private var systemParameters: [String: Any] = [
        ParameterKey.os.rawValue: UIDevice.current.systemName,
        ParameterKey.osVersion.rawValue: UIDevice.current.systemVersion,
        ParameterKey.phoneModel.rawValue: UIDevice.current.name,
        ParameterKey.TACSFrameworkVersion.rawValue:
            Bundle(for: TACSTrackingManager.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown",
        ParameterKey.secureAccessFrameworkVersion.rawValue:
            Bundle(for: SorcManager.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    ]

    /// :nodoc:
    /// Usually, the SecureAccess tracker is used in a silent mode where it only reports events which can not be tracked by TACS.
    /// This is done to avoid redundant events. However, if more logging is required, this flag can be enabled.
    public var trackSecureAccess = false {
        didSet {
            SATrackingManager.shared.usedByTACSSDK = !trackSecureAccess
        }
    }

    /// Registers tracker which will be used to pass events.
    /// - Parameters:
    ///   - tracker: the tracker
    ///   - logLevel: log level which can be used to filter events
    public func registerTracker(_ tracker: TACSEventTracker, logLevel: LogLevel) {
        self.tracker = tracker
        self.logLevel = logLevel
        let saTracker = SATracker()
        saTracker.onEvent = sendEvent(event:parameters:loglevel:)
        SATrackingManager.shared.registerTracker(saTracker, logLevel: logLevel)
        SATrackingManager.shared.usedByTACSSDK = !trackSecureAccess
    }

    internal init(systemClock: SystemClockType = SystemClock()) {
        self.systemClock = systemClock
    }

    internal func track(_ event: TrackingEvent, parameters: [String: Any] = [:], loglevel: LogLevel) {
        if loglevel.rawValue <= logLevel.rawValue {
            // Prefer default parameter, in case the caller wants to overwrite it (e.g. group or message)
            var trackingParameters = event.defaultParameters.merging(parameters) { (defaultParameters, _) -> Any in
                defaultParameters
            }
            if event == .interfaceInitialized {
                // Prefer system parameter to not allow overwriting them
                trackingParameters.merge(systemParameters) { (_, systemParameters) -> Any in
                    systemParameters
                }
            }
            trackingParameters[ParameterKey.timestamp.rawValue] = dateFormatter.string(from: systemClock.now())

            sendEvent(event: String(describing: event), parameters: trackingParameters, loglevel: loglevel)
        }
    }

    private func sendEvent(event: String, parameters: [String: Any], loglevel: LogLevel) {
        tracker?.trackEvent(event, parameters: parameters, loglevel: loglevel)
    }
}

internal func HSMTrack(_ event: TrackingEvent, parameters: [String: Any] = [:], loglevel: LogLevel) {
    TACSTrackingManager.shared.track(event, parameters: parameters, loglevel: loglevel)
}
