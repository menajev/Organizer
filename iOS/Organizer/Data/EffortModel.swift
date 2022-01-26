//
//  EffortModel.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-22.
//

import Foundation

class EffortModel: Identifiable, Codable {
    var id: ID = IDTasks()
    var parentId: IDTasks
    var parent: TaskBase? = nil
    var startTime: Int64
    var endTime: Int64
    
    static let ongoingEndTime: Int64 = -1
    
    var isFinished: Bool {
        endTime != EffortModel.ongoingEndTime
    }
    
    var startDate: Date {
        Date(timeIntervalSince1970: TimeInterval(startTime / 1000))
    }
    
    var endDate: Date {
        Date(timeIntervalSince1970: TimeInterval(endTime / 1000))
    }
    
    // TODO: try automated uppercase
    enum CodingKeys: String, CodingKey {
        case parentId = "ParentID"
        case startTime = "StartTime"
        case endTime = "EndTime"
    }
    
    init() {
        parentId = IDTasks.invalid()
        startTime = Date(timeIntervalSinceNow: -6400).millisecondsSince1970
        endTime = Date().millisecondsSince1970
    }
    
    init(parent: TaskBase) {
        self.parent = parent
        parentId = parent.id
        startTime = Date().millisecondsSince1970
        endTime = EffortModel.ongoingEndTime
    }
}

extension Date { // TODO: Move to extensions
    var millisecondsSince1970: Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}

