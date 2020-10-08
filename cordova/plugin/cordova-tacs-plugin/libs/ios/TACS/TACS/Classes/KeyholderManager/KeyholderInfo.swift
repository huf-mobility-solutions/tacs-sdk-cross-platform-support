// KeyholderInfo.swift
// TACS

// Created on 21.05.19.
// Copyright © 2019 Huf Secure Mobile. All rights reserved.

import Foundation

/// Container for keyholder information
public struct KeyholderInfo: Equatable {
    private let manufacturerDataLength = 26
    private let keyholderIdRange = 2 ..< 18
    private let batteryVoltageRange = 18 ..< 20
    private let activationCountRange = 20 ..< 24
    private let isCardInsertedRange = 24 ..< 25
    private let batteryChangeCountRange = 25 ..< 26
    private let fullVoltageScale = 3.6
    private let advertisedCompanyId: [UInt8] = [0x0A, 0x07]

    /// ID of the keyholder
    public let keyholderId: UUID
    /// Battery voltage
    public let batteryVoltage: Double
    /// Number of times the keyholder was activated
    public let activationCount: Int
    /// Describes if the card is inserted
    public let isCardInserted: Bool
    /// Number of times the battery was changed
    public let batteryChangeCount: Int

    init?(manufacturerData: Data) {
        guard manufacturerData.count == manufacturerDataLength else { return nil }
        guard manufacturerData.subdata(in: 0 ..< 2) == Data(advertisedCompanyId) else { return nil }
        // keyholder id
        let keyholderIdString = manufacturerData.subdata(in: keyholderIdRange).toHexString()
        guard let id = UUID(hexString: keyholderIdString) else { return nil }
        keyholderId = id

        // battery voltage
        let batteryVoltageString = manufacturerData.subdata(in: batteryVoltageRange).toHexString()
        guard let intValue = Int(batteryVoltageString, radix: 16) else { return nil }
        let doubleValue = Double(intValue)
        let adcValue = doubleValue / 1024
        let voltage = adcValue * fullVoltageScale
        batteryVoltage = (voltage * 100).rounded() / 100

        // activation count
        let activationCountString = manufacturerData.subdata(in: activationCountRange).toHexString()
        guard let activationCount = Int(activationCountString, radix: 16) else { return nil }
        self.activationCount = activationCount

        // isCardInserted
        let isCardInsertedString = manufacturerData.subdata(in: isCardInsertedRange).toHexString()
        isCardInserted = Int(isCardInsertedString) == 1 ? true : false

        // batteryChangeCount
        let batteryChangeCountString = manufacturerData.subdata(in: batteryChangeCountRange).toHexString()
        guard let batteryChangeCount = Int(batteryChangeCountString, radix: 16) else { return nil }
        self.batteryChangeCount = batteryChangeCount
    }
}

extension UUID {
    init?(hexString: String) {
        var mutableString = hexString
        mutableString.insert("-", at: mutableString.index(mutableString.startIndex, offsetBy: 8))
        mutableString.insert("-", at: mutableString.index(mutableString.startIndex, offsetBy: 13))
        mutableString.insert("-", at: mutableString.index(mutableString.startIndex, offsetBy: 18))
        mutableString.insert("-", at: mutableString.index(mutableString.startIndex, offsetBy: 23))
        self.init(uuidString: mutableString)
    }
}
