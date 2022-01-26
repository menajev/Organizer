//
//  ApiClientHelpers.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-28.
//

import Foundation

enum ApiError: Error {
    case noBaseUrl
    case invalid
    case message(mesage: String, errorCode: Int)
}

struct ErrorMessage: Decodable {
    var error: String?
}

struct EmptyEncodable: Encodable { }
