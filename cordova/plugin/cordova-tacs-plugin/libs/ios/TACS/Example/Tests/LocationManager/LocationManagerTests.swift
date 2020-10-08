//
//  LocationMangerTest.swift
//  TACS_Tests
//
//  Created on 24.10.19.
//  Copyright © 2019 Huf Secure Mobile GmbH. All rights reserved.
//

import Nimble
import Quick
@testable import SecureAccessBLE
@testable import TACS

class LocationManagerTests: QuickSpec {
    class SorcManagerMock: SorcManagerDefaultMock {
        func setConnected(_ connected: Bool) {
            let sorcID = UUID(uuidString: "be2fecaf-734b-4252-8312-59d477200a20")!
            if connected {
                connectionChangeSubject.onNext(ConnectionChange(state: .connected(sorcID: sorcID),
                                                                action: .connectionEstablished(sorcID: sorcID)))
            } else {
                connectionChangeSubject.onNext(ConnectionChange(state: .disconnected, action: .disconnect))
            }
        }
    }

    private let sorcID = UUID(uuidString: "be2fecaf-734b-4252-8312-59d477200a20")!

    // swiftlint:disable function_body_length
    override func spec() {
        var sut: LocationManager!
        var sorcManager: SorcManagerMock!
        var consumeResult: ServiceGrantChange?
        var locationDataChange: LocationDataChange?

        beforeEach {
            sorcManager = SorcManagerMock()
            sut = LocationManager(sorcManager: sorcManager)
            _ = sut.locationDataChange.subscribe { change in
                locationDataChange = change
            }
        }
        describe("consume") {
            // MARK: .initial

            context("initial") {
                it("consumes change") {
                    let action = ServiceGrantChange.Action.initial
                    let state = ServiceGrantChange.State(requestingServiceGrantIDs: [])
                    let change = ServiceGrantChange(state: state, action: action)
                    consumeResult = sut.consume(change: change)
                    expect(consumeResult).to(beNil())
                }
            }

            // MARK: .requestServiceGrant

            context("data was requested") {
                let state = ServiceGrantChange.State(requestingServiceGrantIDs: [])
                var change: ServiceGrantChange!
                beforeEach {
                    sorcManager.setConnected(true)
                    sut.requestLocationData()
                }
                context("service grant id is not locationID") {
                    beforeEach {
                        let serviceGrantID: ServiceGrantID = 2
                        let action = ServiceGrantChange.Action.requestServiceGrant(id: serviceGrantID, accepted: true)
                        change = ServiceGrantChange(state: state, action: action)
                        consumeResult = sut.consume(change: change)
                    }
                    it("doesnot consume change") {
                        expect(consumeResult) == change
                    }
                }
                context("service grant id is locationID") {
                    context("accepted") {
                        var serviceGrantID: ServiceGrantID!
                        beforeEach {
                            serviceGrantID = LocationManager.locationServiceGrantID
                            let action = ServiceGrantChange.Action.requestServiceGrant(id: serviceGrantID, accepted: true)
                            change = ServiceGrantChange(state: state, action: action)
                            consumeResult = sut.consume(change: change)
                        }
                        it("consumes change") {
                            expect(consumeResult).to(beNil())
                        }
                        it("notifies change") {
                            let expectedAction = LocationDataChange.Action.requestingData(accepted: true)
                            let state = change.state.requestingServiceGrantIDs.contains(serviceGrantID)
                            expect(locationDataChange) == LocationDataChange(state: state, action: expectedAction)
                        }
                    }

                    context("not accepted") {
                        beforeEach {
                            let action = ServiceGrantChange.Action.requestServiceGrant(id: LocationManager.locationServiceGrantID, accepted: false)
                            change = ServiceGrantChange(state: state, action: action)
                            consumeResult = sut.consume(change: change)
                        }
                        it("consumes change") {
                            expect(consumeResult).to(beNil())
                        }
                        it("notifies change") {
                            let expectedAction = LocationDataChange.Action.requestingData(accepted: false)
                            expect(locationDataChange) == LocationDataChange(state: false, action: expectedAction)
                        }
                    }
                }
                context("state contains location id") {
                    it("location id is removed") {
                        let state = ServiceGrantChange.State(requestingServiceGrantIDs: [10])
                        let action = ServiceGrantChange.Action.requestServiceGrant(id: 2, accepted: true)
                        let change = ServiceGrantChange(state: state, action: action)
                        let result = sut.consume(change: change)
                        let expectedChange = ServiceGrantChange(state: .init(requestingServiceGrantIDs: []),
                                                                action: .requestServiceGrant(id: 2, accepted: true))
                        expect(result) == expectedChange
                    }
                }
            }

            // MARK: .responseReceived

            context("responseReceived") {
                var change: ServiceGrantChange!
                var responseStatus: ServiceGrantResponse.Status!
                var serviceGrantID: UInt16!
                context("service grant id is location") {
                    beforeEach {
                        serviceGrantID = LocationManager.locationServiceGrantID
                        sorcManager.setConnected(true)
                    }
                    context("data was requested") {
                        beforeEach {
                            sut.requestLocationData()
                            _ = sut.consume(change: ServiceGrantChangeFactory.acceptedLocationRequestChange())
                        }
                        context("received response") {
                            responseStatus = ServiceGrantResponse.Status.success
                            beforeEach {
                                let state = ServiceGrantChange.State(requestingServiceGrantIDs: [])

                                let response = ServiceGrantResponse(sorcID: self.sorcID,
                                                                    serviceGrantID: serviceGrantID,
                                                                    status: responseStatus,
                                                                    responseData: self.locationDataResponseString())
                                let action = ServiceGrantChange.Action.responseReceived(response)
                                change = ServiceGrantChange(state: state, action: action)
                            }

                            it("consumes change") {
                                consumeResult = sut.consume(change: change)
                                expect(consumeResult).to(beNil())
                            }

                            context("response is success containing requested data") {
                                beforeEach {
                                    consumeResult = sut.consume(change: change)
                                }

                                it("notifies location data change") {
                                    let locationData = LocationData(timeStamp: "1970-01-01T00:00:00Z",
                                                                    latitude: 53.87654,
                                                                    longitude: 7.234,
                                                                    accuracy: 20.56)
                                    let expectedResponse = LocationDataResponse(locationData)
                                    let expectedChange = LocationDataChange(state: false, action: .responseReceived(response: expectedResponse))
                                    expect(locationDataChange) == expectedChange
                                }
                            }

                            context("response doesnot contain requested data") {
                                beforeEach {
                                    let state = ServiceGrantChange.State(requestingServiceGrantIDs: [])

                                    let response = ServiceGrantResponse(sorcID: self.sorcID,
                                                                        serviceGrantID: serviceGrantID,
                                                                        status: responseStatus,
                                                                        responseData: self.locationDataResponseWithoutAccuracyValue())
                                    let action = ServiceGrantChange.Action.responseReceived(response)
                                    change = ServiceGrantChange(state: state, action: action)
                                    consumeResult = sut.consume(change: change)
                                }
                                it("notifies not supported state") {
                                    let expectedResponse = LocationDataResponse.error(.notSupported)
                                    let expectedAction = LocationDataChange.Action.responseReceived(response: expectedResponse)
                                    let expectedChange = LocationDataChange(state: false, action: expectedAction)
                                    expect(locationDataChange) == expectedChange
                                }
                            }
                        }
                        context("status of response is invalidTimeFrame") {
                            beforeEach {
                                responseStatus = .invalidTimeFrame
                                let state = ServiceGrantChange.State(requestingServiceGrantIDs: [])
                                let response = ServiceGrantResponse(sorcID: self.sorcID,
                                                                    serviceGrantID: serviceGrantID,
                                                                    status: responseStatus,
                                                                    responseData: "FOO")
                                let action = ServiceGrantChange.Action.responseReceived(response)
                                change = ServiceGrantChange(state: state, action: action)
                                consumeResult = sut.consume(change: change)
                            }
                            it("notifies denied state") {
                                let expectedResponse = LocationDataResponse.error(.denied)
                                let expectedAction = LocationDataChange.Action.responseReceived(response: expectedResponse)
                                let expectedChange = LocationDataChange(state: false, action: expectedAction)
                                expect(locationDataChange) == expectedChange
                            }
                        }
                    }
                }
                context("service grant id is not location") {
                    beforeEach {
                        serviceGrantID = 4
                    }
                    it("does not consume change") {
                        let state = ServiceGrantChange.State(requestingServiceGrantIDs: [])
                        let response = ServiceGrantResponse(sorcID: self.sorcID,
                                                            serviceGrantID: serviceGrantID,
                                                            status: ServiceGrantResponse.Status.success,
                                                            responseData: "FOO")
                        let action = ServiceGrantChange.Action.responseReceived(response)
                        let change = ServiceGrantChange(state: state, action: action)
                        let result = sut.consume(change: change)
                        expect(result) == change
                    }
                    context("service grant contains location id") {
                        it("location id is removed") {
                            let state = ServiceGrantChange.State(requestingServiceGrantIDs: [LocationManager.locationServiceGrantID])
                            let response = ServiceGrantResponse(sorcID: self.sorcID,
                                                                serviceGrantID: serviceGrantID,
                                                                status: ServiceGrantResponse.Status.success,
                                                                responseData: "FOO")
                            let action = ServiceGrantChange.Action.responseReceived(response)
                            let change = ServiceGrantChange(state: state, action: action)
                            let result = sut.consume(change: change)

                            let expectedState = ServiceGrantChange.State(requestingServiceGrantIDs: [])
                            let expectedResponse = ServiceGrantResponse(sorcID: self.sorcID,
                                                                        serviceGrantID: serviceGrantID,
                                                                        status: ServiceGrantResponse.Status.success,
                                                                        responseData: "FOO")
                            let expectedAction = ServiceGrantChange.Action.responseReceived(expectedResponse)
                            let expectedChange = ServiceGrantChange(state: expectedState, action: expectedAction)

                            expect(result) == expectedChange
                        }
                    }
                }
            }

            // MARK: .requestFailed

            context("action is requestFailed") {
                var change: ServiceGrantChange!
                beforeEach {
                    let state = ServiceGrantChange.State(requestingServiceGrantIDs: [])
                    let action = ServiceGrantChange.Action.requestFailed(.receivedInvalidData)
                    change = ServiceGrantChange(state: state, action: action)
                }
                it("does not consume change") {
                    let result = sut.consume(change: change)
                    expect(result) == change
                }
                it("does not notify error if no request is pending") {
                    _ = sut.consume(change: change)
                    expect(locationDataChange) == LocationDataChange.initialWithState(false)
                }
                it("notifies error if request was pending") {
                    sorcManager.setConnected(true)
                    sut.requestLocationData()
                    _ = sut.consume(change: ServiceGrantChangeFactory.acceptedLocationRequestChange())
                    _ = sut.consume(change: change)
                    let expectedResponse = LocationDataResponse.error(.remoteFailed)
                    expect(locationDataChange) == LocationDataChange(state: false, action: .responseReceived(response: expectedResponse))
                }
            }

            // MARK: .reset

            context("action is reset") {
                var change: ServiceGrantChange!
                beforeEach {
                    let state = ServiceGrantChange.State(requestingServiceGrantIDs: [])
                    let action = ServiceGrantChange.Action.reset
                    change = ServiceGrantChange(state: state, action: action)
                }
                it("does not consume change") {
                    let result = sut.consume(change: change)
                    expect(result) == change
                }
            }
        }
    }

    private func locationDataResponseString() -> String {
        let string = """
        {
            "timestamp": "1970-01-01T00:00:00Z",
            "latitude": 53.87654,
            "longitude": 7.234,
            "accuracy": 20.56
        }
        """
        return string
    }

    private func locationDataResponseWithoutAccuracyValue() -> String {
        let string = """
        {
            "timestamp": "1970-01-01T00:00:00Z",
            "latitude": 53.87654,
            "longitude": 7.234,
            "accuracy": null
        }
        """
        return string
    }
}
