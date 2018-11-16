//
//  OrderDetailViewController.swift
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
import SnapKit

class OrderDetailViewController: UIViewController {

    @IBOutlet weak var lblTable: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    private let viewModel: OrderDetailViewModelType = OrderDetailViewModel()
    private var emptyView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad()
        fetchData()
        bindUI()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    private func bindUI() {
        viewModel.outputs.tableName
            .observeOn(MainScheduler.instance)
            .bind(to: lblTable.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.outputs.isEmpty
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEmpty in
                guard let strongSelf = self else {return}
                if isEmpty {
                    strongSelf.setupEmptyView()
                } else {
                    strongSelf.emptyView.removeFromSuperview()
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    private func setupEmptyView() {
        emptyView = Bundle.main.loadNibNamed("EmptyPrepareView", owner: self, options: nil)?.first as! UIView
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { m in
            m.top.bottom.left.right.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<OrderDetailSection>(configureCell: { (section, cv, indexPath, model) -> UITableViewCell in
            let cell = cv.dequeueReusableCell(withIdentifier: "orderDetailsCell", for: indexPath) as! OrderTableViewCell
            cell.selectionStyle = .none
            cell.lblName.text = model.name
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
    
    @IBAction func btnCompletePressed(_ sender: Any) {
        SVProgressHUD.show()
        viewModel.outputs.completePrepare()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else {return}
                SVProgressHUD.dismiss()
                let nav = strongSelf.tabBarController?.viewControllers?.first as! UINavigationController
                let tableListVC = nav.topViewController as! TablesListViewController
                tableListVC.fetchData()
                strongSelf.fetchData()
                }, onError: { [weak self] error in
                    SVProgressHUD.dismiss()
                    guard let strongSelf = self else {return}
                    strongSelf.showAlert(title: "Error", message: error.description(), UIAlertAction(title: "Retry", style: .default, handler: nil))
            })
            .disposed(by: disposeBag)
    }
}
