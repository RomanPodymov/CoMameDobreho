//
//  PeripheralManager.swift
//  CoMameDobreho
//
//  Created by Roman Podymov on 29/12/2020.
//  Copyright © 2020 CoMameDobreho. All rights reserved.
//

import CoreBluetooth

private enum CharacteristicId: String, CaseIterable {
    case soup = "b1faa5b2-95b1-436c-9bc5-82815228a3e1"
    case firstDish = "b1faa5b2-95b1-436c-9bc5-82815228a3e2"
    case secondDish = "b1faa5b2-95b1-436c-9bc5-82815228a3e3"
    case thirdDish = "b1faa5b2-95b1-436c-9bc5-82815228a3e4"

    var asDishRowTag: DishRowTag {
        switch self {
        case .soup:
            return .soup
        case .firstDish:
            return .firstDish
        case .secondDish:
            return .secondDish
        case .thirdDish:
            return .thirdDish
        }
    }
}

final class PeripheralManager: NSObject {
    static let shared = PeripheralManager()

    private var peripheralManager: CBPeripheralManager!

    private static let mainServiceId = CBUUID(
        string: "f64642dc-22f5-450f-a2db-a0ab07c3d47f"
    )

    private var deviceName = ""
    private var offer: [DishRowTag: String]?

    public final func updateData(with offer: [DishRowTag: String], deviceName: String) {
        self.deviceName = deviceName
        self.offer = offer
        if peripheralManager == nil {
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }
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
        let mainCharacteristics = CharacteristicId.allCases.map {
            CBMutableCharacteristic(
                type: CBUUID(string: $0.rawValue),
                properties: [.read],
                value: self.offer?[$0.asDishRowTag].flatMap { $0.data(using: .utf8) },
                permissions: [.readable]
            )
        }
        let mainService = CBMutableService(type: Self.mainServiceId, primary: true)
        mainService.characteristics = mainCharacteristics
        peripheralManager.add(mainService)
        startAdvertising()
    }

    func startAdvertising() {
        peripheralManager.startAdvertising(
            [
                CBAdvertisementDataLocalNameKey: deviceName,
                CBAdvertisementDataServiceUUIDsKey: [
                    Self.mainServiceId,
                ],
            ]
        )
    }
}
