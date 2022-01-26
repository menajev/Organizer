//
//  TasksListCellViewModel.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-19.
//

import Foundation

class TasksListCellViewModel: ObservableObject {
    @Published var task: TaskBase
    let isCollapsable: Bool
    let settings: TasksListSettings
    
    init(_ task: TaskBase, isCollapsable: Bool, settings: TasksListSettings) {
        self.task = task
        self.isCollapsable = isCollapsable
        self.settings = settings
    }
    
    var name: String {
        settings.flatStucture ? task.displayNameFull : task.displayName
    }
    
    var priority: String {
        task.displayPriority
    }
    
    var shortcutsList: String {
        task.isOnShortcutsList && settings.shortcutsMarkerVisible ? ("TasksListCell.ShortcutsSymbol".localized + " ") : ""
    }
    
    var collapsed: String {
        task.isCollapsed ? "TasksListCell.Expand".localized : "TasksListCell.Collapse".localized
    }
    
    var indent: Float {
        settings.flatStucture ? 0.0 : indentForTask(task)
    }
    
    private func indentForTask(_ task: TaskBase) -> Float {
        if let parent = task.parent {
            return 10.0 + indentForTask(parent)
        } else {
            return 0.0
        }
    }
    
    func toggleCollapsed() {
        task.isCollapsed.toggle()
        let dataSource: ProjectsDataSource = ServiceLocator.inject()
        dataSource.addOrReplaceTask(task)
    }
}
