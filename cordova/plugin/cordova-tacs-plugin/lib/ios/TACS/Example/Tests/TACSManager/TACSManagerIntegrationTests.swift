// TACSManagerIntegrationTests.swift
// TACSTests

// Created on 26.04.19.
// Copyright © 2019 Huf Secure Mobile. All rights reserved.

import Nimble
import Quick
import SecureAccessBLE
@testable import TACS

class TACSManagerIntegrationTests: QuickSpec {
    class SorcManagerMock: SorcManagerDefaultMock {
        let sorcID = UUID(uuidString: "be2fecaf-734b-4252-8312-59d477200a20")!
        func setConnected(_ connected: Bool) {
            if connected {
                connectionChangeSubject.onNext(ConnectionChange(state: .connected(sorcID: sorcID),
                                                                action: .connectionEstablished(sorcID: sorcID)))
            } else {
                connectionChangeSubject.onNext(ConnectionChange(state: .disconnected, action: .disconnect))
            }
        }
    }

    // swiftlint:disable:next function_body_length
    override func spec() {
        var sorcManagerMock: SorcManagerMock!
        var sut: TACSManager!
        var telematicsDataChanges: [TelematicsDataChange]!
        var vehicleAccessChanges: [VehicleAccessFeatureChange]!
        var locationDataChange: LocationDataChange!
        var queue: DispatchQueue!

        var locationManager: LocationManagerType!

        beforeEach {
            sorcManagerMock = SorcManagerMock()
            queue = DispatchQueue.main
            locationManager = LocationManager(sorcManager: sorcManagerMock)
            let telematicsManager = TelematicsManager(sorcManager: sorcManagerMock, locationManager: locationManager, queue: queue)
            let vehicleAccessManager = VehicleAccessManager(sorcManager: sorcManagerMock, queue: queue)
            let keyholderManager = KeyholderManager(queue: queue)
            sut = TACSManager(sorcManager: sorcManagerMock,
                              telematicsManager: telematicsManager,
                              vehicleAccessManager: vehicleAccessManager,
                              keyholderManager: keyholderManager,
                              locationManager: locationManager,
                              queue: queue)
            telematicsDataChanges = []
            vehicleAccessChanges = []
            _ = sut.telematicsManager.telematicsDataChange.subscribe { change in
                telematicsDataChanges.append(change)
            }
            _ = sut.vehicleAccessManager.vehicleAccessChange.subscribe { change in
                vehicleAccessChanges.append(change)
            }
            _ = sut.telematicsManager.locationDataChange.subscribe { change in
                locationDataChange = change
            }
        }
        describe("init") {
            it("interceptors registered") {
                expect(sorcManagerMock.didReceiveRegisterInterceptor) == 3
                expect(sorcManagerMock.receivedRegisterInterceptorInterceptors[0]) === sut.telematicsManager
                expect(sorcManagerMock.receivedRegisterInterceptorInterceptors[1]) === sut.vehicleAccessManager
                expect(sorcManagerMock.receivedRegisterInterceptorInterceptors[2]) === locationManager
            }
        }

        describe("send requests via multiple managers in connected state") {
            beforeEach {
                sorcManagerMock.setConnected(true)
                (sut.telematicsManager as! TelematicsManager).requestTelematicsDataInternal([.odometer])
                (sut.telematicsManager as! TelematicsManager).requestLocationDataInternal()
                (sut.vehicleAccessManager as! VehicleAccessManager).requestFeatureInternal(.lock)
            }
            context("no change from sorcManager received") {
                it("no change notified via managers") {
                    expect(telematicsDataChanges) == [TelematicsDataChange.initialWithState([])]
                    expect(vehicleAccessChanges) == [VehicleAccessFeatureChange.initialWithState([])]
                    expect(locationDataChange) == LocationDataChange.initialWithState(false)
                }
            }
            context("request change with telematics id notified") {
                beforeEach {
                    _ = sut.telematicsManager.consume(change: ServiceGrantChangeFactory.acceptedTelematicsRequestChange())
                }
                it("telematics manager notifies change") {
                    expect(telematicsDataChanges).to(haveCount(2))
                    expect(telematicsDataChanges[1]) == TelematicsDataChange(state: [.odometer],
                                                                             action: .requestingData(types: [.odometer], accepted: true))
                }
                it("vehicle access manager does not notify change") {
                    expect(vehicleAccessChanges) == [VehicleAccessFeatureChange.initialWithState([])]
                }
                it("location manager does not notify change") {
                    expect(locationDataChange) == LocationDataChange.initialWithState(false)
                }
            }

            context("request change with feature") {
                beforeEach {
                    _ = sut.vehicleAccessManager.consume(change: ServiceGrantChangeFactory.acceptedRequestChange(feature: .lock))
                }
                it("telematics manager does not notify change") {
                    expect(telematicsDataChanges) == [TelematicsDataChange.initialWithState([])]
                }
                it("location manager does not notify change") {
                    expect(locationDataChange) == LocationDataChange.initialWithState(false)
                }
                it("vehicle access manager notifies change") {
                    expect(vehicleAccessChanges).to(haveCount(2))
                    let expectedChange = VehicleAccessFeatureChange(state: [.lock],
                                                                    action: .requestFeature(feature: .lock, accepted: true))
                    expect(vehicleAccessChanges[1]) == expectedChange
                }
            }
            context("request change with location id notified") {
                beforeEach {
                    _ = locationManager.consume(change: ServiceGrantChangeFactory.acceptedLocationRequestChange())
                }
                it("telematics manager does not notify change") {
                    expect(telematicsDataChanges) == [TelematicsDataChange.initialWithState([])]
                }
                it("vehicle access manager does not notify change") {
                    expect(vehicleAccessChanges) == [VehicleAccessFeatureChange.initialWithState([])]
                }
                it("location manager notifies change") {
                    let expectedChange = LocationDataChange(state: true, action: .requestingData(accepted: true))
                    expect(locationDataChange) == expectedChange
                }
            }
        }
    }
}
