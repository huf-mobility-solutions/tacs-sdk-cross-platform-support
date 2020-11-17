//
//  LocationData.swift
//  TACS
//
//  Created on 23.10.19.
//  Copyright © 2019 Huf Secure Mobile GmbH. All rights reserved.
//

import Foundation

public struct LocationData: Decodable {
    public let timestamp: String
    public let latitude: Double
    public let longitude: Double
    public let accuracy: Double

    enum Error: Swift.Error {
        case parseError
    }

    init(responseData: String) throws {
        guard let data = responseData.data(using: .utf8) else { throw Error.parseError }

        do {
            self = try JSONDecoder().decode(LocationData.self, from: data)
        } catch {
            throw Error.parseError
        }
    }
}

extension LocationData: Equatable {}
// Initializer which should only be used in tests
extension LocationData {
    init(timeStamp: String,
         latitude: Double,
         longitude: Double,
         accuracy: Double) {
        timestamp = timeStamp
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
    }
}
