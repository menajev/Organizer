//
//  TaskModel.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-19.
//

import Foundation

enum TaskStatus: String, Codable {
    case active = "Active"
    case inactive = "Inactive"
    case done = "Done"
    case archived = "Archived" // archived - removed task kept due to effort history
    
    var isActive: Bool { self == .active }
    var isInactive: Bool { self == .inactive }
    var isDone: Bool { self == .done }
    
    mutating func toggleActive() {
        if self == .active {
            self = .inactive
        } else {
            self = .active
        }
    }
}

class TaskModel: TaskBaseDataImpl, TaskBase {
    var type: TaskType { .task }
    
    enum CodingKeys: String, CodingKey {
        case type = "Type"
    }
    
    override init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
    }
    
    func supportsOperation(_ operation: TaskOperation) -> Bool {
        let supportedOperations: [TaskOperation] = [
            !isContainer ? .tracking : nil,
            .parenting,
            .fosterParenting,
            (!isContainer || areChildrenCompleted) ? .deleting : nil,
            !isContainer ? .togglingStatus : nil,
            (!isContainer || areChildrenCompleted) ? .markingDone : nil,
            !isContainer ? .shortcuting : nil,
            .editing,
            .editingIsContainer,
            .editingPriority
        ].compactMap { $0 }
        return supportedOperations.contains(operation)
    }
}
