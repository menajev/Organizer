//
//  LoginCodables.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-28.
//

import Foundation

struct LoginRequest: Encodable {
    var login: String
    var password: String
}

struct LoginResponse: Decodable {
    var token: String?
    enum CodingKeys: String, CodingKey {
        case token = "Token"
    }
}

struct LogoutRequest: Encodable {
    let function = "logout"
    enum CodingKeys: String, CodingKey {
        case function = "Func"
    }
}
