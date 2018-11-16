//
//  CreateOrderViewModel.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/18/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol CreateOrderViewModelInputs {
    
    /// Call when user selected drinks
    func createOrderSection(drinks: [SelectDrinkCellItem])
    
    /// Call when user selected table
    func set(table: SelectTableCellItem)
   
    /// Call when view did load
    func viewDidLoad()
    
    /// Call when press submit button
//    func submitPressed()
    
}

protocol CreateOrderViewModelOuputs {
    // {Alphabetized list of output signals with documentation}
    var orders: BehaviorRelay<[CreateOrderSection]> {get}
    var isEmptyOrder: BehaviorRelay<Bool> {get}
    var isValid: BehaviorRelay<Bool> {get}
    var isSelectedTable: BehaviorRelay<Bool> {get}
    var isSelectedDrink: BehaviorRelay<Bool> {get}
    var total: BehaviorRelay<Int> {get}
    var table: BehaviorRelay<SelectTableCellItem?> {get}
    var selectedDrinks: BehaviorRelay<[SelectDrinkSection]> {get}
    
    func createOrder() -> Observable<Order>
}

protocol CreateOrderViewModelType {
    var inputs: CreateOrderViewModelInputs { get }
    var outputs: CreateOrderViewModelOuputs { get }
}

class CreateOrderViewModel: CreateOrderViewModelType, CreateOrderViewModelInputs, CreateOrderViewModelOuputs {
    
    // MARK : - Inputs
    func createOrderSection(drinks: [SelectDrinkCellItem]) {
        selectedDrinks.accept([SelectDrinkSection(items: drinks)])
        let items = drinks.map { drinkItem -> CreateOrderCellItem in
            let payment = drinkItem.count * drinkItem.price
            return CreateOrderCellItem(id: drinkItem.id, name: drinkItem.name, count: drinkItem.count, payment: payment)
        }
        let orderSection = CreateOrderSection(items: items)
        self.orders.accept([orderSection])
        
        let totalPayment = calTotalPayment(orderItems: items)
        total.accept(totalPayment)
        isSelectedDrink.accept(true)
    }
    
    func set(table: SelectTableCellItem) {
        self.table.accept(table)
        isSelectedTable.accept(true)
    }
    
    func viewDidLoad() {
        observeEmptyOrder()
        observeValidForSubmit()
    }
    
    func createOrder() -> Observable<Order> {
        let tableID = table.value!.id
        let orderSectionItems = orders.value.first?.items ?? []
        let orderDetails = orderSectionItems.map { item in
            return OrderDetail(drinkID: item.id, quantity: item.count)
        }
        
        return NetworkAdapter.createOrder(tableID: tableID, orderDetails: orderDetails)
    }
    
    // MARK : - Outputs
    var orders: BehaviorRelay<[CreateOrderSection]> = BehaviorRelay(value: [])
    var isEmptyOrder: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isValid: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isSelectedTable: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isSelectedDrink: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var total: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    var table: BehaviorRelay<SelectTableCellItem?> = BehaviorRelay(value: nil)

    
    // MARK:- Other methods
    func calTotalPayment(orderItems: [CreateOrderCellItem]) -> Int {
        var totalPayment: Int = 0
        orderItems.forEach { orderCellItem in
            totalPayment += orderCellItem.payment
        }
        return totalPayment
    }
    
    func observeEmptyOrder() {
        orders.map { createOrderSection -> Bool in
            return createOrderSection.first?.items.isEmpty ?? true
        }
        .bind(to: isEmptyOrder)
        .disposed(by: disposeBag)
    }
    
    func observeValidForSubmit() {
        Observable.combineLatest(isEmptyOrder, table)
            .map { !$0 && $1 != nil }
            .bind(to: isValid)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let didSubmitSubject = PublishSubject<Void>()
    var selectedDrinks = BehaviorRelay<[SelectDrinkSection]>(value: [])
    
    // {Declaration of inputs/outputs}
    var inputs: CreateOrderViewModelInputs { return self }
    var outputs: CreateOrderViewModelOuputs { return self }
}

// RxDatasource adapter

struct CreateOrderCellItem {
    var id: String
    var name: String
    var count: Int
    var payment: Int
}

struct CreateOrderSection {
    var items: [Item]
}

extension CreateOrderSection: SectionModelType {
    
    typealias Item = CreateOrderCellItem

    init(original: CreateOrderSection, items: [Item]) {
        self = original
        self.items = items
    }
}
