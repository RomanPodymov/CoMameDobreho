//
//  OfferScreen.swift
//  CoMameDobreho
//
//  Created by Roman Podymov on 29/12/2020.
//  Copyright © 2020 CoMameDobreho. All rights reserved.
//

import Eureka
import Foundation

enum OfferScreenTag: String {
    case soup
    case firstMeal
    case secondMeal
    case thirdMeal
}

final class OfferScreen: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section(NSLocalizedString("offer_screen.title", comment: ""))
            <<< TextRow(OfferScreenTag.soup.rawValue) { row in
                row.title = NSLocalizedString("offer_screen.soup", comment: "")
                row.placeholder = NSLocalizedString("offer_screen.text_placeholder", comment: "")
            }
            <<< TextRow(OfferScreenTag.firstMeal.rawValue) { row in
                row.title = NSLocalizedString("offer_screen.first_meal", comment: "")
                row.placeholder = NSLocalizedString("offer_screen.text_placeholder", comment: "")
            }
            <<< TextRow(OfferScreenTag.secondMeal.rawValue) { row in
                row.title = NSLocalizedString("offer_screen.second_meal", comment: "")
                row.placeholder = NSLocalizedString("offer_screen.text_placeholder", comment: "")
            }
            <<< TextRow(OfferScreenTag.thirdMeal.rawValue) { row in
                row.title = NSLocalizedString("offer_screen.third_meal", comment: "")
                row.placeholder = NSLocalizedString("offer_screen.text_placeholder", comment: "")
            }
            <<< ButtonRow { row in
                row.title = NSLocalizedString("offer_screen.button_save", comment: "")
                row.onCellSelection { [weak self] _, _ in
                    self?.onSave()
                }
            }
    }

    private func onSave() {
        let offerScreenTagsAndValues: [(OfferScreenTag, String)] = form.values().compactMap {
            guard let offerScreenTag = OfferScreenTag(rawValue: $0) else {
                return nil
            }
            guard let value = $1 as? String else {
                return nil
            }
            return (offerScreenTag, value)
        }
        PeripheralManager.shared.start(with: .init(uniqueKeysWithValues: offerScreenTagsAndValues))
    }
}
