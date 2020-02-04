//
//  LoginViewController.swift
//  Levarti
//
//  Created by Lee, Ryan on 2/3/20.
//  Copyright © 2020 Lee, Ryan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
class LoginViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!

    let viewModel: LoginViewModelType = LoginViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }

    func bindUI() {
        userName.rx.text.orEmpty
            .bind(to: viewModel.username)
            .disposed(by: disposeBag)

        password.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)

        loginButton.rx.tap
            .bind(to: viewModel.loginButtonDidTap)
            .disposed(by: disposeBag)

        // indicator
        viewModel.isLoading
            .bind(to: indicator.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.stateObservble
            .asDriver(onErrorJustReturn: .unknown)
            .drive(onNext: {[weak self] state in
                guard let self = self else { return }
                if case .success = state {
                    self.dismiss(animated: true)
                }
            }).disposed(by: disposeBag)
    }
}
