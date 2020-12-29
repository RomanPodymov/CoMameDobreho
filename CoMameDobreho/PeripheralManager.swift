//
//  PeripheralManager.swift
//  CoMameDobreho
//
//  Created by Roman Podymov on 29/12/2020.
//  Copyright © 2020 CoMameDobreho. All rights reserved.
//

import CoreBluetooth

final class PeripheralManager: NSObject {
    static let shared = PeripheralManager()

    private var peripheralManager: CBPeripheralManager!

    private static let mainServiceId = CBUUID(string: "f64642dc-22f5-450f-a2db-a0ab07c3d47f")
    private static let mainCharacteristicId = CBUUID(string: "b1faa5b2-95b1-436c-9bc5-82815228a3e1")

    private let dataString = "Hello"

    public final func start() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
}

extension PeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            setupServices()
        default:
            ()
        }
    }

    func setupServices() {
        let valueData = dataString.data(using: .utf8)
        let mainCharacteristic = CBMutableCharacteristic(
            type: Self.mainCharacteristicId,
            properties: [.read],
            value: valueData,
            permissions: [.readable]
        )
        let mainService = CBMutableService(type: Self.mainServiceId, primary: true)
        mainService.characteristics = [mainCharacteristic]
        peripheralManager.add(mainService)
        startAdvertising()
    }

    func startAdvertising() {
        peripheralManager.startAdvertising(
            [
                CBAdvertisementDataLocalNameKey: "CoMameDobreho",
                CBAdvertisementDataServiceUUIDsKey: [
                    Self.mainServiceId,
                ],
            ]
        )
    }
}
