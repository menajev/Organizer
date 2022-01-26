//
//  Data.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-19.
//

import Foundation

typealias IdRaw = Int64

class ID: Hashable, Codable, Equatable {
    private static var idsInUse: [String: [IdRaw: Int]] = [:]
    static var invalidId: IdRaw = -1
    
    var group: String { "" }
    var val: IdRaw {
        willSet {
            guard val != newValue else { return }
            
            if val != Self.invalidId {
                ID.idsInUse[group, default: [:]][val, default: 0] -= 1
            }
            if newValue != Self.invalidId {
                ID.idsInUse[group, default: [:]][newValue, default: 0] += 1
            }
        }
    }
    
    var isValid: Bool {
        val != Self.invalidId
    }
    
    init() {
        val = ID.invalidId
        defer { val = findValue() }
    }
    
    init(_ id: IdRaw) {
        val = ID.invalidId
        defer { val = id }
    }
    
    required init(from decoder: Decoder) {
        val = ID.invalidId
        defer { val = (try? decoder.singleValueContainer().decode(IdRaw.self)) ?? IDTasks.invalidId }
    }
    
    deinit { val = ID.invalidId }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(val)
    }
    
    func invalidate() {
        val = ID.invalidId
    }
    
    internal func findValue() -> IdRaw {
        let inUse = ID.idsInUse[group, default: [:]]
        var newVal: IdRaw = 1
        while inUse[newVal] != nil && inUse[newVal] != 0 {
            newVal += 1
        }
        return newVal
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(group)
        hasher.combine(val)
    }
    
    static func ==(lhs: ID, rhs: ID) -> Bool {
        return lhs.group == rhs.group && lhs.val == rhs.val
    }
    
    static func !=(lhs: ID, rhs: ID) -> Bool {
        return !(lhs == rhs)
    }
}

class IDTasks: ID {
    override var group: String { "Tasks" }
    
    static func invalid() -> IDTasks {
        IDTasks(ID.invalidId)
    }
}

class IDTags: ID {
    override var group: String { "Tags" }
    
    static func invalid() -> IDTags {
        IDTags(ID.invalidId)
    }
}
