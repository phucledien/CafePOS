//
//  Drink.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/18/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import Foundation

struct Drink {
    var id: String
    var name: String
    var price: Double
    
    init(id: String, name: String, price: Double) {
        self.id = id
        self.name = name
        self.price = price
    }
}
