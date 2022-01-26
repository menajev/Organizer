//
//  ProjectModel.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-23.
//

import Foundation
import AnyCodable

struct ProjectIdentifier: Hashable {
    var id: String
    var name: String
}

struct ProjectModel: Identifiable, Codable {
    var id: String
    var name: String?
    var version: Int
    var tasksListFilters: [String: AnyCodable] // Desktop app settings; TODO: Or needed?
    var shortcutsListFilters: [String: AnyCodable] // Desktop app settings
    var effortListFilters: [String: AnyCodable] // Desktop app settings
    var tasks: [TaskBase] {
        didSet {
            refreshVersionsContainer()
        }
    }
    var effort: [EffortModel]
    var tags: [TagModel]
    var targetVersions: [TagModel]
    
    private var tasksToEncode: [TasksWrapper] {
        tasks.filter { ($0 as? Milestone)?.isTargetVersionHolder != true }
        .map { TasksWrapper($0) }
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "ProjectID"
        case name = "Name"
        case version = "Version"
        case tasksListFilters = "TasksListFilters"
        case shortcutsListFilters = "ShortcutsListFilters"
        case effortListFilters = "EffortListFilters"
        case tasks = "Tasks"
        case effort = "Effort"
        case tags = "Tags"
        case targetVersions = "TargetVersions"
    }
    
    init(id: String = "", name: String = "") {
        self.id = id
        self.name = name
        version = 1
        tasksListFilters = [:]
        shortcutsListFilters = [:]
        effortListFilters = [:]
        tasks = []
        effort = []
        tags = []
        targetVersions = []
        tasks.append(VersionsContainerModel())
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try? container.decode(String.self, forKey: .name)
        version = try container.decode(Int.self, forKey: .version)
        tasksListFilters = try container.decode([String: AnyCodable].self, forKey: .tasksListFilters)
        shortcutsListFilters = try container.decode([String: AnyCodable].self, forKey: .shortcutsListFilters)
        effortListFilters = try container.decode([String: AnyCodable].self, forKey: .effortListFilters)
        tasks = (try container.decode([TasksWrapper].self, forKey: .tasks)).map { $0.task }
        effort = try container.decode([EffortModel].self, forKey: .effort)
        tags = (try? container.decode([TagModel].self, forKey: .tags)) ?? []
        targetVersions = (try? container.decode([TagModel].self, forKey: .targetVersions)) ?? []
        
        if !tasks.contains (where: { $0.type == .versionsContainer }) {
            tasks.append(VersionsContainerModel())
        }
        
        reuniteFamilies()
        refreshVersionsContainer()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(version, forKey: .version)
        try container.encode(tasksListFilters, forKey: .tasksListFilters)
        try container.encode(shortcutsListFilters, forKey: .shortcutsListFilters)
        try container.encode(effortListFilters, forKey: .effortListFilters)
        try container.encode(tasksToEncode, forKey: .tasks)
        try container.encode(effort, forKey: .effort)
        try container.encode(tags, forKey: .tags)
        try container.encode(targetVersions, forKey: .targetVersions)
    }
    
    func reuniteFamilies() {
        for task in tasks {
            task.findRelatives(tags)
            task.findRelatives(targetVersions)
            task.findRelatives(tasks) // Keep it last
        }
        
        for effort in effort {
            if let parent = tasks.first(where: { $0.id == effort.parentId }) {
                effort.parent = parent
            }
        }
    }
    
    func refreshVersionsContainer() {
        if let vc = tasks.first(where: { $0.type == .versionsContainer }) {
            vc.findRelatives(tasks)
        }
    }
}
