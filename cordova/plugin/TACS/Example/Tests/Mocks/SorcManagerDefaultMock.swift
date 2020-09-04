// SorcManagerMock.swift
// TACSTests

// Created on 25.04.19.
// Copyright © 2019 Huf Secure Mobile. All rights reserved.

import SecureAccessBLE

class SorcManagerDefaultMock: SorcManagerType {
    var bluetoothStateSubject = BehaviorSubject<BluetoothState>(value: .poweredOn)
    var bluetoothState: StateSignal<BluetoothState> { return bluetoothStateSubject.asSignal() }

    let discoveryChangeSubject = ChangeSubject<DiscoveryChange>(state: .init(
        discoveredSorcs: SorcInfos(),
        discoveryIsEnabled: false
    ))

    var discoveryChange: ChangeSignal<DiscoveryChange> { return discoveryChangeSubject.asSignal() }

    var didReceiveStartDiscovery = 0
    func startDiscovery() {
        didReceiveStartDiscovery += 1
    }

    var timeoutForDiscovery: TimeInterval?
    var didReceiveStartDiscoveryForSpecificSorc = 0
    func startDiscovery(sorcID _: SorcID, timeout: TimeInterval?) {
        didReceiveStartDiscoveryForSpecificSorc += 1
        timeoutForDiscovery = timeout
    }

    func stopDiscovery() {}

    let connectionChangeSubject = ChangeSubject<ConnectionChange>(state: .disconnected)

    var connectionChange: ChangeSignal<ConnectionChange> { return connectionChangeSubject.asSignal() }

    var didReceiveConnectToSorc = 0
    var receivedConnectToSorcLeaseToken: LeaseToken?
    var receivedConnectToSorcLeaseTokenBlob: LeaseTokenBlob?
    func connectToSorc(leaseToken: LeaseToken, leaseTokenBlob: LeaseTokenBlob) {
        didReceiveConnectToSorc += 1
        receivedConnectToSorcLeaseToken = leaseToken
        receivedConnectToSorcLeaseTokenBlob = leaseTokenBlob
    }

    func disconnect() {}

    let serviceGrantChangeSubject = ChangeSubject<ServiceGrantChange>(state: .init(requestingServiceGrantIDs: []))
    var serviceGrantChange: ChangeSignal<ServiceGrantChange> { return serviceGrantChangeSubject.asSignal() }

    var didRequestServiceGrant = 0
    func requestServiceGrant(_: ServiceGrantID) {
        didRequestServiceGrant += 1
    }

    var didReceiveRegisterInterceptor = 0
    var receivedRegisterInterceptorInterceptors: [SorcInterceptor] = []
    func registerInterceptor(_ interceptor: SorcInterceptor) {
        didReceiveRegisterInterceptor += 1
        receivedRegisterInterceptorInterceptors.append(interceptor)
    }

    var mobileBulkChange = ChangeSubject<MobileBulkChange>(state: .init(requestingBulkIDs: [])).asSignal()
    func requestBulk(_: MobileBulk) {}
}
