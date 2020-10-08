//
//  LocationManager.swift
//  TACS
//
//  Created on 24.10.19.
//  Copyright © 2019 Huf Secure Mobile GmbH. All rights reserved.
//

import Foundation
import SecureAccessBLE

internal class LocationManager: LocationManagerType {
    private let sorcManager: SorcManagerType
    private let locationDataChangeSubject: ChangeSubject<LocationDataChange> = ChangeSubject<LocationDataChange>(state: false)
    internal static let locationServiceGrantID: UInt16 = 0x0A

    /// Location data change signal which can be used to retrieve data changes
    internal var locationDataChange: ChangeSignal<LocationDataChange> {
        return locationDataChangeSubject.asSignal()
    }

    internal var trackingParametersProvider: TACSManager.DefaultTrackingParametersProvider?

    /// Requests location data from the vehicle
    internal func requestLocationData() {
        HSMTrack(.locationRequested, parameters: trackingParametersProvider?() ?? [:], loglevel: .info)

        guard case SecureAccessBLE.ConnectionChange.State.connected = sorcManager.connectionChange.state else {
            notifyNotConnectedChange()
            return
        }
        sorcManager.requestServiceGrant(LocationManager.locationServiceGrantID)
    }

    init(sorcManager: SorcManagerType) {
        self.sorcManager = sorcManager
    }

    private func notifyNotConnectedChange() {
        let locationResponse = LocationDataResponse.error(.notConnected)
        let action = LocationDataChange.Action.responseReceived(response: locationResponse)
        let change = LocationDataChange(state: false, action: action)
        locationDataChangeSubject.onNext(change)
    }

    private func notifyRemoteFailedChange() {
        let locationResponse = LocationDataResponse.error(.remoteFailed)
        let action = LocationDataChange.Action.responseReceived(response: locationResponse)
        let change = LocationDataChange(state: false, action: action)
        locationDataChangeSubject.onNext(change)
    }

    private func notifyRemoteNotSupportedChange() {
        let locationResponse = LocationDataResponse.error(.notSupported)
        let action = LocationDataChange.Action.responseReceived(response: locationResponse)
        let change = LocationDataChange(state: false, action: action)
        locationDataChangeSubject.onNext(change)
    }

    private func notifyRequestingChange(_ accepted: Bool, state: Bool) {
        let change: LocationDataChange
        if accepted {
            change = LocationDataChange(state: state, action: .requestingData(accepted: accepted))
        } else {
            change = LocationDataChange(state: state, action: .requestingData(accepted: accepted))
        }
        locationDataChangeSubject.onNext(change)
    }

    private func notifyRequestDeniedChange() {
        let locationResponse = LocationDataResponse.error(.denied)
        let action = LocationDataChange.Action.responseReceived(response: locationResponse)
        let change = LocationDataChange(state: false, action: action)
        locationDataChangeSubject.onNext(change)
    }

    private func notifyResponseReceived(with locationData: LocationData) {
        let locationResponse = LocationDataResponse(locationData)
        let change = LocationDataChange(state: false, action: .responseReceived(response: locationResponse))
        locationDataChangeSubject.onNext(change)
    }

    private func onResponseReceived(_ response: ServiceGrantResponse) {
        switch response.status {
        case .success:
            guard let locationData = try? LocationData(responseData: response.responseData) else {
                notifyRemoteNotSupportedChange()
                return
            }
            notifyResponseReceived(with: locationData)
        case .pending:
            break
        case .failure:
            notifyRemoteFailedChange()
        case .invalidTimeFrame, .notAllowed:
            notifyRequestDeniedChange()
        }
    }

    // SorcInterceptor conformance
    public func consume(change: ServiceGrantChange) -> ServiceGrantChange? {
        switch change.action {
        case .initial:
            return nil
        case let .requestServiceGrant(id: serviceGrantId, accepted: accepted):
            if serviceGrantId == LocationManager.locationServiceGrantID {
                notifyRequestingChange(accepted, state: change.state.requestingServiceGrantIDs.contains(LocationManager.locationServiceGrantID))
                return nil
            } else {
                return change.withoutLocationID()
            }
        case let .responseReceived(response):
            if response.serviceGrantID == LocationManager.locationServiceGrantID {
                onResponseReceived(response)
                return nil
            } else {
                return change.withoutLocationID()
            }
        case .requestFailed:
            if locationDataChangeSubject.state {
                notifyRemoteFailedChange()
                return nil
            }
            return change.withoutLocationID()
        case .reset: // happens on disconnect
            return change.withoutLocationID()
        }
    }
}

private extension ServiceGrantChange {
    func withoutLocationID() -> ServiceGrantChange {
        if !state.requestingServiceGrantIDs.contains(LocationManager.locationServiceGrantID) {
            return self
        } else {
            let filteredIDs = state.requestingServiceGrantIDs.filter { $0 != LocationManager.locationServiceGrantID }
            let newState = State(requestingServiceGrantIDs: filteredIDs)
            return ServiceGrantChange(state: newState, action: action)
        }
    }
}
