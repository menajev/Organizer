//
//  TaskBaseData.swift
//  Organizer
//
//  Created by mac-1234 on 17/01/2022.
//

import Foundation

protocol TaskBaseData: AnyObject {
    var id: IDTasks { get set }
    var parent: TaskBase?  { get set }
    var name: String  { get set }
    var description: String  { get set }
    var status: TaskStatus  { get set }
    var priority: Int { get set }
    var creationTime: Int64 { get set }
    var estimatedTime: Int64  { get set }
    var children: [TaskBase] { get set }
    var blockers: [TaskBase]? { get set }
    var targetVersion: TagModel? { get set }
    var tags: [TagModel]? { get set }
    
    var isOnShortcutsList: Bool { get set }
    var isCollapsed: Bool { get set }
    var isPinned: Bool { get set }
    var isContainer: Bool { get set }
    
    var parentId: IDTasks? { get } // TODO: Hide these
    var targetVersionId: IDTags? { get }
    var tagsIds: [IDTags]? { get }
}

class TaskBaseDataImpl : TaskBaseData, Identifiable, Codable {
    var id: IDTasks
    var parent: TaskBase? = nil {
        didSet {
            parentId = parent?.id
        }
    }
    var children: [TaskBase] = [] // TODO: didSet
    var blockers: [TaskBase]? = [] // TODO: didSet
    var name: String = ""
    var description: String = ""
    var status: TaskStatus = .active
    var priority: Int = 0
    var creationTime: Int64 = 0
    var estimatedTime: Int64 = 0
    var targetVersion: TagModel? = nil {
        didSet {
            targetVersionId = targetVersion?.id
        }
    }
    var tags: [TagModel]? = nil {
        didSet {
            tagsIds = tags?.map{ $0.id }
        }
    }
    
    var isOnShortcutsList: Bool = false
    var isCollapsed: Bool = false
    var isPinned: Bool = false
    var isContainer: Bool = false
    
    private(set) var parentId: IDTasks? = nil
    private(set) var targetVersionId: IDTags? = nil
    private(set) var tagsIds: [IDTags]? = nil
    
    init() {
        id = IDTasks()
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case description = "Description"
        case status = "Status"
        case priority = "Priority"
        case creationTime = "CreationTime"
        case estimatedTime = "EstimatedTime"
        case isOnShortcutsList = "ShortcutsList"
        case isCollapsed = "Collapsed"
        case isPinned = "Pinned"
        case isContainer = "Container"
        case parentId = "ParentID"
        case targetVersionId = "TargetVersion"
        case tagsIds = "Tags"
    }
}
