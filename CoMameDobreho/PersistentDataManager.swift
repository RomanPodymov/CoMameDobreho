//
//  PersistentDataManager.swift
//  CoMameDobreho
//
//  Created by Roman Podymov on 03/01/2021.
//  Copyright © 2021 CoMameDobreho. All rights reserved.
//

import CouchbaseLiteSwift
import SwifterSwift

private extension Dictionary where Key == DishRowTag, Value == String {
    var asDictionaryObject: DictionaryObject {
        let result = MutableDictionaryObject()
        forEach {
            result.setString(self[$0.key], forKey: $0.key.rawValue)
        }
        return result
    }
}

private extension DictionaryObject {
    var asDishRowTagDict: [DishRowTag: String] {
        let dishRowTagsAndValues: [(DishRowTag, String)] = DishRowTag.allCases.compactMap {
            guard let valueForKey = string(forKey: $0.rawValue) else {
                return nil
            }
            return ($0, valueForKey)
        }
        return .init(uniqueKeysWithValues: dishRowTagsAndValues)
    }
}

final class PersistentDataManager {
    private enum Key: String {
        // swiftlint:disable identifier_name
        case id
        // swiftlint:enable identifier_name
        case dishes
    }

    private static let databaseName = "offers"

    static let shared = PersistentDataManager()

    private var database: Database?
    private var currentDocument: MutableDocument?

    init() {
        database = try? Database(name: Self.databaseName)
        deleteAllDocumentsExceptForToday()
        currentDocument = database?.document(withID: databaseID())?.toMutable()
    }

    private func deleteAllDocumentsExceptForToday() {
        guard let database = database else {
            return
        }
        let query = QueryBuilder
            .select(SelectResult.expression(Meta.id))
            .from(DataSource.database(database))
            .where(Meta.id.notEqualTo(Expression.string(databaseID())))
        guard let documentsExceptForToday = try? query.execute() else {
            return
        }
        for result in documentsExceptForToday {
            if let idValue = result.string(forKey: Key.id.rawValue), let document = database.document(withID: idValue) {
                do {
                    try database.deleteDocument(document)
                } catch {}
            }
        }
    }

    private func databaseID(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    public final var dishes: [DishRowTag: String]? {
        get {
            currentDocument?.dictionary(forKey: Key.dishes.rawValue)?.asDishRowTagDict
        }

        set {
            currentDocument ?= MutableDocument(id: databaseID())
            currentDocument!.setDictionary(
                newValue?.asDictionaryObject,
                forKey: Key.dishes.rawValue
            )
            do {
                try database?.saveDocument(currentDocument!)
            } catch {}
        }
    }
}
