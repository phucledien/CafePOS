//
//  TablesListViewModel.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/17/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol TablesListViewModelInputs {
    
    /// Call when text search changed
    func set(filter: String)
    
    /// Call when view did load
    func viewDidLoad()
}

protocol TablesListViewModelOuputs {
    // {Alphabetized list of output signals with documentation}
    
    /// Emit fetch data success or not
    func fetchData() -> Observable<Void>
    
    /// Emit the filtered tables
    var filteredTables: BehaviorRelay<[TablesListSection]> {get}
    
}

protocol TablesListViewModelType {
    var inputs: TablesListViewModelInputs { get }
    var outputs: TablesListViewModelOuputs { get }
}

class TablesListViewModel: TablesListViewModelType, TablesListViewModelInputs, TablesListViewModelOuputs {
    // MARK : - Inputs
    func set(filter: String) {
        self.filter.accept(filter)
    }
    
    func viewDidLoad() {
        applyFilter()
    }
    
    // MARK : - Outputs
    func fetchData() -> Observable<Void> {
        return NetworkAdapter.getTables()
            .do(onNext: { [weak self] tables in
                guard let strongSelf = self else {return}
                strongSelf.tables.accept(tables.tables)
            })
            .map { _ in return Observable.of(()) }
    }
    
    var filteredTables: BehaviorRelay<[TablesListSection]> = BehaviorRelay(value: [])
    
    // MARK:- Other methods
    func createSection(withTables: [Table]) -> [TablesListSection] {
        let items = withTables.map { table in
            return TablesListCellItem(id: table.id, name: table.name, payment: "0đ", status: table.status)
        }
        return [TablesListSection(items: items)]
    }
    
    
    func applyFilter() {
        Observable.combineLatest(filter, tables)
            .subscribe(onNext: { [weak self] keyword, tables in
                guard let strongSelf = self else {return}
                var filteredTables = tables.filter { $0.name.contains(keyword) }
                if keyword.isEmpty {
                    filteredTables = tables
                }
                strongSelf.filteredTables.accept(strongSelf.createSection(withTables: filteredTables))
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    var filter: BehaviorRelay<String> = BehaviorRelay(value: "")
    var tables: BehaviorRelay<[Table]> = BehaviorRelay(value: [])
    
    // {Declaration of inputs/outputs}
    var inputs: TablesListViewModelInputs { return self }
    var outputs: TablesListViewModelOuputs { return self }
}

// RxDatasource adapter

enum TableStatus: Int {
    case Empty = 0
    case Preparing = 1
    case Ordered = 2
}

struct TablesListCellItem {
    var id: String
    var name: String
    var payment: String
    var status: TableStatus
}

extension TablesListCellItem: IdentifiableType {
    typealias Identity = String
    
    var identity: String { return id }
}

extension TablesListCellItem: Equatable {}

struct TablesListSection {
    var items: [Item]
}

extension TablesListSection: AnimatableSectionModelType {
    
    typealias Identity = String
    
    typealias Item = TablesListCellItem
    
    var identity: Identity { return ""}
    
    init(original: TablesListSection, items: [Item]) {
        self = original
        self.items = items
    }
}
