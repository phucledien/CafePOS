//
//  SelectTableViewModel.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/18/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol SelectTableViewModelInputs {
    /// Call when search text changed
    func set(filter: String)
    
    /// Call when view did load
    func viewDidLoad()
}

protocol SelectTableViewModelOuputs {
    // {Alphabetized list of output signals with documentation}
    
    /// Emit fetch data success or not
    func fetchData() -> Observable<Void>
    
    /// Emit the filtered tables
    var filteredTables: BehaviorRelay<[SelectTableSection]> {get}    
}

protocol SelectTableViewModelType {
    var inputs: SelectTableViewModelInputs { get }
    var outputs: SelectTableViewModelOuputs { get }
}

class SelectTableViewModel: SelectTableViewModelType, SelectTableViewModelInputs, SelectTableViewModelOuputs {
    
    // MARK : - Inputs
    func set(filter: String) {
        self.filter.accept(filter)
    }
    
    func viewDidLoad() {
        applyFilter()
    }
    
    // MARK : - Outputs
    func fetchData() -> Observable<Void> {
        return NetworkAdapter.getEmptyTables()
            .do(onNext: { [weak self] tables in
                guard let strongSelf = self else {return}
                strongSelf.tables.accept(tables)
            })
            .map { _ in return }
    }
    
    var filteredTables: BehaviorRelay<[SelectTableSection]> = BehaviorRelay(value: [])
    
    // MARK:- Other methods
    func createSection(withTables: [Table]) -> [SelectTableSection] {
        let items = withTables.map { table in
            return SelectTableCellItem(id: table.id, name: table.name)
        }
        return [SelectTableSection(items: items)]
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
    var inputs: SelectTableViewModelInputs { return self }
    var outputs: SelectTableViewModelOuputs { return self }
}

// RxDatasource adapter

struct SelectTableCellItem {
    var id: String
    var name: String
}

struct SelectTableSection {
    var items: [Item]
}

extension SelectTableSection: SectionModelType {
    typealias Item = SelectTableCellItem
    
    init(original: SelectTableSection, items: [Item]) {
        self = original
        self.items = items
    }
}



