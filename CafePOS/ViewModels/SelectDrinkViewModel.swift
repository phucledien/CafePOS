//
//  SelectDrinkViewModel.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/18/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol SelectDrinkViewModelInputs {
    
    /// Call when do minus
    func minus(id: String)
    
    /// Call when do plus
    func plus(id: String)
    
    /// Call when do toggle select
    func toggle(id: String)
    
    /// Call when search text changed
    func set(filter: String)
    
    /// Call when press submit
    func submitPressed()
    
    /// Call when view did load
    func viewDidLoad()
}

protocol SelectDrinkViewModelOuputs {
    // {Alphabetized list of output signals with documentation}
    
    /// Emit fetch data success or not
    func fetchData() -> Observable<Void>
    
    /// Emit the filtered Drinks
    var filteredDrinkSections: BehaviorRelay<[SelectDrinkSection]> {get}
    
    /// Emit the selected Drinks
    func getSelectedDrinks() -> Observable<[SelectDrinkCellItem]>
}

protocol SelectDrinkViewModelType {
    var inputs: SelectDrinkViewModelInputs { get }
    var outputs: SelectDrinkViewModelOuputs { get }
}

class SelectDrinkViewModel: SelectDrinkViewModelType, SelectDrinkViewModelInputs, SelectDrinkViewModelOuputs {
    
    // MARK : - Inputs
    
    func minus(id: String) {
        guard
            var drinkItems = filteredDrinkSections.value.first?.items,
            var findItem = drinkItems.first(where: { $0.id == id }),
            let index = drinkItems.firstIndex(where: { $0.id == id }),
            findItem.count > 0
            else {return}
        if findItem.count - 1 == 0 {
            findItem.selected = false
        }
        findItem.count = findItem.count - 1
        drinkItems[index] = findItem
        filteredDrinkSections.accept([SelectDrinkSection(items: drinkItems)])
    }
    
    func plus(id: String) {
        guard
            var drinkItems = drinkSections.value.first?.items,
            var findItem = drinkItems.first(where: { $0.id == id }),
            let index = drinkItems.firstIndex(where: { $0.id == id })
            else {return}
        if findItem.count == 0  {
            findItem.selected = true
        }
        findItem.count = findItem.count + 1
        drinkItems[index] = findItem
        drinkSections.accept([SelectDrinkSection(items: drinkItems)])
    }
    
    func toggle(id: String) {
        guard
            var drinkItems = drinkSections.value.first?.items,
            var findItem = drinkItems.first(where: { $0.id == id }),
            let index = drinkItems.firstIndex(where: { $0.id == id })
            else {return}
        
        findItem.count = 1
        if findItem.selected {
            findItem.count = 0
        }
        
        findItem.selected = !findItem.selected
        drinkItems[index] = findItem
        drinkSections.accept([SelectDrinkSection(items: drinkItems)])
    }
    
    func set(filter: String) {
        self.filter.accept(filter)
    }
    
    func submitPressed() {
        didSubmitSubject.onNext(())
    }
    
    func viewDidLoad() {
        applyFilter()
    }
    
    // MARK : - Outputs
    func fetchData() -> Observable<Void> {
        return NetworkAdapter.getDrinks()
            .map(createSection)
            .do(onNext: { [weak self] drinkSections in
                guard let strongSelf = self else {return}
                strongSelf.drinkSections.accept(drinkSections)
            })
            .flatMap{ _ in return Observable.of(()) }
    }
    
    var filteredDrinkSections: BehaviorRelay<[SelectDrinkSection]> = BehaviorRelay(value: [])
    
    func getSelectedDrinks() -> Observable<[SelectDrinkCellItem]>  {
        return didSubmitSubject
            .withLatestFrom(drinkSections)
            .map { $0.first?.items ?? [] }
            .map { $0.filter { $0.selected } }
    }
    
    // MARK:- Other methods
    func createSection(withDrinks: [Drink]) -> [SelectDrinkSection] {
        let items = withDrinks.map { drink in
            return SelectDrinkCellItem(id: drink.id, name: drink.name, count: 0, price: drink.price, selected: false)
        }
        return [SelectDrinkSection(items: items)]
    }
    
    func applyFilter() {
        Observable.combineLatest(filter, drinkSections)
            .subscribe(onNext: { [weak self] keyword, drinkSections in
                guard
                    let strongSelf = self,
                    let drinkItems = drinkSections.first?.items
                    else {return}
                var filteredDrinks = drinkItems.filter { $0.name.contains(keyword) }
                if keyword.isEmpty {
                    filteredDrinks = drinkItems
                }
                strongSelf.filteredDrinkSections.accept([SelectDrinkSection(items: filteredDrinks)])
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    let didSubmitSubject = PublishSubject<Void>()
    
    var filter: BehaviorRelay<String> = BehaviorRelay(value: "")
    var drinkSections: BehaviorRelay<[SelectDrinkSection]> = BehaviorRelay(value: [])
    
    // {Declaration of inputs/outputs}
    var inputs: SelectDrinkViewModelInputs { return self }
    var outputs: SelectDrinkViewModelOuputs { return self }
}

// RxDatasource adapter

struct SelectDrinkCellItem {
    var id: String
    var name: String
    var count: Int
    var price: Double
    var selected: Bool
}

struct SelectDrinkSection {
    var items: [Item]
}

extension SelectDrinkCellItem: IdentifiableType {
    typealias Identity = String
    var identity: Identity { return id }
}

extension SelectDrinkCellItem: Equatable {}

extension SelectDrinkSection: AnimatableSectionModelType {
    typealias Item = SelectDrinkCellItem
    typealias Identity = String
    var identity: Identity { return "" }
    
    init(original: SelectDrinkSection, items: [Item]) {
        self = original
        self.items = items
    }
}
