//
//  NetworkAdapter.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/17/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

class NetworkAdapter {
    class func noneAuthenticateHeader() -> [String:String] {
        return [
            "Content-Type": "application/json; charset=utf-8"
        ]
    }
}

// MARK: - Table
extension NetworkAdapter {
    class func getTables() -> Observable<Tables> {
        let URL = APIEndpoint.baseURL + "tables"
        return APIEngine.queryData(method: .get, url: URL, parameters: nil, header: noneAuthenticateHeader())
    }
    
    class func getTable(tableID: String) -> Observable<Table> {
        let URL = APIEndpoint.baseURL + "tables/" + tableID
        return APIEngine.queryData(method: .get, url: URL, parameters: nil, header: noneAuthenticateHeader())
    }
    
    class func getEmptyTables() -> Observable<Tables> {
        let URL = APIEndpoint.baseURL + "tables/empty"
        return APIEngine.queryData(method: .get, url: URL, parameters: nil, header: noneAuthenticateHeader())
    }
    
    class func getPreparingTables() -> Observable<Tables> {
        let URL = APIEndpoint.baseURL + "tables/preparing"
        return APIEngine.queryData(method: .get, url: URL, parameters: nil, header: noneAuthenticateHeader())
    }
    
    class func updateStatus(tableID: String, status: Int) -> Observable<RequestResult> {
        let URL = APIEndpoint.baseURL + "tables/\(tableID)/status"
        let params = ["status": status]
        return APIEngine.queryData(method: .put, url: URL, parameters: params, header: noneAuthenticateHeader())
    }
}

// MARK: - Drink
extension NetworkAdapter {
    class func getDrinks() -> Observable<Drinks> {
        let URL = APIEndpoint.baseURL + "drinks"
        return APIEngine.queryData(method: .get, url: URL, parameters: nil, header: noneAuthenticateHeader())
    }
}

// MARK: - Order
extension NetworkAdapter{
    class func createOrder(tableID: String, orderDetails: [OrderDetail]) -> Observable<Order> {
        let URL = APIEndpoint.baseURL + "orders"
        let orderDetailsJson = Mapper().toJSONArray(orderDetails)
        let  params = ["order":[
            "table_id": tableID,
            "order_details": orderDetailsJson
        ]]
        return APIEngine.queryData(method: .post, url: URL, parameters: params, header: noneAuthenticateHeader())

    }
}
