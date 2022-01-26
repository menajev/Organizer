//
//  TasksListFilters.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-29.
//

import Foundation
import Combine // Remove after extension moved

struct TasksListFilters {
    var hideDone = false
    var hideInactive = false
    var hideBlocked = false
    var shortcutsListOnly = false
    var minPriority = -1
    var searchText = ""
    var masterTask: TaskBase? = nil
    var masterTaskActive = false
  
    func shouldShowTask(_ task: TaskBase) -> Bool {
        if task.status == .archived { return false }
        if hideDone && task.status.isDone { return false }
        if hideInactive && task.status.isInactive { return false }
        if hideBlocked && task.isBlocked { return false }
        if shortcutsListOnly && task.isOnShortcutsList == false { return false }
        if minPriority > -1 && minPriority > task.priority { return false }
        
        if !searchText.isEmpty
            && (task.name.lowercased().contains(searchText.lowercased())
                || task.description.lowercased().contains(searchText.lowercased())) {
            return false
        }
        
        if let masterTask = masterTask, masterTaskActive && task != masterTask && !task.isSuccessor(ofTask: masterTask) {
            return false
        }
        
        return true
    }
    
    func isActiveMaster(task: TaskBase) -> Bool {
        masterTaskActive && task == masterTask
    }
}

// TODO: Move to extensions
extension Published.Publisher {
    var didSet: AnyPublisher<Value, Never> {
        self.receive(on: RunLoop.main).eraseToAnyPublisher()
    }
}
