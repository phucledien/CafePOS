//
//  TablesListViewController.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 11/17/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SVProgressHUD

class TablesListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    private let viewModel: TablesListViewModelType = TablesListViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad()
        setupCollectionView()
        fetchData()
        bindUI()
    }
    
    private func setupCollectionView() {
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<TablesListSection>(configureCell: { (section, cv, indexPath, model) -> UICollectionViewCell in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "tableItem", for: indexPath) as! TableCollectionViewCell
            cell.lblName.text = model.name
            cell.lblPayment.text = model.payment
            switch model.status {
            case .Empty:
                cell.lblStatus.text = "Bàn trống"
            case .Ordered:
                cell.lblStatus.text = "Đang pha chế"
            case .Prepared:
                cell.lblStatus.text = "Đã pha chế"
            }
            return cell
        })

        viewModel.outputs.filteredTables
            .bind(to: tableCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    private func fetchData() {
        SVProgressHUD.show()
        viewModel.outputs.fetchData()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { _ in
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
}
