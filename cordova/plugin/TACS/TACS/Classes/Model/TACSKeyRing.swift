// TACSKeyRing.swift
// TACS

// Created on 30.04.19.
// Copyright © 2019 Huf Secure Mobile. All rights reserved.

import Foundation

/// Typealias vor vehicle reference type
public typealias VehicleRef = String

/// :nodoc:
public struct ServiceGrant: Codable {
    public struct Validators: Codable {
        let startTime: String
        let endTime: String
    }

    let serviceGrantId: String
    let validators: Validators
}

/// :nodoc:
public struct LeaseToken: Codable {
    let leaseTokenDocumentVersion: String
    let leaseTokenId: UUID
    let leaseId: UUID
    let userId: String
    let sorcId: UUID
    let sorcAccessKey: String
    let startTime: String
    let endTime: String
    let serviceGrantList: [ServiceGrant]
}

/// :nodoc:
public struct LeaseTokenBlob: Codable {
    let sorcId: UUID
    let blob: String
    let blobMessageCounter: String
}

/// :nodoc:
public struct TacsLeaseTokenTableEntry: Codable {
    let vehicleAccessGrantId: String
    let leaseToken: LeaseToken
}

/// :nodoc:
public struct TacsSorcBlobTableEntry: Codable {
    let tenantId: String
    let externalVehicleRef: VehicleRef
    let keyholderId: UUID?
    let blob: LeaseTokenBlob
}

/// Keyring structure. Conforms to `Codable` which means it can simply be mapped from and to JSON.
public struct TACSKeyRing: Codable {
    /// :nodoc:
    let tacsLeaseTokenTableVersion: String
    /// :nodoc:
    let tacsLeaseTokenTable: [TacsLeaseTokenTableEntry]
    /// :nodoc:
    let tacsSorcBlobTableVersion: String
    /// :nodoc:
    let tacsSorcBlobTable: [TacsSorcBlobTableEntry]
}
