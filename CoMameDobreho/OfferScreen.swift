//
//  OfferScreen.swift
//  CoMameDobreho
//
//  Created by Roman Podymov on 29/12/2020.
//  Copyright © 2020 CoMameDobreho. All rights reserved.
//

import CouchbaseLiteSwift
import Eureka
import Foundation

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

private extension Dictionary where Key == DishRowTag, Value == String {
    var asDictionaryObject: DictionaryObject {
        let result = MutableDictionaryObject()
        forEach {
            result.setString(self[$0.key], forKey: $0.key.rawValue)
        }
        return result
    }
}

final class OfferScreen: FormViewController {
    private var database: Database?
    private var currentDocument: MutableDocument?

    override func viewDidLoad() {
        super.viewDidLoad()
        let dishes = setupLocalDatabase()
        setupSectionDeviceInformation()
        setupSectionsDishes(dishes: dishes)
    }

    private func setupLocalDatabase() -> DictionaryObject? {
        database = try? Database(name: "offers")
        currentDocument = database?.document(withID: databaseID())?.toMutable()
        return currentDocument?.dictionary(forKey: "dishes")
    }

    private func databaseID(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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

    private func setupSectionsDishes(dishes: DictionaryObject?) {
        let sectionsDishes = Section(L10n.OfferScreen.Dishes.title)
        sectionsDishes.tag = SectionTag.dishes.rawValue
        form +++ sectionsDishes
            <<< TextRow(DishRowTag.soup.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.soup
                row.value = dishes?.string(forKey: DishRowTag.soup.rawValue)
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
            <<< TextRow(DishRowTag.firstDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.firstDish
                row.value = dishes?.string(forKey: DishRowTag.firstDish.rawValue)
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
            <<< TextRow(DishRowTag.secondDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.secondDish
                row.value = dishes?.string(forKey: DishRowTag.secondDish.rawValue)
                row.placeholder = L10n.OfferScreen.textPlaceholder
            }
            <<< TextRow(DishRowTag.thirdDish.rawValue) { row in
                row.title = L10n.OfferScreen.Dishes.thirdDish
                row.value = dishes?.string(forKey: DishRowTag.thirdDish.rawValue)
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
        saveData(
            sectionsDishes: sectionsDishes,
            rowDeviceName: rowDeviceName
        )
    }

    private func saveData(
        sectionsDishes: Section,
        rowDeviceName: TextRow
    ) {
        let sectionDishesTagsAndValues: [(DishRowTag, String)] = DishRowTag.allCases.compactMap {
            guard let dishRow: TextRow = sectionsDishes.rowBy(tag: $0.rawValue),
                  let rowValue = dishRow.value
            else {
                return nil
            }
            return ($0, rowValue)
        }
        let sectionDishesDict = Dictionary(
            uniqueKeysWithValues: sectionDishesTagsAndValues
        )
        if currentDocument == nil {
            currentDocument = MutableDocument(id: databaseID())
        }
        currentDocument!.setDictionary(
            sectionDishesDict.asDictionaryObject, forKey: "dishes"
        )
        do {
            try database?.saveDocument(currentDocument!)
        } catch {}
        PeripheralManager.shared.updateData(
            with: sectionDishesDict,
            deviceName: rowDeviceName.value ?? ""
        )
    }
}
