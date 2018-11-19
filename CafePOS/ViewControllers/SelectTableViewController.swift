//
//  SelectTableViewController.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/18/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SVProgressHUD

class SelectTableViewController: UIViewController {

    @IBOutlet weak var btnDismiss: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let selectedTable = PublishSubject<SelectTableCellItem>()
    private let disposeBag = DisposeBag()
    private let viewModel: SelectTableViewModelType = SelectTableViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        viewModel.inputs.viewDidLoad()
        setupTableView()
        fetchData()
        bindUI()
        prepareForBtnDismiss()
        prepareForSelectItem()
    }
    
    private func prepareForBtnDismiss() {
        btnDismiss.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<SelectTableSection>(configureCell: { (section, cv, indexPath, model) -> UITableViewCell in
            let cell = cv.dequeueReusableCell(withIdentifier: "selectTableCell", for: indexPath)
            cell.textLabel?.text = model.name
            return cell
        })
        
        viewModel.outputs.filteredTables
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func fetchData() {
        SVProgressHUD.show()
        viewModel.outputs.fetchData()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                SVProgressHUD.dismiss()
            }, onError: { [weak self] error in
                SVProgressHUD.dismiss()
                guard let strongSelf = self else {return}
                strongSelf.showAlert(title: "Error", message: error.description(), UIAlertAction(title: "Retry", style: .default, handler: { _ in strongSelf.fetchData() }))
            })
            .disposed(by: disposeBag)
    }
    
    private func prepareForSelectItem() {
        tableView.rx.modelSelected(SelectTableCellItem.self)
            .subscribe(onNext: { [weak self] item in
                guard let strongSelf = self else {return}
                strongSelf.selectedTable.onNext(item)
                strongSelf.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindUI () {
        searchBar.rx.text.orEmpty
            .subscribe(onNext: { [weak self] keyword in
                guard let strongSelf = self else {return}
                strongSelf.viewModel.inputs.set(filter: keyword)
            })
            .disposed(by: disposeBag)
    }

}
