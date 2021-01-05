//
//  PersistentDataManager.swift
//  CoMameDobreho
//
//  Created by Roman Podymov on 03/01/2021.
//  Copyright © 2021 CoMameDobreho. All rights reserved.
//

import CouchbaseLiteSwift
import SwifterSwift

private extension Dictionary where Key: RawRepresentable, Value == String {
    var asDictionaryObject: DictionaryObject {
        let result = MutableDictionaryObject()
        forEach {
            guard let key = $0.key.rawValue as? String else {
                return
            }
            result.setString(self[$0.key], forKey: key)
        }
        return result
    }
}

private extension DictionaryObject {
    func asRowTagDict<KeyType>() -> [KeyType: String] where KeyType: CaseIterable, KeyType: RawRepresentable {
        let rowTagsAndValues: [(KeyType, String)] = KeyType.allCases.compactMap {
            guard let key = $0.rawValue as? String else {
                return nil
            }
            guard let valueForKey = string(forKey: key) else {
                return nil
            }
            return ($0, valueForKey)
        }
        return .init(uniqueKeysWithValues: rowTagsAndValues)
    }
}

final class PersistentDataManager {
    private enum DeviceInformationDocumentKey: String {
        case mainInformation
    }

    private enum OfferDocumentKey: String {
        // swiftlint:disable identifier_name
        case id
        // swiftlint:enable identifier_name
        case dishes
    }

    private static let databaseName = "offers"
    private static let deviceInformationDocumentKey = "deviceInformationDocumentKey"

    static let shared = PersistentDataManager()

    private var database: Database?
    private var deviceInformationDocument: MutableDocument?
    private var currentOfferDocument: MutableDocument?

    init() {
        database = try? Database(name: Self.databaseName)
        deleteAllDocumentsExceptForToday()
        deviceInformationDocument = database?.document(withID: Self.deviceInformationDocumentKey)?.toMutable()
        currentOfferDocument = database?.document(withID: offerDatabaseID())?.toMutable()
    }

    private func deleteAllDocumentsExceptForToday() {
        guard let database = database else {
            return
        }
        let query = QueryBuilder
            .select(SelectResult.expression(Meta.id))
            .from(DataSource.database(database))
            .where(Meta.id.notEqualTo(Expression.string(offerDatabaseID())).and(
                Meta.id.notEqualTo(Expression.string(Self.deviceInformationDocumentKey))))
        guard let documentsExceptForToday = try? query.execute() else {
            return
        }
        documentsExceptForToday.forEach { result in
            if let idValue = result.string(
                forKey: OfferDocumentKey.id.rawValue
            ), let document = database.document(
                withID: idValue
            ) {
                do {
                    try database.deleteDocument(document)
                } catch {}
            }
        }
    }

    private func offerDatabaseID(for date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private static func getProperty<KeyType: RawRepresentable, ResultKeyType: RawRepresentable & CaseIterable>(
        document: Document?,
        key: KeyType
    ) -> [ResultKeyType: String]? {
        guard let key = key.rawValue as? String else {
            return nil
        }
        return document?.dictionary(
            forKey: key
        )?.asRowTagDict()
    }

    private func setProperty<KeyType: RawRepresentable, ResultKeyType: RawRepresentable>(
        document: inout MutableDocument?,
        documentId: String,
        key: KeyType,
        newValue: [ResultKeyType: String]?
    ) {
        guard let key = key.rawValue as? String else {
            return
        }
        document ?= MutableDocument(id: documentId)
        document!.setDictionary(
            newValue?.asDictionaryObject,
            forKey: key
        )
        do {
            try database?.saveDocument(document!)
        } catch {}
    }

    public final var deviceInformation: [DeviceInformationRowTag: String]? {
        get {
            Self.getProperty(
                document: deviceInformationDocument,
                key: DeviceInformationDocumentKey.mainInformation
            )
        }

        set {
            setProperty(
                document: &deviceInformationDocument,
                documentId: Self.deviceInformationDocumentKey,
                key: DeviceInformationDocumentKey.mainInformation,
                newValue: newValue
            )
        }
    }

    public final var dishes: [DishRowTag: String]? {
        get {
            Self.getProperty(
                document: currentOfferDocument,
                key: OfferDocumentKey.dishes
            )
        }

        set {
            setProperty(
                document: &currentOfferDocument,
                documentId: offerDatabaseID(),
                key: OfferDocumentKey.dishes,
                newValue: newValue
            )
        }
    }
}
