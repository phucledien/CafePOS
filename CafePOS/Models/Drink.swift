//
//  Drink.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/18/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import ObjectMapper

struct Drinks: Mappable {
    var drinks: [Drink] = []
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.drinks <- map["drinks"]
    }
}

struct Drink: Mappable {
    var id: String!
    var name: String!
    var price: Int!

    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.id         <- map["id"]
        self.name       <- map["name"]
        self.price      <- map["price"]
    }
}
