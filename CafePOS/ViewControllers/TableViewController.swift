//
//  TableViewController.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 12/24/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SVProgressHUD

class TableViewController: UIViewController {

    @IBOutlet weak var lblTable: UILabel!
    @IBOutlet weak var tableView: IntrinsicTableView!
    @IBOutlet weak var lblTotal: UILabel!
    
    private let disposeBag = DisposeBag()
    private let viewModel: TableViewModelType = TableViewModel()
    var didUpdate: (()->())?
    
    class func initWith(tableID: String) -> TableViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TableViewController") as! TableViewController
        vc.viewModel.inputs.set(tableID: tableID)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        bindUI()
        setupTableView()
    }
    
    private func bindUI() {
        viewModel.outputs.tableName
            .observeOn(MainScheduler.instance)
            .bind(to: lblTable.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.totalPayment.map { "\($0)đ" }
            .observeOn(MainScheduler.instance)
            .bind(to: lblTotal.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<OrderDetailSection>(configureCell: { (section, cv, indexPath, model) -> UITableViewCell in
            let cell = cv.dequeueReusableCell(withIdentifier: "createOrderCell", for: indexPath) as! OrderTableViewCell
            cell.selectionStyle = .none
            cell.lblName.text = model.name
            cell.lblPayment.text = "\(model.price)đ"
            cell.lblCount.text = "x\(model.quantity)"
            return cell
        })
        
        viewModel.outputs.orderDetailSections
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
    
    @IBAction func btnCheckoutPressed(_ sender: Any) {
        SVProgressHUD.show()
        viewModel.outputs.checkout()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard
                    let strongSelf = self,
                    let didUpdate = strongSelf.didUpdate
                else {return}
                
                SVProgressHUD.dismiss()
                didUpdate()
                strongSelf.navigationController?.popViewController(animated: true)
            }, onError: { [weak self] error in
                SVProgressHUD.dismiss()
                guard let strongSelf = self else {return}
                strongSelf.showAlert(title: "Error", message: error.description(), UIAlertAction(title: "Retry", style: .default, handler: nil))
            })
            .disposed(by: disposeBag)
    }
}
