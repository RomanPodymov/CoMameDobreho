//
//  OfferScreen.swift
//  CoMameDobreho
//
//  Created by Roman Podymov on 29/12/2020.
//  Copyright © 2020 CoMameDobreho. All rights reserved.
//

import Eureka
import Foundation
import SwifterSwift

enum SectionTag: String {
    case deviceInformation
    case dishes
}

protocol RowTag: CaseIterable, RawRepresentable {}

enum DeviceInformationRowTag: String, RowTag {
    case name
}

enum DishRowTag: String, RowTag {
    case soup
    case firstDish
    case secondDish
    case thirdDish
}

final class OfferScreen: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSectionDeviceInformation(deviceInformation: PersistentDataManager.shared.deviceInformation)
        setupSectionsDishes(dishes: PersistentDataManager.shared.dishes)
    }

    private func setupSectionDeviceInformation(deviceInformation: [DeviceInformationRowTag: String]?) {
        let sectionDeviceInformation = Section(L10n.OfferScreen.DeviceInformation.title)
        sectionDeviceInformation.tag = SectionTag.deviceInformation.rawValue
        form +++ sectionDeviceInformation
            <<< TextRow(DeviceInformationRowTag.name.rawValue) { row in
                row.title = L10n.OfferScreen.DeviceInformation.name
                row.value = deviceInformation?[.name]
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
    }

    private func setupSectionsDishes(dishes: [DishRowTag: String]?) {
        let sectionsDishes = Section(L10n.OfferScreen.Dishes.title)
        sectionsDishes.tag = SectionTag.dishes.rawValue
        form +++ sectionsDishes
            <<< TextRow(DishRowTag.soup.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.soup
                row.value = dishes?[.soup]
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
            <<< TextRow(DishRowTag.firstDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.firstDish
                row.value = dishes?[.firstDish]
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
            <<< TextRow(DishRowTag.secondDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.secondDish
                row.value = dishes?[.secondDish]
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
            <<< TextRow(DishRowTag.thirdDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.thirdDish
                row.value = dishes?[.thirdDish]
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
            <<< ButtonRow { row in
                row.title = L10n.OfferScreen.buttonSave
                row.onCellSelection { [weak self] _, _ in
                    guard let self = self else { return }
                    self.onSave()
                }
            }
    }

    private func onSave() {
        guard let sectionDeviceInformation = form.sectionBy(
            tag: SectionTag.deviceInformation.rawValue
        ) else {
            return
        }
        guard let sectionsDishes = form.sectionBy(
            tag: SectionTag.dishes.rawValue
        ) else {
            return
        }
        _ = saveData(
            sectionDeviceInformation: sectionDeviceInformation,
            sectionsDishes: sectionsDishes
        )
    }

    private static func getData<KeyType: CaseIterable & RawRepresentable>(for section: Section) -> [KeyType: String]? {
        let sectionTagsAndValues: [(KeyType, String?)] = KeyType.allCases.compactMap {
            guard let tag = $0.rawValue as? String else {
                return nil
            }
            guard let row: TextRow = section.rowBy(tag: tag) else {
                return nil
            }
            return ($0, row.value)
        }
        let sectionTagsAndValuesWithoutNils: [(KeyType, String)] = sectionTagsAndValues.compactMap {
            if let value = $0.1, !value.isEmpty {
                return ($0.0, value)
            } else {
                return nil
            }
        }
        if sectionTagsAndValues.count != sectionTagsAndValuesWithoutNils.count {
            return nil
        }
        return Dictionary(
            uniqueKeysWithValues: sectionTagsAndValuesWithoutNils
        )
    }

    private func saveData(
        sectionDeviceInformation: Section,
        sectionsDishes: Section
    ) -> Bool {
        guard let sectionDeviceInformationDict: [DeviceInformationRowTag: String] = Self.getData(
            for: sectionDeviceInformation
        ) else {
            return false
        }
        guard let sectionDishesDict: [DishRowTag: String] = Self.getData(
            for: sectionsDishes
        ) else {
            return false
        }

        PersistentDataManager.shared.deviceInformation = sectionDeviceInformationDict
        PersistentDataManager.shared.dishes = sectionDishesDict
        PeripheralManager.shared.updateData(
            with: sectionDishesDict,
            deviceInformation: sectionDeviceInformationDict
        )
        return true
    }
}
