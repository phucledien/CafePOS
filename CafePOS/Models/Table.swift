//
//  Table.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/17/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import ObjectMapper

struct Tables: Mappable {
    var tables: [Table] = []
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.tables <- map ["tables"]
    }
}

struct Table: Mappable {
    var id: String!
    var name: String!
    var status: TableStatus!
    var orders: [Order] = []
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.id     <- map["id"]
        self.name   <- map["name"]
        self.status <- map["status"]
        self.orders <- map["orders"]
        self.id     <- map["table.id"]
        self.name   <- map["table.name"]
        self.status <- map["table.status"]
        self.orders <- map["table.orders"]
    }
}
