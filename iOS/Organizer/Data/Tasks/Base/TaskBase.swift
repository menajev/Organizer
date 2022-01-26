//
//  TasksBase.swift
//  Organizer
//
//  Created by mac-1234 on 17/01/2022.
//

import Foundation

enum TaskType: String, Codable {
    case task = "Task"
    case milestone = "Milestone"
    case alias = "Alias"
    case versionsContainer = "VersionsContainer"
}

enum TaskOperation {
    case tracking,
         parenting,
         fosterParenting,
         deleting,
         togglingStatus,
         markingDone,
         shortcuting,
         editing,
         editingPriority,
         editingIsContainer
}

protocol TaskBase : TaskBaseData, TaskBaseCalculation {
    var type: TaskType { get }
}

protocol TaskBaseCalculation {
    var isBlocked: Bool { get }
    var isActive: Bool { get }
    var treePriority: Int { get }
    
    var displayName: String { get }
    var displayNameFull: String { get }
    var displayNamePath: String { get }
    var displayDescription: String { get }
    var displayPriority: String { get }
    var sortingPriority: Int { get }
    
    var areChildrenCompleted: Bool { get }
    
    func supportsOperation(_ operation: TaskOperation) -> Bool
    
    func addChild(_ child: TaskBase)
    func removeChild(_ child: TaskBase)
    func findRelatives(_ tasks: [TaskBase])
    func findRelatives(_ tags: [TagModel])
    
    func isSuccessor(ofTask task: TaskBase) -> Bool
    func isPredecessor(ofTask task: TaskBase) -> Bool
}

extension TaskBase  {
    var isBlocked: Bool { !(blockers?.isEmpty ?? true) }
    var isActive: Bool { status == .active}
    
    var treePriority: Int {
        var maxPriority = priority
        for child in children {
            maxPriority = max(maxPriority, child.treePriority)
        }
        return maxPriority
    }
    
    var displayName: String { name }
    var displayNameFull: String { name + ((parent != nil) ? " (\(parent?.displayNamePath ?? ""))" : "") }
    var displayNamePath: String { (parent != nil ? ((parent?.displayNamePath ?? "") + " / ") : "") + displayName }
    var displayDescription: String { description }
    var displayPriority: String { String(priority) }
    var sortingPriority: Int {
        if type == .versionsContainer {
            return isActive ? 10 : -1
        } else if isPinned {
            return 9
        } else if type == .milestone {
            return 8
        } else {
            return 0
        }
    }
    
    var areChildrenCompleted: Bool {
        for child in children {
            if child.status == .active || child.status == .inactive {
                return false
            }
        }
        return true
    }
    
    func addChild(_ child: TaskBase) {
        if !children.contains(where: { $0.id == child.id }) {
            children.append(child)
        }
    }
    
    func removeChild(_ child: TaskBase) {
        children.removeAll(where: { $0.id == child.id })
    }
    
    func findRelatives(_ tasks: [TaskBase]) {
        if parentId?.isValid ?? false {
            parent = tasks.first(where: { $0.id == parentId })
            parent?.addChild(self)
        }
    }
    
    func findRelatives(_ tags: [TagModel]) {
        if let tvId = targetVersionId, let tv = tags.first(where: { $0.id == tvId }) {
            targetVersion = tv
        }
        for tagId in tagsIds ?? [] {
            if let tag = tags.first(where: { $0.id == tagId }) {
                self.tags = self.tags ?? []
                self.tags?.append(tag)
            }
        }
    }
    
    func isSuccessor(ofTask task: TaskBase) -> Bool {
        task == parent || (parent?.isSuccessor(ofTask: task) ?? false)
    }
    
    func isPredecessor(ofTask task: TaskBase) -> Bool {
        for child in children {
            if task == child || child.isPredecessor(ofTask: task) {
                return true
            }
        }
        return false
    }
}

func ==(lhs: TaskBase, rhs: TaskBase) -> Bool {
    return lhs.id == rhs.id
}

func !=(lhs: TaskBase, rhs: TaskBase) -> Bool {
    return !(lhs == rhs)
}

// TODO: Clean if possibly

func ==(lhs: TaskBase, rhs: TaskBase?) -> Bool {
    return lhs.id == rhs?.id
}

func !=(lhs: TaskBase, rhs: TaskBase?) -> Bool {
    return !(lhs == rhs)
}
