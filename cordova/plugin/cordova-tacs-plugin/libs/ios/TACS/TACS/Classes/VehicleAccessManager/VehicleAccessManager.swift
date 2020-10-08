// VehileAccessManager.swift
// TACS

// Created on 23.04.19.
// Copyright © 2019 Huf Secure Mobile. All rights reserved.

import SecureAccessBLE

/// Manager for vehicle access control. Retrieve an instance of the manager via `vehicleAccessManager` property of  `TACSManager`
public class VehicleAccessManager: VehicleAccessManagerType {
    private let sorcManager: SorcManagerType
    private let queue: DispatchQueue
    private let vehicleAccessChangeSubject = ChangeSubject<VehicleAccessFeatureChange>(state: [])
    /// Vehicle access feature change which can be used to retrieve vehicle access feature changes.

    public var vehicleAccessChange: ChangeSignal<VehicleAccessFeatureChange> {
        return vehicleAccessChangeSubject.asSignal()
    }

    internal var trackingParametersProvider: TACSManager.DefaultTrackingParametersProvider?

    fileprivate var featuresWaitingForAck: [VehicleAccessFeature] = []
    init(sorcManager: SorcManagerType, queue: DispatchQueue) {
        self.sorcManager = sorcManager
        self.queue = queue
    }

    /// Requests a feature from vehicle.
    ///
    /// - Parameter vehicleAccessFeature: Feature which has to be requested.
    public func requestFeature(_ vehicleAccessFeature: VehicleAccessFeature) {
        queue.async { [weak self] in
            self?.requestFeatureInternal(vehicleAccessFeature)
        }
    }

    func requestFeatureInternal(_ vehicleAccessFeature: VehicleAccessFeature) {
        featuresWaitingForAck.append(vehicleAccessFeature)
        trackVehicleAccessRequested(for: vehicleAccessFeature, defaultParameters: trackingParametersProvider?() ?? [:])
        sorcManager.requestServiceGrant(vehicleAccessFeature.serviceGrantID())
    }
}

extension VehicleAccessManager: SorcInterceptor {
    // SorcInterceptor conformance
    /// :nodoc:
    public func consume(change: ServiceGrantChange) -> ServiceGrantChange? {
        let result: ServiceGrantChange?
        switch change.action {
        case .initial:
            result = nil
        case let .requestServiceGrant(id: serviceGrant, accepted: accepted):
            result = consumeRequestServiceGrantChange(change, serviceGrant: serviceGrant, accepted: accepted)
        case let .responseReceived(response):
            result = consumeResponseReceivedChange(change, response: response)
        case let .requestFailed(error):
            notifyRequestFailedChangeIfNeeded(error)
            result = changeWithoutRequestedGrants(from: change)
        case .reset: // happens on disconnect
            result = changeWithoutRequestedGrants(from: change)
        }
        return result
    }

    private func changeWithoutRequestedGrants(from change: ServiceGrantChange) -> ServiceGrantChange {
        return change.withoutGrantIDs(vehicleAccessChangeSubject.state.map { $0.serviceGrantID() })
    }

    private func notifyRequestFailedChangeIfNeeded(_ error: ServiceGrantChange.Error) {
        func notifyChange(feature: VehicleAccessFeature, error: VehicleAccessFeatureError) {
            featuresWaitingForAck.removeAll()
            let response = VehicleAccessFeatureResponse.failure(feature: feature, error: error)
            let action = VehicleAccessFeatureChange.Action.responseReceived(response: response)
            let remoteFailedChange = VehicleAccessFeatureChange(state: [], action: action)
            vehicleAccessChangeSubject.onNext(remoteFailedChange)
        }

        if error == .notConnected, let lastRequestedFeature = featuresWaitingForAck.last {
            notifyChange(feature: lastRequestedFeature, error: .notConnected)
        } else if let lastRequestedFeature = vehicleAccessChangeSubject.state.last {
            notifyChange(feature: lastRequestedFeature, error: .remoteFailed)
        }
    }

    private func consumeRequestServiceGrantChange(_ change: ServiceGrantChange,
                                                  serviceGrant: ServiceGrantID,
                                                  accepted: Bool) -> ServiceGrantChange? {
        guard let feature = VehicleAccessFeature(serviceGrantID: serviceGrant) else {
            return changeWithoutRequestedGrants(from: change)
        }
        if let index = featuresWaitingForAck.firstIndex(of: feature) {
            featuresWaitingForAck.remove(at: index)
            var newState = vehicleAccessChange.state
            if accepted {
                newState.append(feature)
            }
            let action: VehicleAccessFeatureChange.Action =
                .requestFeature(feature: feature, accepted: accepted)
            vehicleAccessChangeSubject.onNext(VehicleAccessFeatureChange(state: newState, action: action))
            return nil
        } else {
            return change
        }
    }

    private func consumeResponseReceivedChange(_ change: ServiceGrantChange,
                                               response: ServiceGrantResponse) -> ServiceGrantChange? {
        guard let feature = VehicleAccessFeature(serviceGrantID: response.serviceGrantID) else {
            return changeWithoutRequestedGrants(from: change)
        }
        // ensure we are waiting for response for this feature, otherwise don't consume
        guard vehicleAccessChangeSubject.state.contains(feature) else {
            return changeWithoutRequestedGrants(from: change)
        }

        var stateWithoutReceivedFeature = vehicleAccessChangeSubject.state
        if let index = vehicleAccessChangeSubject.state.firstIndex(of: feature) {
            stateWithoutReceivedFeature.remove(at: index)
        }
        if let response = VehicleAccessFeatureResponse(feature: feature, response: response) {
            let featureChange = VehicleAccessFeatureChange(state: stateWithoutReceivedFeature, action: .responseReceived(response: response))
            vehicleAccessChangeSubject.onNext(featureChange)
        }
        return nil
    }
}

private extension ServiceGrantChange {
    func withoutGrantIDs(_ serviceGrantIDs: [ServiceGrantID]) -> ServiceGrantChange {
        let filteredIDs = state.requestingServiceGrantIDs.filter { !serviceGrantIDs.contains($0) }
        let newState = State(requestingServiceGrantIDs: filteredIDs)
        return ServiceGrantChange(state: newState, action: action)
    }
}

protocol SystemClockType {
    func now() -> Date

    func timeIntervalSinceNow(for date: Date) -> TimeInterval
}

class SystemClock: SystemClockType {
    func now() -> Date {
        return Date()
    }

    func timeIntervalSinceNow(for date: Date) -> TimeInterval {
        return date.timeIntervalSinceNow
    }
}
