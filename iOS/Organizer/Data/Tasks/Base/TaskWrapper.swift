//
//  TaskWrapper.swift
//  Organizer
//
//  Created by mac-1234 on 17/01/2022.
//

import Foundation

enum Errors: Error { // TODO: Move elesewhere
    case decodeError
}

internal extension ProjectModel {
    struct TasksWrapper: Codable {
        var task: TaskBase
        
        private enum CodingKeys: String, CodingKey {
            case type = "Type"
        }
        
        init(_ task: TaskBase) {
            self.task = task
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(TaskType.self, forKey: .type)
            
            switch type {
            case .task: task = try TaskModel(from: decoder)
            case .milestone: task = try MilestoneModel(from: decoder)
            case .alias: throw Errors.decodeError
            case .versionsContainer: try task = VersionsContainerModel(from: decoder)
            }
        }
        
        func encode(to encoder: Encoder) throws {
            switch task.type { // Why casting?
            case .task: try (task as! TaskModel).encode(to: encoder)
            case .milestone: try (task as! MilestoneModel).encode(to: encoder)
            case .alias: break
            case .versionsContainer: try (task as! VersionsContainerModel).encode(to: encoder)
            }
        }
    }
}
