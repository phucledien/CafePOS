//
//  OrderDetail.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 12/24/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import ObjectMapper

struct OrderDetail: Mappable {
    var id: String!
    var quantity: Int!
    var drinkID: String!
    var drink: Drink!
    
    init(drinkID: String, quantity: Int) {
        self.drinkID = drinkID
        self.quantity = quantity
    }
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.id         <- map["id"]
        self.quantity   <- map["quantity"]
        self.drink      <- map["drink"]
        self.drinkID    <- map["drink_id"]
    }
}
