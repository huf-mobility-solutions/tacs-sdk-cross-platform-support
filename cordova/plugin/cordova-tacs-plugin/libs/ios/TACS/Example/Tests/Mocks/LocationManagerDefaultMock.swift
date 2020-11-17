//
//  LocationManagerDefaultMock.swift
//  TACS_Tests
//
//  Created on 30.10.19.
//  Copyright © 2019 Huf Secure Mobile. All rights reserved.
//

import SecureAccessBLE
@testable import TACS

class LocationManagerDefaultMock: LocationManagerType {
    var changeAfterConsume: ServiceGrantChange?
    func consume(change _: ServiceGrantChange) -> ServiceGrantChange? {
        return changeAfterConsume
    }

    var locationDataChangeSubject = ChangeSubject<LocationDataChange>(state: false)

    func requestLocationData() {}
    var locationDataChange: ChangeSignal<LocationDataChange> {
        return locationDataChangeSubject.asSignal()
    }
}
