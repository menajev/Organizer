//
//  Milestone.swift
//  Organizer
//
//  Created by mac-1234 on 17/01/2022.
//

import Foundation

protocol Milestone {
    var isTargetVersionHolder: Bool { get }
}

class MilestoneModel: TaskBaseDataImpl, TaskBase, Milestone {
    var type: TaskType { .milestone }
    
    private(set) var isTargetVersionHolder: Bool = false
    var childrenIds: [ID] = []
    var aliases: [Alias] {
        children as! [Alias]
    }
    
    var displayPriority: String {
        let tp = treePriority
        if isTargetVersionHolder {
            return String(tp == -1 ? "" : "\(String(tp))")
        } else if (priority < tp) {
            return "\(String(priority)) \(tp == -1 ? "" : "(\(String(tp))"))"
        } else {
            return String(priority)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type = "Type"
        case childrenIds = "Children"
    }

    init(targetVersion: TagModel) {
        super.init()
        self.targetVersion = targetVersion
        name = targetVersion.name
        isTargetVersionHolder = true
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        childrenIds = try container.decode([ID].self, forKey: .childrenIds)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(children.compactMap { ($0 as? Alias)?.aliasedId }, forKey: .childrenIds)
    }
    
    func supportsOperation(_ operation: TaskOperation) -> Bool {
        let supportedOperations: [TaskOperation] = [
            !isTargetVersionHolder ? .fosterParenting : nil,
            areChildrenCompleted ? .deleting : nil,
            !isTargetVersionHolder ? .editing : nil,
            .editing
        ].compactMap { $0 }
        return supportedOperations.contains(operation)
    }
    
    func addChild(_ child: TaskBase) {
        if !aliases.contains(where: { $0.aliasedId == child.id }) {
            children.append(AliasModel(child))
            children.last?.parent = self
        }
    }
    
    func removeChild(_ child: TaskBase) {
        children.removeAll(where: { ($0 as? Alias)?.aliasedId == child.id })
    }
    
    func findRelatives(_ tasks: [TaskBase]) {
        for childId in childrenIds {
            if let child = tasks.first (where: { $0.id == childId }) {
                addChild(child)
            }
        }
    }
}
