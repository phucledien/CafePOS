//
//  CreateOrderViewController.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/18/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CreateOrderViewController: UIViewController {

    @IBOutlet weak var lblTableName: UILabel!
    @IBOutlet weak var tableView: IntrinsicTableView!
    @IBOutlet weak var lblTotalPayment: UILabel!
    @IBOutlet weak var sViewTotalPayment: UIStackView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    private let viewModel: CreateOrderViewModelType = CreateOrderViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad()
        setupTableView()
        bindUI()
    }
    
    private func setupTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<CreateOrderSection>(configureCell: { (section, cv, indexPath, model) -> UITableViewCell in
            let cell = cv.dequeueReusableCell(withIdentifier: "createOrderCell", for: indexPath) as! OrderTableViewCell
            cell.selectionStyle = .none
            cell.lblName.text = model.name
            cell.lblCount.text = "x\(model.count)"
            cell.lblPayment.text = "\(model.payment)đ"
            
            return cell
        })
        
        viewModel.outputs.orders
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Segues.ToSelectTable:
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers.first as! SelectTableViewController
            vc.selectedTable
                .subscribe(onNext: { [weak self] selectedTable in
                    guard let strongSelf = self else {return}
                    strongSelf.viewModel.inputs.set(table: selectedTable)
                })
                .disposed(by: disposeBag)
        case Segues.ToSelectDrink:
            let nav = segue.destination as! UINavigationController
            let vc = nav.viewControllers.first as! SelectDrinkViewController
            vc.getSelectedDrinks()
                .subscribe(onNext: { [weak self] selectDrinks in
                    guard let strongSelf = self else {return}
                    strongSelf.viewModel.inputs.createOrderSection(drinks: selectDrinks)
                })
                .disposed(by: disposeBag)
        default:
            return
        }
    }
    
    private func bindUI() {
        viewModel.outputs.isValid.asDriver()
            .drive(onNext: { [weak self] isValid in
                guard let strongSelf = self else {return}
                strongSelf.btnSubmit.isEnabled = isValid
                strongSelf.btnSubmit.backgroundColor = #colorLiteral(red: 0.7277125635, green: 0.7277125635, blue: 0.7277125635, alpha: 1)
                strongSelf.btnSubmit.setTitleColor(#colorLiteral(red: 0.1215686277, green: 0.1294117719, blue: 0.1411764771, alpha: 1), for: .normal)
                if isValid {
                    strongSelf.btnSubmit.backgroundColor = #colorLiteral(red: 0.1261689961, green: 0.8373404145, blue: 0.8544338942, alpha: 1)
                    strongSelf.btnSubmit.setTitleColor(#colorLiteral(red: 0.942977488, green: 0.4194691777, blue: 0.5093488097, alpha: 1), for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.isEmptyOrder.asDriver()
            .drive(sViewTotalPayment.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.total.asDriver()
            .map { "\($0)đ" }
            .drive(lblTotalPayment.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.table.asDriver()
            .filter { $0 != nil }
            .map { $0?.name }
            .drive(lblTableName.rx.text)
            .disposed(by: disposeBag)
    }
}
