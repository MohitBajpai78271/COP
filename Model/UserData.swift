//
//  UserData.swift
//  ConstableOnPatrol
//
//  Created by Mac on 20/07/24.
//

import Foundation

class UserData {
    static let shared = UserData()
    
    var phoneNumber: String?
    
    private init() {}
}
