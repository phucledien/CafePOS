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
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        viewModel.inputs.viewDidLoad()
        setupCollectionView()
        fetchData()
        bindUI()
    }
    
    private func setupCollectionView() {
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableCollectionView.refreshControl = refreshControl
        } else {
            tableCollectionView.addSubview(refreshControl)
        }
        refreshControl.tintColor = #colorLiteral(red: 0.942977488, green: 0.4194691777, blue: 0.5093488097, alpha: 1)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Table Data ...")

        refreshControl.addTarget(self, action: #selector(refreshTableData(_:)), for: .valueChanged)

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<TablesListSection>(configureCell: { (section, cv, indexPath, model) -> UICollectionViewCell in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: "tableItem", for: indexPath) as! TableCollectionViewCell
            cell.lblName.text = model.name
            switch model.status {
            case .Empty:
                cell.lblStatus.text = "Bàn trống"
            case .Preparing:
                cell.lblStatus.text = "Đang pha chế"
            case .Ordered:
                cell.lblStatus.text = "Đã pha chế"
            }

            return cell
        })
        
        tableCollectionView.rx.modelSelected(TablesListCellItem.self)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] item in
                guard
                    let strongSelf = self,
                    let selectedRowIndexPath = strongSelf.tableCollectionView.indexPathsForSelectedItems?.first,
                    item.status != .Empty
                    else {return}
                strongSelf.tableCollectionView.deselectItem(at: selectedRowIndexPath, animated: true)
                let tableVC = TableViewController.initWith(tableID: item.id)
                tableVC.didUpdate = {
                    strongSelf.fetchData()
                }
                strongSelf.navigationController?.pushViewController(tableVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.filteredTables
            .bind(to: tableCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    @objc private func refreshTableData(_ sender: Any) {
        // Fetch Table Data
        fetchData()
    }
    
    func fetchData() {
        SVProgressHUD.show()
        viewModel.outputs.fetchData()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.refreshControl.endRefreshing()
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
