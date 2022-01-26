//
//  VersionsContainerModel.swift
//  Organizer
//
//  Created by mac-1234 on 17/01/2022.
//

import Foundation

class VersionsContainerModel: TaskBase {
    var id: IDTasks
    var status: TaskStatus
    var isCollapsed: Bool
    var children: [TaskBase] = []
    var expandedIds: [IDTags]
    
    var type: TaskType { .versionsContainer }
    var parentId: IDTasks? { get { nil } set {} }
    var parent: TaskBase? { get { nil } set {} }
    var name: String { get { "VersionsContainer".localized } set {  } }
    var description: String { get { "" } set {  } }
    var priority: Int { get { 0 } set {  } }
    var creationTime: Int64 { get { 0 } set { } }
    var estimatedTime: Int64 { get { 0 } set { } }
    var blockers: [TaskBase]? { get { nil } set { } }
    var targetVersion: TagModel? { get { nil } set { } }
    var tags: [TagModel]? { get { nil } set { } }
    var isOnShortcutsList: Bool { get { false } set {  } }
    var isPinned: Bool { get { false } set { } }
    var isContainer: Bool { get { true } set { } }
    
    var targetVersionId: IDTags? { nil }
    var tagsIds: [IDTags]? { nil }
    
    var displayPriority: String {
        ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case type = "Type"
        case status = "Status"
        case isCollapsed = "Collapsed"
        case expandedIds = "ExpandedIds"
    }
    
    init() {
        id = IDTasks()
        status = .active
        isCollapsed = false
        expandedIds = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(IDTasks.self, forKey: .id)
        status = try container.decode(TaskStatus.self, forKey: .status)
        isCollapsed = try container.decode(Bool.self, forKey: .isCollapsed)
        expandedIds = try container.decode([IDTags].self, forKey: .expandedIds)
    }
    
    func encode(to encoder: Encoder) throws {
        expandedIds = children.compactMap { $0.isCollapsed ? nil : $0.targetVersion?.id }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(status, forKey: .status)
        try container.encode(isCollapsed, forKey: .isCollapsed)
        try container.encode(expandedIds, forKey: .expandedIds)
    }
    
    func supportsOperation(_ operation: TaskOperation) -> Bool {
        let supportedOperations: [TaskOperation] = [
            .fosterParenting,
            .togglingStatus
        ]
        return supportedOperations.contains(operation)
    }
    
    func findRelatives(_ tasks: [TaskBase]) {
        var versions = [TagModel: [TaskBase]]()
        if !children.isEmpty { // Without this condition first search will clear loaded list
            expandedIds = children.compactMap { $0.isCollapsed ? nil : $0.targetVersion?.id }
        }
        children.removeAll()
        
        for task in tasks {
            if let targetVersion = task.targetVersion, task.type == .task {
                versions[targetVersion, default: []].append(task)
            }
        }
        
        for (version, tasks) in versions {
            addChild(MilestoneModel(targetVersion: version))
            children.last?.parent = self
            children.last?.isCollapsed = !expandedIds.contains(version.id)
            
            for task in tasks {
                children.last?.addChild(task)
            }
        }
    }    
}
