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
    var total: BehaviorRelay<Double> {get}
    var table: BehaviorRelay<SelectTableCellItem?> {get}
}

protocol CreateOrderViewModelType {
    var inputs: CreateOrderViewModelInputs { get }
    var outputs: CreateOrderViewModelOuputs { get }
}

class CreateOrderViewModel: CreateOrderViewModelType, CreateOrderViewModelInputs, CreateOrderViewModelOuputs {
    
    // MARK : - Inputs
    func createOrderSection(drinks: [SelectDrinkCellItem]) {
        let items = drinks.map { drinkItem -> CreateOrderCellItem in
            let payment = Double(drinkItem.count) * drinkItem.price
            return CreateOrderCellItem(id: drinkItem.id, name: drinkItem.name, count: drinkItem.count, payment: payment)
        }
        let orderSection = CreateOrderSection(items: items)
        self.orders.accept([orderSection])
        
        let totalPayment = calTotalPayment(orderItems: items)
        total.accept(totalPayment)
    }
    
    func set(table: SelectTableCellItem) {
        self.table.accept(table)
    }
    
    func viewDidLoad() {
        observeEmptyOrder()
        observeValidForSubmit()
    }
    
    // MARK : - Outputs
    var orders: BehaviorRelay<[CreateOrderSection]> = BehaviorRelay(value: [])
    var isEmptyOrder: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var isValid: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var total: BehaviorRelay<Double> = BehaviorRelay(value: 0)
    var table: BehaviorRelay<SelectTableCellItem?> = BehaviorRelay(value: nil)

    
    // MARK:- Other methods
    func calTotalPayment(orderItems: [CreateOrderCellItem]) -> Double {
        var totalPayment: Double = 0
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
    
    // {Declaration of inputs/outputs}
    var inputs: CreateOrderViewModelInputs { return self }
    var outputs: CreateOrderViewModelOuputs { return self }
}

// RxDatasource adapter

struct CreateOrderCellItem {
    var id: String
    var name: String
    var count: Int
    var payment: Double
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
