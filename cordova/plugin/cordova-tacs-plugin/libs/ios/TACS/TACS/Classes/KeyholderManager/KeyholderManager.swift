// KeyholderManager.swift
// TACS

// Created on 03.05.19.
// Copyright © 2019 Huf Secure Mobile. All rights reserved.

import CoreBluetooth
import Foundation
import SecureAccessBLE

/// Manager for retrieving keyholder state. Retrieve an instance of it via `keyholderManager` property of `TACSManager`
public class KeyholderManager: NSObject, KeyholderManagerType {
    private let keyholderChangeSubject = ChangeSubject<KeyholderStatusChange>(state: .stopped)

    /// Keyholder change which can be used to retrieve keyholder status
    public var keyholderChange: ChangeSignal<KeyholderStatusChange> {
        return keyholderChangeSubject.asSignal()
    }

    private let centralManager: CBCentralManagerType
    private let queue: DispatchQueue
    internal var keyholderIDProvider: (() -> UUID?)!

    internal var trackingParametersProvider: TACSManager.DefaultTrackingParametersProvider?

    private let keyholderServiceId = "180A"
    private var scanTimeoutTimer: RepeatingBackgroundTimer?

    required init(centralManager: CBCentralManagerType, queue: DispatchQueue) {
        self.centralManager = centralManager
        self.queue = queue
        super.init()
        self.centralManager.delegate = self
    }

    /// Requests keyholder status and notifies changes via `keyholderChange`
    ///
    /// - Parameter timeout: Interval which defines discovery timeout. If the keyholder is not discovered during given timeout,
    /// appropriate error change will be notified via `keyholderChange`.
    public func requestStatus(timeout: TimeInterval) {
        queue.async {
            self.requestStatusInternal(timeout: timeout)
        }
    }

    internal func requestStatusInternal(timeout: TimeInterval) {
        var parameters = trackingParametersProvider?() ?? [:]
        parameters[ParameterKey.timeout.rawValue] = String(describing: timeout)
        HSMTrack(.keyholderStatusRequested, parameters: parameters, loglevel: .info)

        guard keyholderChange.state == .stopped else { return }
        guard keyholderIDProvider() != nil else {
            let change = KeyholderStatusChange(state: .stopped, action: .failed(.keyholderIdMissing))
            keyholderChangeSubject.onNext(change)
            return
        }
        guard centralManager.state == .poweredOn else {
            let change = KeyholderStatusChange(state: .stopped, action: .failed(.bluetoothOff))
            keyholderChangeSubject.onNext(change)
            return
        }
        let cbuuid = CBUUID(string: keyholderServiceId)
        centralManager.scanForPeripherals(withServices: [cbuuid], options: nil)
        scheduleTimeoutTimer(timeout: timeout)
        let change = KeyholderStatusChange(state: .searching, action: .discoveryStarted)
        keyholderChangeSubject.onNext(change)
    }

    private func scheduleTimeoutTimer(timeout: TimeInterval) {
        scanTimeoutTimer = RepeatingBackgroundTimer.scheduledTimer(timeInterval: timeout, queue: queue, handler: onTimeout)
    }

    private func onTimeout() {
        scanTimeoutTimer?.suspend()
        centralManager.stopScan()
        let change = KeyholderStatusChange(state: .stopped, action: .failed(.scanTimeout))
        keyholderChangeSubject.onNext(change)
    }

    func centralManager_(_: CBCentralManagerType, didDiscover _: CBPeripheralType,
                         advertisementData: [String: Any], rssi _: NSNumber) {
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
            let keyholderInfo = KeyholderInfo(manufacturerData: manufacturerData),
            keyholderInfo.keyholderId == keyholderIDProvider() {
            onKeyholderDiscovered(keyholderInfo: keyholderInfo)
        }
    }

    func centralManagerDidUpdateState_(_ centralManager: CBCentralManagerType) {
        if keyholderChange.state == .searching {
            scanTimeoutTimer?.suspend()
            centralManager.stopScan()
            keyholderChangeSubject.onNext(KeyholderStatusChange(state: .stopped, action: .failed(.bluetoothOff)))
        }
    }

    private func onKeyholderDiscovered(keyholderInfo: KeyholderInfo) {
        scanTimeoutTimer?.suspend()
        centralManager.stopScan()
        let change = KeyholderStatusChange(state: .stopped, action: .discovered(keyholderInfo))
        keyholderChangeSubject.onNext(change)
    }
}

extension KeyholderManager {
    convenience init(queue: DispatchQueue) {
        let centralManager = CBCentralManager(delegate: nil, queue: queue,
                                              options: [CBPeripheralManagerOptionShowPowerAlertKey: 0])
        self.init(centralManager: centralManager, queue: queue)
    }
}

extension KeyholderManager: CBCentralManagerDelegate {
    /// :nodoc:
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralManagerDidUpdateState_(central)
    }

    /// :nodoc:
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                               advertisementData: [String: Any], rssi RSSI: NSNumber) {
        centralManager_(central as CBCentralManagerType,
                        didDiscover: peripheral as CBPeripheralType,
                        advertisementData: advertisementData,
                        rssi: RSSI)
    }
}
