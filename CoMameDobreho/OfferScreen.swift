//
//  OfferScreen.swift
//  CoMameDobreho
//
//  Created by Roman Podymov on 29/12/2020.
//  Copyright © 2020 CoMameDobreho. All rights reserved.
//

import UIKit

final class OfferScreen: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        PeripheralManager.shared.start()
    }
}
