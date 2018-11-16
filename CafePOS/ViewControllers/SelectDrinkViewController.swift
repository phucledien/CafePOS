//
//  SelectDrinkViewController.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/18/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import BEMCheckBox
import SVProgressHUD

class SelectDrinkViewController: UIViewController {

    @IBOutlet weak var btnDismiss: UIBarButtonItem!
    @IBOutlet weak var btnSubmit: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let disposeBag = DisposeBag()
    private let viewModel: SelectDrinkViewModelType = SelectDrinkViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        viewModel.inputs.viewDidLoad()
        setupTableView()
        fetchData()
        bindUI()
        prepareForBtnDismiss()
        prepareForBtnSubmit()
    }
    
    private func setupTableView() {

        let dataSource = RxTableViewSectionedAnimatedDataSource<SelectDrinkSection>(configureCell: { [weak self] (section, cv, indexPath, model) -> UITableViewCell in
            guard let strongSelf = self else {return UITableViewCell()}
            let cell = cv.dequeueReusableCell(withIdentifier: "selectDrinkCell", for: indexPath) as! SelectDrinkTableViewCell
            cell.selectionStyle = .none
            cell.lblName.text = model.name
            cell.lblCount.text = "\(model.count)"
            cell.lblPrice.text = "\(model.price)đ"
            cell.btnPlus.rx.tap
                .subscribe(onNext: {
                    strongSelf.viewModel.inputs.plus(id: model.id)
                })
                .disposed(by: cell.bag)
            
            cell.btnMinus.rx.tap
                .subscribe(onNext: {
                   strongSelf.viewModel.inputs.minus(id: model.id)
                })
                .disposed(by: cell.bag)
            
            
            cell.checkBox.on = model.selected
            cell.checkBox.rx.tap
                .subscribe(onNext: {
                    strongSelf.viewModel.inputs.toggle(id: model.id)
                })
                .disposed(by: cell.bag)
            
            return cell
        })
        
        viewModel.outputs.filteredDrinkSections
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func getSelectedDrinks() -> Observable<[SelectDrinkCellItem]> {
        return viewModel.outputs.getSelectedDrinks()
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
    
    private func bindUI () {
        searchBar.rx.text.orEmpty
            .subscribe(onNext: { [weak self] keyword in
                guard let strongSelf = self else {return}
                strongSelf.viewModel.inputs.set(filter: keyword)
            })
            .disposed(by: disposeBag)
    }
    
    private func prepareForBtnDismiss() {
        btnDismiss.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func prepareForBtnSubmit() {
        btnSubmit.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else {return}
                strongSelf.viewModel.inputs.submitPressed()
                strongSelf.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

