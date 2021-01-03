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

enum DeviceInformationRowTag: String {
    case name
}

enum DishRowTag: String, CaseIterable {
    case soup
    case firstDish
    case secondDish
    case thirdDish
}

final class OfferScreen: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSectionDeviceInformation()
        setupSectionsDishes(dishes: PersistentDataManager.shared.dishes)
    }

    private func setupSectionDeviceInformation() {
        let sectionDeviceInformation = Section(L10n.OfferScreen.DeviceInformation.title)
        sectionDeviceInformation.tag = SectionTag.deviceInformation.rawValue
        form +++ sectionDeviceInformation
            <<< TextRow(DeviceInformationRowTag.name.rawValue) { row in
                row.title = L10n.OfferScreen.DeviceInformation.name
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
    }

    private func setupSectionsDishes(dishes: [DishRowTag: String]?) {
        let sectionsDishes = Section(L10n.OfferScreen.Dishes.title)
        sectionsDishes.tag = SectionTag.dishes.rawValue
        form +++ sectionsDishes
            <<< TextRow(DishRowTag.soup.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.soup
                row.value = dishes?[DishRowTag.soup]
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
            <<< TextRow(DishRowTag.firstDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.firstDish
                row.value = dishes?[DishRowTag.firstDish]
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
            <<< TextRow(DishRowTag.secondDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.secondDish
                row.value = dishes?[DishRowTag.secondDish]
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
            <<< TextRow(DishRowTag.thirdDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.thirdDish
                row.value = dishes?[DishRowTag.thirdDish]
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
            <<< ButtonRow { row in
                row.title = L10n.OfferScreen.buttonSave
                row.onCellSelection { [weak self] _, _ in
                    self?.onSave()
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
        guard let rowDeviceName: TextRow = sectionDeviceInformation.rowBy(
            tag: DeviceInformationRowTag.name.rawValue
        ) else {
            return
        }
        if !saveData(
            sectionsDishes: sectionsDishes,
            rowDeviceName: rowDeviceName
        ) {}
    }

    private func saveData(
        sectionsDishes: Section,
        rowDeviceName: TextRow
    ) -> Bool {
        if rowDeviceName.value.isNilOrEmpty {
            return false
        }
        let sectionDishesTagsAndValues: [(DishRowTag, String?)] = DishRowTag.allCases.compactMap {
            guard let dishRow: TextRow = sectionsDishes.rowBy(tag: $0.rawValue) else {
                return nil
            }
            return ($0, dishRow.value)
        }
        let sectionDishesTagsAndValuesWithoutNils: [(DishRowTag, String)] = sectionDishesTagsAndValues.compactMap {
            if let value = $0.1 {
                return ($0.0, value)
            } else {
                return nil
            }
        }
        if sectionDishesTagsAndValues.count != sectionDishesTagsAndValuesWithoutNils.count {
            return false
        }
        let sectionDishesDict = Dictionary(
            uniqueKeysWithValues: sectionDishesTagsAndValuesWithoutNils
        )
        PersistentDataManager.shared.dishes = sectionDishesDict
        PeripheralManager.shared.updateData(
            with: sectionDishesDict,
            deviceName: rowDeviceName.value ?? ""
        )
        return true
    }
}
