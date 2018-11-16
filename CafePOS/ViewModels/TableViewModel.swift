//
//  TableViewModel.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 12/24/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol TableViewModelInputs {
    func set(tableID: String)
}

protocol TableViewModelOuputs {
    /// Emit fetch data success or not
    func fetchData() -> Observable<Void>
    
    func checkout() -> Observable<Bool>
    
    // Emit table name
    var tableName: BehaviorRelay<String> {get}
    
    // Emit table total payment
    var totalPayment: BehaviorRelay<Int> {get}
    
    /// Emit the filtered tables
    var orderDetailSections: BehaviorRelay<[OrderDetailSection]> {get}
}

protocol TableViewModelType {
    var inputs: TableViewModelInputs { get }
    var outputs: TableViewModelOuputs { get }
}

class TableViewModel: TableViewModelType, TableViewModelInputs, TableViewModelOuputs {
    
    // MARK:- Inputs
    func set(tableID: String) {
        self.tableID = tableID
    }
    
    // MARK: - Outputs
    var tableName: BehaviorRelay<String> = BehaviorRelay(value: "")
    var totalPayment: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    var orderDetails: BehaviorRelay<[OrderDetail]> = BehaviorRelay(value: [])
    var orderDetailSections: BehaviorRelay<[OrderDetailSection]> = BehaviorRelay(value: [])
    
    func checkout() -> Observable<Bool> {
        return NetworkAdapter.updateStatus(tableID: self.tableID, status: 0)
            .map { $0.status == .Success }
    }
    
    func fetchData() -> Observable<Void> {
        return NetworkAdapter.getTable(tableID: tableID)
            .do(onNext: { [weak self] table in
                guard let strongSelf = self else {return}
                strongSelf.tableName.accept(table.name)
                strongSelf.totalPayment.accept(table.orders.last?.totalPayment ?? 0)
                strongSelf.orderDetails.accept(table.orders.last?.orderDetails ?? [])
                strongSelf.createSection()
            })
            .map { _ in return }
    }
    
    func createSection() {
        orderDetails.subscribe(onNext: { [weak self] orderDetails in
            guard let strongSelf = self else {return}
            let items = orderDetails.map({ orderDetail in
                return OrderDetailCellItem(id: orderDetail.id, name: orderDetail.drink.name, price: orderDetail.drink.price, quantity: orderDetail.quantity)
            })
            strongSelf.orderDetailSections.accept([OrderDetailSection(items: items)])
        })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Properties
    var tableID: String = ""
    let disposeBag = DisposeBag()
    
    // {Declaration of inputs/outputs}
    var inputs: TableViewModelInputs { return self }
    var outputs: TableViewModelOuputs { return self }
}
