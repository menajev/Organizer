//
//  TasksListSettings.swift
//  Organizer
//
//  Created by XCodeClub on 2021-12-03.
//

import Foundation

class TasksListSettings: ObservableObject {
    var flatStucture: Bool
    var shortcutsMarkerVisible: Bool
    var hideNewTaskButton: Bool
    var hideMasterTaskFilter: Bool
    var forceHideDoneTasks: Bool    
    
    init(flatStucture: Bool,
         shortcutsMarkerVisible: Bool,
         hideNewTaskButton: Bool,
         hideMasterTaskFilter: Bool,
         forceHideDoneTasks: Bool
    ) {
        self.flatStucture = flatStucture
        self.shortcutsMarkerVisible = shortcutsMarkerVisible
        self.hideNewTaskButton = hideNewTaskButton
        self.hideMasterTaskFilter = hideMasterTaskFilter
        self.forceHideDoneTasks = forceHideDoneTasks
    }
    
    static var main: TasksListSettings {
        TasksListSettings(flatStucture: false,
                          shortcutsMarkerVisible: true,
                          hideNewTaskButton: false,
                          hideMasterTaskFilter: false,
                          forceHideDoneTasks: false)
    }
    
    static var shortcutsList: TasksListSettings {
        TasksListSettings(flatStucture: true,
                          shortcutsMarkerVisible: false,
                          hideNewTaskButton: true,
                          hideMasterTaskFilter: true,
                          forceHideDoneTasks: true)
    }
}
