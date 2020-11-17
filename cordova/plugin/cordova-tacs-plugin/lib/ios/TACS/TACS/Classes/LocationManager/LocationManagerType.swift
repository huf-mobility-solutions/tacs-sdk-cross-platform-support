//
//  LocationManagerType.swift
//  TACS
//
//  Created on 24.10.19.
//  Copyright © 2019 Huf Secure Mobile GmbH. All rights reserved.
//

import Foundation
import SecureAccessBLE

internal protocol LocationManagerType: SorcInterceptor {
    /// Location data change signal which can be used to retrieve data changes
    var locationDataChange: ChangeSignal<LocationDataChange> { get }

    /// Requests Location data from the vehicle
    func requestLocationData()
}
