//
//  LoginViewController.swift
//  CafePOS
//
//  Created by Phuc Le Dien on 12/24/18.
//  Copyright © 2018 Dwarvesv. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()    

    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
    
    private func bindUI() {
        Observable.combineLatest(txtUsername.rx.text.orEmpty, txtPassword.rx.text.orEmpty)
            .map({ (username, password) in
                username.count > 0 && password.count > 0
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isValid in
                guard let strongSelf = self else {return}
                strongSelf.btnLogin.isEnabled = isValid
                strongSelf.btnLogin.backgroundColor = isValid ? #colorLiteral(red: 0.942977488, green: 0.4194691777, blue: 0.5093488097, alpha: 1) : #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            })
            .disposed(by: disposeBag)
        
        btnLogin.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else {return}
                SVProgressHUD.show()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    SVProgressHUD.dismiss()
                    if strongSelf.txtUsername.text == "phucledien" && strongSelf.txtPassword.text == "Dienphuc12" {
                        strongSelf.performSegue(withIdentifier: Segues.ToMain, sender: nil)
                    } else {
                        SVProgressHUD.showError(withStatus: "Wrong Password")
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    
}
