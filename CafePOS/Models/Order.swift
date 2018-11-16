//
//  Order.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 12/24/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import ObjectMapper

struct Order: Mappable {
    var id: String!
    var totalPayment: Int!
    var orderDetails: [OrderDetail] = []
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.totalPayment <- map["total_payment"]
        self.orderDetails <- map["order_details"]
    }
}
