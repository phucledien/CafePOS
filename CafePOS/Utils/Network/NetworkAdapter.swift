//
//  NetworkAdapter.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/17/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import Foundation
import RxSwift

class NetworkAdapter {
    class func noneAuthenticateHeader() -> [String:String] {
        return [
            "Content-Type": "application/json; charset=utf-8"
        ]
    }
}

// Table
extension NetworkAdapter {
    class func getTables() -> Observable<[Table]> {
        let items = [
            Table(name: "Bàn 1", status: .Empty, payment: 200000),
            Table(name: "Bàn 2", status: .Ordered, payment: 170000),
            Table(name: "Bàn 3", status: .Ordered, payment: 130000),
            Table(name: "Bàn 4", status: .Prepared, payment: 150000),
            Table(name: "Bàn 5", status: .Empty, payment: 250000),
            Table(name: "Bàn 6", status: .Prepared, payment: 100000),
            ]
//        return Observable.error(NetworkError.Error(message: "Cannot fetch tables"))
        return Observable.of(items)
    }
}

