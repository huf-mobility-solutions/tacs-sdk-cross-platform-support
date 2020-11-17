//
//  LocationDataResponseTests.swift
//  TACS_Tests
//
//  Created on 29.10.19.
//  Copyright © 2019 Huf Secure Mobile GmbH. All rights reserved.
//

import Nimble
import Quick
@testable import TACS

class LocationDataResponseTests: QuickSpec {
    override func spec() {
        describe("init") {
            context("request for location data") {
                context("response contains data") {
                    it("success with data") {
                        let locationData = try? LocationData(responseData: self.locationDataResponseString())
                        let sut = LocationDataResponse(locationData)

                        let expectedData = LocationData(timeStamp: "1970-01-01T00:00:00Z",
                                                        latitude: 53.87654,
                                                        longitude: 7.234,
                                                        accuracy: 20.56)
                        let expectedResponse = LocationDataResponse.success(expectedData)
                        expect(sut) == expectedResponse
                    }
                }
                context("response doesnot contain data") {
                    it("obtain error of not supported") {
                        let locationData = try? LocationData(responseData: self.locationDataResponseWithoutAccuracyValue())
                        let sut = LocationDataResponse(locationData)

                        let expectedError = LocationDataResponse.error(.notSupported)

                        expect(sut) == expectedError
                    }
                }
            }
        }
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
}
