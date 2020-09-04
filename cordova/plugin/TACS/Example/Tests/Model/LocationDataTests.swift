//
//  LocationDataTests.swift
//  TACS_Tests
//
//  Created by Priya Khatri on 23.10.19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Nimble
import Quick
@testable import TACS

class LocationDataTests: QuickSpec {
    override func spec() {
        describe("init") {
            context("response obtain as string") {
                it("should map") {
                    let sut = try? LocationData(responseData: self.locationDataResponseString())
                    expect(sut).toNot(beNil())
                }
            }
            context("response obtain with missing accuracy value") {
                it("should give error") {
                    do {
                        _ = try LocationData(responseData: self.locationDataResponseWithoutAccuracyValue())
                    } catch {
                        expect(error).toNot(beNil())
                    }
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
