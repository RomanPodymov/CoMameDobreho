//
//  OfferScreen.swift
//  CoMameDobreho
//
//  Created by Roman Podymov on 29/12/2020.
//  Copyright © 2020 CoMameDobreho. All rights reserved.
//

import Eureka
import Foundation

final class OfferScreen: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section(NSLocalizedString("offer_screen.title", comment: ""))
            <<< TextRow { row in
                row.title = NSLocalizedString("offer_screen.soup", comment: "")
                row.placeholder = NSLocalizedString("offer_screen.text_placeholder", comment: "")
            }
            <<< TextRow { row in
                row.title = NSLocalizedString("offer_screen.first_meal", comment: "")
                row.placeholder = NSLocalizedString("offer_screen.text_placeholder", comment: "")
            }
            <<< TextRow { row in
                row.title = NSLocalizedString("offer_screen.second_meal", comment: "")
                row.placeholder = NSLocalizedString("offer_screen.text_placeholder", comment: "")
            }
            <<< TextRow { row in
                row.title = NSLocalizedString("offer_screen.third_meal", comment: "")
                row.placeholder = NSLocalizedString("offer_screen.text_placeholder", comment: "")
            }

        PeripheralManager.shared.start()
    }
}
