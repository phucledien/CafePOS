//
//  RequestStatus.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 12/25/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import ObjectMapper

enum RequestStatus:String {
    case Success = "success"
    case Failure = "failure"
}

struct RequestResult: Mappable {
    var status: RequestStatus!
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.status   <- map["status"]
    }
}
