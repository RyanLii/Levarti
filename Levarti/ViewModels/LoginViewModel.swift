//
//  LoginViewModel.swift
//  Levarti
//
//  Created by Lee, Ryan on 2/3/20.
//  Copyright © 2020 Lee, Ryan. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
struct Credentials {
    let username: String
    let password: String
}

enum LoginState {
    case success
    case failure(errorMessage: String)
    case unknown
}

protocol LoginViewModelType {
    var username: BehaviorRelay<String> { get }
    var password: BehaviorRelay<String> { get }
    var loginButtonDidTap: PublishRelay<Void> { get }
    var stateObservble: Observable<LoginState> { get }
    var isLoading: Observable<Bool> { get }
}
class LoginViewModel: LoginViewModelType{
    let username = BehaviorRelay<String>(value: "")
    let password = BehaviorRelay<String>(value: "")
    let loginButtonDidTap = PublishRelay<Void>()
    private var _isLoading = BehaviorRelay<Bool>(value: false)
    lazy var isLoading: Observable<Bool> = _isLoading.asObservable()
    lazy var stateObservble = statePublishRelay.asObservable()
    private let statePublishRelay = PublishRelay<LoginState>()
    lazy var credentialsObservable = Observable.combineLatest(username, password) { username, password in
        return Credentials(username: username, password: password)
    }

    let a = "fdafd"

    private let disposeBag = DisposeBag()
    init() {
        loginButtonDidTap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .withLatestFrom(credentialsObservable)
            .flatMapLatest { _ in
                // we do validation here if we have api endpoint
                // we fake the response now
                return Observable.just(true)
        }
        .subscribe(onNext: {[weak self] success in
            guard let self = self else { return }
            if success {
                self._isLoading.accept(true)
                DispatchQueue.main
                    .asyncAfter(deadline: .now() + 1, execute:
                    {
                        self._isLoading.accept(false)
                        UserStateManager.shared.state.accept(.active)
                        return self.statePublishRelay.accept(.success)
                })
            }
        }).disposed(by: disposeBag)
    }
}
