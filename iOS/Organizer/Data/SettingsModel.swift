//
//  SettingsModel.swift
//  Organizer
//
//  Created by XCodeClub on 2021-12-13.
//

import Foundation

struct SettingsModel: Codable {
    var currentProject: String?
    var projectsList: [String]
    
    enum CodingKeys: String, CodingKey {
        case currentProject = "CurrentProject"
        case projectsList = "ProjectsList"
    }
    
    init() {
        currentProject = nil
        projectsList = []
    }
}
