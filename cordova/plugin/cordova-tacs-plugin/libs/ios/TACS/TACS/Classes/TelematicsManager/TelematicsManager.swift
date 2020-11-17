// TelematicsManager.swift
// SecureAccessBLE

// Created on 26.03.19.
// Copyright © 2019 Huf Secure Mobile GmbH. All rights reserved.

import Foundation
import SecureAccessBLE

/// Telematics manager which can be used to retrieve telematics data from the vehicle
public class TelematicsManager: TelematicsManagerType {
    private let sorcManager: SorcManagerType
    private let queue: DispatchQueue
    private let telematicsDataChangeSubject: ChangeSubject<TelematicsDataChange> = ChangeSubject<TelematicsDataChange>(state: [])
    internal static let telematicsServiceGrantID: UInt16 = 9
    private var requestedTypesWaitingForAck: [TelematicsDataType] = []
    internal let locationManager: LocationManagerType

    internal var trackingParametersProvider: TACSManager.DefaultTrackingParametersProvider?

    /// Telematics data change signal which can be used to retrieve data changes
    public var telematicsDataChange: ChangeSignal<TelematicsDataChange> {
        return telematicsDataChangeSubject.asSignal()
    }

    /// Requests telematics data from the vehicle
    ///
    /// - Parameter types: Data types which need to be retrieved
    public func requestTelematicsData(_ types: [TelematicsDataType]) {
        queue.async { [weak self] in
            self?.requestTelematicsDataInternal(types)
        }
    }

    public func requestLocationData() {
        queue.async { [weak self] in
            self?.requestLocationDataInternal()
        }
    }

    public var locationDataChange: ChangeSignal<LocationDataChange> {
        return locationManager.locationDataChange
    }

    internal func requestLocationDataInternal() {
        locationManager.requestLocationData()
    }

    internal func requestTelematicsDataInternal(_ types: [TelematicsDataType]) {
        var parameters = trackingParametersProvider?() ?? [:]
        let stringTypes = types.map { String(describing: $0) }
        parameters[ParameterKey.data.rawValue] = stringTypes
        HSMTrack(.telematicsRequested, parameters: parameters, loglevel: .info)

        guard case SecureAccessBLE.ConnectionChange.State.connected = sorcManager.connectionChange.state else {
            requestedTypesWaitingForAck.removeAll()
            notifyNotConnectedChange(with: types)
            return
        }
        if telematicsDataChangeSubject.state.count != 0 {
            // In this state, request is already running, so we only notify requesting state with added types
            let combinedTypes = Array(Set(types + telematicsDataChangeSubject.state))
            notifyRequestingChange(with: combinedTypes, accepted: true)
            return
        } else if requestedTypesWaitingForAck.count != 0 {
            // In this state request was sent but not acked yet, so we anly append requested types to wait list
            requestedTypesWaitingForAck.append(contentsOf: types)
            return
        }
        requestedTypesWaitingForAck.append(contentsOf: types)
        sorcManager.requestServiceGrant(TelematicsManager.telematicsServiceGrantID)
    }

    init(sorcManager: SorcManagerType, locationManager: LocationManagerType, queue: DispatchQueue) {
        self.sorcManager = sorcManager
        self.locationManager = locationManager
        self.queue = queue
    }

    private func onResponseReceived(_ response: ServiceGrantResponse) {
        switch response.status {
        case .success:
            guard let tripMetaData = try? TripMetaData(responseData: response.responseData) else {
                notifyRemoteFailedChange()
                return
            }
            notifyResponseReceived(with: tripMetaData)
        case .invalidTimeFrame, .notAllowed:
            notifyRequestDeniedChange()
        case .pending: break
        case .failure:
            notifyRemoteFailedChange()
        }
    }

    private func notifyRequestingChange(with types: [TelematicsDataType], accepted: Bool) {
        let change: TelematicsDataChange
        if accepted {
            change = TelematicsDataChange(state: types, action: .requestingData(types: types, accepted: accepted))
        } else {
            change = TelematicsDataChange(state: [], action: .requestingData(types: [], accepted: accepted))
        }
        telematicsDataChangeSubject.onNext(change)
    }

    private func notifyNotConnectedChange(with types: [TelematicsDataType]) {
        let responses = types.map { TelematicsDataResponse.error($0, .notConnected) }
        let action = TelematicsDataChange.Action.responseReceived(responses: responses)
        let change = TelematicsDataChange(state: [], action: action)
        telematicsDataChangeSubject.onNext(change)
    }

    private func notifyRemoteFailedChange() {
        let telematicsResponses = telematicsDataChangeSubject.state.map {
            TelematicsDataResponse.error($0, .remoteFailed)
        }
        let change = TelematicsDataChange(state: [], action: .responseReceived(responses: telematicsResponses))
        telematicsDataChangeSubject.onNext(change)
    }

    private func notifyResponseReceived(with tripMetaData: TripMetaData) {
        let telematicsResponses = telematicsDataChangeSubject.state.map {
            TelematicsDataResponse(tripMetaData: tripMetaData, requestedType: $0)
        }
        let change = TelematicsDataChange(state: [], action: .responseReceived(responses: telematicsResponses))
        telematicsDataChangeSubject.onNext(change)
    }

    private func notifyRequestDeniedChange() {
        let telematicsResponses = telematicsDataChangeSubject.state.map {
            TelematicsDataResponse.error($0, .denied)
        }
        let change = TelematicsDataChange(state: [], action: .responseReceived(responses: telematicsResponses))
        telematicsDataChangeSubject.onNext(change)
    }

    // SorcInterceptor conformance
    /// :nodoc:
    public func consume(change: ServiceGrantChange) -> ServiceGrantChange? {
        switch change.action {
        case .initial:
            return nil
        case let .requestServiceGrant(id: serviceGrantId, accepted: accepted):
            // TODO: A scenario where a user requested for telematicsServiceGrantId from native Sorcmanager, as a result requestTypesWaitingForAck is empty
            if serviceGrantId == TelematicsManager.telematicsServiceGrantID, !requestedTypesWaitingForAck.isEmpty {
                notifyRequestingChange(with: requestedTypesWaitingForAck, accepted: accepted)
                requestedTypesWaitingForAck.removeAll()
                return nil
            } else {
                return change.withoutTelematicsID()
            }
        case let .responseReceived(response):
            if response.serviceGrantID == TelematicsManager.telematicsServiceGrantID {
                onResponseReceived(response)
                return nil
            } else {
                return change.withoutTelematicsID()
            }
        case .requestFailed:
            if !requestedTypesWaitingForAck.isEmpty || !telematicsDataChangeSubject.state.isEmpty {
                notifyRemoteFailedChange()
            }
            return change.withoutTelematicsID()
        case .reset: // happens on disconnect
            return change.withoutTelematicsID()
        }
    }
}

private extension ServiceGrantChange {
    func withoutTelematicsID() -> ServiceGrantChange {
        if !state.requestingServiceGrantIDs.contains(TelematicsManager.telematicsServiceGrantID) {
            return self
        } else {
            let filteredIDs = state.requestingServiceGrantIDs.filter { $0 != TelematicsManager.telematicsServiceGrantID }
            let newState = State(requestingServiceGrantIDs: filteredIDs)
            return ServiceGrantChange(state: newState, action: action)
        }
    }
}
