//
//  UserStateManager.swift
//  
//
//  Created by Lee, Ryan on 2/4/20.
//

import Foundation
import RxRelay
enum UserState {
    case inActive
    case active
}
class UserStateManager {
    static let shared = UserStateManager()
    let state = BehaviorRelay<UserState>(value: .inActive)
}
