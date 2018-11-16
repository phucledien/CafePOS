//
//  OrderDetailViewModel.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 12/24/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol OrderDetailViewModelInputs {
    func set(tableID: String)
    func viewDidLoad()
}

protocol OrderDetailViewModelOuputs {
    
    func completePrepare() -> Observable<Bool>
    
    /// Emit fetch data success or not
    func fetchData() -> Observable<Void>
    
    // Emit table name
    var tableName: BehaviorRelay<String> {get}
    
    var isEmpty: BehaviorRelay<Bool> {get}
    
    /// Emit the filtered tables
    var orderDetailSections: BehaviorRelay<[OrderDetailSection]> {get}
}

protocol OrderDetailViewModelType {
    var inputs: OrderDetailViewModelInputs { get }
    var outputs: OrderDetailViewModelOuputs { get }
}

class OrderDetailViewModel: OrderDetailViewModelType, OrderDetailViewModelInputs, OrderDetailViewModelOuputs {
    
    // MARK:- Inputs
    func set(tableID: String) {
        self.tableID = tableID
    }
    
    func viewDidLoad() {
        createSection()
    }
    
    // MARK: - Outputs
    var tableName: BehaviorRelay<String> = BehaviorRelay(value: "")
    var isEmpty: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    var orderDetails: BehaviorRelay<[OrderDetail]> = BehaviorRelay(value: [])
    var orderDetailSections: BehaviorRelay<[OrderDetailSection]> = BehaviorRelay(value: [])
    
    func completePrepare() -> Observable<Bool> {
        return NetworkAdapter.updateStatus(tableID: tableID, status: 2)
            .map { $0.status == .Success }
    }
    
    func fetchData() -> Observable<Void> {
        return NetworkAdapter.getPreparingTables()
            .do(onNext: { [weak self] tables in
                guard
                    let strongSelf = self,
                    let tableID = tables.tables.first?.id
                else {
                    self?.isEmpty.accept(true)
                    return
                }
                strongSelf.isEmpty.accept(false)
                strongSelf.set(tableID: tableID)
                strongSelf.tableName.accept(tables.tables.first?.name ?? "unknow table name")
                strongSelf.orderDetails.accept(tables.tables.first?.orders.last?.orderDetails ?? [])
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
    var inputs: OrderDetailViewModelInputs { return self }
    var outputs: OrderDetailViewModelOuputs { return self }
}

// RxDatasource adapter

struct OrderDetailCellItem {
    var id: String
    var name: String
    var price: Int
    var quantity: Int
}

struct OrderDetailSection {
    var items: [Item]
}

extension OrderDetailSection: SectionModelType {
    typealias Item = OrderDetailCellItem
    
    init(original: OrderDetailSection, items: [Item]) {
        self = original
        self.items = items
    }
}
