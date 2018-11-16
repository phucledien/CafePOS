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
            Table(id: "0", name: "Bàn 1", status: .Ordered, payment: 200000),
            Table(id: "1", name: "Bàn 2", status: .Ordered, payment: 170000),
            Table(id: "2", name: "Bàn 3", status: .Ordered, payment: 130000),
            Table(id: "3", name: "Bàn 4", status: .Prepared, payment: 150000),
            Table(id: "4", name: "Bàn 5", status: .Prepared, payment: 100000),
            ]
//        return Observable.error(NetworkError.Error(message: "Cannot fetch tables"))
        return Observable.of(items)
    }
    
    class func getEmptyTables() -> Observable<[Table]> {
        let items = [
            Table(id: "0", name: "Bàn 1", status: .Empty, payment: 200000),
            Table(id: "1", name: "Bàn 2", status: .Empty, payment: 170000),
            Table(id: "2", name: "Bàn 3", status: .Empty, payment: 130000),
            Table(id: "3", name: "Bàn 4", status: .Empty, payment: 150000),
            Table(id: "4", name: "Bàn 5", status: .Empty, payment: 100000),
            ]
        //        return Observable.error(NetworkError.Error(message: "Cannot fetch tables"))
        return Observable.of(items)
    }
}

extension NetworkAdapter {
    class func getDrinks() -> Observable<[Drink]> {
        let items = [
            Drink(id: "0", name: "Trà sữa betea", price: 30000),
            Drink(id: "1", name: "Trà sữa olong", price: 29000),
            Drink(id: "2", name: "Cafe sữa", price: 35000),
            Drink(id: "3", name: "Cafe đen", price: 40000),
            Drink(id: "4", name: "Trà Lài", price: 60000),
            Drink(id: "5", name: "Trà sữa trân châu", price: 32000)
        ]
        //        return Observable.error(NetworkError.Error(message: "Cannot fetch tables"))

        return Observable.of(items)
    }
}
