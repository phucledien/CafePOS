//
//  Table.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/17/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import Foundation

struct Table {
    var id: String
    var name: String
    var status: TableStatus
    var payment: Int
    
    init(id: String, name: String, status: TableStatus, payment: Int) {
        self.id = id
        self.name = name
        self.status = status
        self.payment = payment
    }
}
