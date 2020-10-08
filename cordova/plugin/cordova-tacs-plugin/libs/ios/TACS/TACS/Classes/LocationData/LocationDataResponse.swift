//
//  LocationDataResponse.swift
//  TACS
//
//  Created on 29.10.19.
//  Copyright © 2019 Huf Secure Mobile GmbH. All rights reserved.
//

import Foundation

/// Location data response which can be delivered via `LocationDataChange`
public enum LocationDataResponse: Equatable {
    /// Success case with associated location data
    case success(LocationData)
    /// Error case with associated error
    case error(TelematicsDataError)

    init(_ locationData: LocationData?) {
        if let result = locationData {
            self = .success(result)
        } else {
            self = .error(.notSupported)
        }
    }
}
