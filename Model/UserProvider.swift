//
//  UserProvider.swift
//  ConstableOnPatrol
//
//  Created by Mac on 18/07/24.
//

import UIKit

struct UserProvider: Codable {
    var userRole: String
    var id: String
    var token: String
    var userName: String
    var phoneNumber: String
    var gender: String
    var address: String
    var dateOfBirth: String
}

