//
//  TasksComparator.swift
//  Organizer
//
//  Created by XCodeClub on 2021-12-02.
//

import Foundation

struct TasksComparator {
    enum ComparedParam {
        case name, priority
        
        var name: String {
            ("ComparedParam." + (self == .name ? "Name" : "Priority")).localized
        }
        
        mutating func toggle() {
            self = (self == .name ? .priority : .name)
        }
    }
    
    var comparedParam: ComparedParam = .name
    var order: SortOrder = .forward
    
    func sort(a: TaskBase, b: TaskBase) -> Bool {
        if a.sortingPriority != b.sortingPriority {
            return a.sortingPriority > b.sortingPriority
        }
        
        let first = order == .forward ? a : b
        let second = order == .forward ? b : a
        
        if comparedParam == .priority {
            return first.priority < second.priority
        }
        return first.name < second.name
    }
}

extension SortOrder {
    var name: String {
        ("SortOrder." + (self == .forward ? "Asc" : "Desc")).localized
    }
    
    mutating func toggle() {
        self = (self == .forward ? .reverse : .forward)
    }
}
