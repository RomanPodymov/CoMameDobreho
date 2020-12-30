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
    case firstMeal = "b1faa5b2-95b1-436c-9bc5-82815228a3e2"
    case secondMeal = "b1faa5b2-95b1-436c-9bc5-82815228a3e3"
    case thirdMeal = "b1faa5b2-95b1-436c-9bc5-82815228a3e4"

    var asOfferScreenTag: OfferScreenTag {
        switch self {
        case .soup:
            return .soup
        case .firstMeal:
            return .firstMeal
        case .secondMeal:
            return .secondMeal
        case .thirdMeal:
            return .thirdMeal
        }
    }
}

final class PeripheralManager: NSObject {
    static let shared = PeripheralManager()

    private var peripheralManager: CBPeripheralManager!

    private static let mainServiceId = CBUUID(
        string: "f64642dc-22f5-450f-a2db-a0ab07c3d47f"
    )

    private var data: [OfferScreenTag: String]?

    public final func start(with data: [OfferScreenTag: String]) {
        self.data = data
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
        let mainCharacteristics = CharacteristicId.allCases.map {
            CBMutableCharacteristic(
                type: CBUUID(string: $0.rawValue),
                properties: [.read],
                value: self.data?[$0.asOfferScreenTag].flatMap { $0.data(using: .utf8) },
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
                CBAdvertisementDataLocalNameKey: "CoMameDobreho",
                CBAdvertisementDataServiceUUIDsKey: [
                    Self.mainServiceId,
                ],
            ]
        )
    }
}
