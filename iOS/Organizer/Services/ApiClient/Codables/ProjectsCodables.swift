//
//  ProjectsCodables.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-28.
//

import Foundation

struct GetProjectsRequest: Encodable {
    var projectId: String
    
    enum CodingKeys: String, CodingKey {
        case projectId = "ProjectID"
    }
}

struct ProjectIdentifierResponse: Decodable {
    let id: String?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "ProjectID"
        case name = "Name"
    }
}
