//
//  Alias.swift
//  Organizer
//
//  Created by mac-1234 on 17/01/2022.
//

import Foundation

protocol Alias {
    var aliased: TaskBase { get set }
    var aliasedId: IDTasks { get }
}

class AliasModel: TaskBase, Alias {
    var type: TaskType {
        .alias
    }
    
    var id: IDTasks
    var parentId: IDTasks?
    var parent: TaskBase?
    var aliased: TaskBase
    var aliasedId: IDTasks { aliased.id }
    
    var name: String { get { aliased.name } set { aliased.name = newValue } }
    var description: String { get { aliased.description } set { aliased.description = newValue } }
    var status: TaskStatus { get { aliased.status } set { aliased.status = newValue } }
    var priority: Int { get { aliased.priority } set { aliased.priority = newValue } }
    var creationTime: Int64 { get { aliased.creationTime } set { aliased.creationTime = newValue } }
    var estimatedTime: Int64 { get { aliased.estimatedTime } set { aliased.estimatedTime = newValue } }
    var children: [TaskBase] { get { [] } set { } }
    var blockers: [TaskBase]? { get { aliased.blockers } set { aliased.blockers = newValue } }
    var targetVersion: TagModel? { get { aliased.targetVersion } set { aliased.targetVersion = newValue } }
    var tags: [TagModel]? { get { aliased.tags } set { aliased.tags = newValue } }
    
    var isOnShortcutsList: Bool { get { aliased.isOnShortcutsList } set { aliased.isOnShortcutsList = newValue } }
    var isCollapsed: Bool { get { false } set { } }
    var isPinned: Bool { get { aliased.isPinned } set { aliased.isPinned = newValue } }
    var isContainer: Bool { get { false } set {  } }    
    var targetVersionId: IDTags? { nil }
    var tagsIds: [IDTags]? { nil }
    
    var displayName: String { aliased.displayNameFull }
    
    func supportsOperation(_ operation: TaskOperation) -> Bool {
        let supportedOperations: [TaskOperation] = [
            !isContainer ? .tracking : nil,
            .deleting,
            !isContainer ? .togglingStatus : nil,
            (!isContainer || areChildrenCompleted) ? .markingDone : nil,
            .editing
        ].compactMap { $0 }
        return supportedOperations.contains(operation)
    }
    
    init(_ aliased: TaskBase) {
        self.aliased = aliased
        id = IDTasks()
        parent = nil
    }
}
