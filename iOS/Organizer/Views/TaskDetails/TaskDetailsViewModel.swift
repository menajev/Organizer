//
//  TaskDetailsViewModel.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-30.
//

import Foundation
import Combine

class TaskDetailsViewModel: ObservableObject {
    @Published var name: String
    @Published var description: String
    @Published var priority: Int
    @Published var targetVersion: TagModel?
    @Published var estimatedTime: String
    @Published var isActive: Bool
    @Published var isOnShortcutsList: Bool
    @Published var isPinned: Bool
    @Published var isContainer: Bool
    @Published var targetVersions: [TagModel]
    
    @Published var creatingChild = false
    @Published var selectingTags = false
    @Published var errorMessage = ""
    
    private(set) var task: TaskBase
    let taskCreation: Bool
    let tagsViewModel: TagsViewModel
    
    private let emptyTargetVersion: TagModel
    private var bag = Set<AnyCancellable>()
    
    init(task: TaskBase? = nil, parent: TaskBase? = nil) {
        taskCreation = task == nil
        
        let task = (task as? Alias)?.aliased ?? task ?? TaskModel()
        self.task = task
        
        if taskCreation {
            self.task.parent = parent
        }
        
        name = task.name
        description = task.description
        priority = task.priority
        targetVersion = task.targetVersion
        estimatedTime = TimeFormatter.estimatedTime(from: task.estimatedTime)
        isActive = task.isActive
        isOnShortcutsList = task.isOnShortcutsList
        isPinned = task.isPinned
        isContainer = task.isContainer
        
        tagsViewModel = TagsViewModel(multiSelection: true, selectedTags: task.tags)
        emptyTargetVersion = TagModel(name: "(none)".localized, description: nil)
        
        let dataSource: ProjectsDataSource = ServiceLocator.inject()
        targetVersions = [emptyTargetVersion]
        targetVersions.append(contentsOf: dataSource.targetVersions)
    }
    
    func supports(_ operation: TaskOperation) -> Bool {
        if operation == .togglingStatus && task.status.isDone { // TODO: 'Activate' button for this scenario
            return false
        }
        return task.supportsOperation(operation)
    }
    
    func save() -> Bool {
        if name.isEmpty {
            errorMessage = "Error.NameEmpty".localized
            return false
        }
        
        task.name = name
        task.description = description
        task.priority = priority
        task.targetVersion = targetVersion != emptyTargetVersion ? targetVersion : nil
        task.tags = tagsViewModel.selectedTags
        task.estimatedTime = TimeFormatter.estimatedTime(from: estimatedTime)
        if task.status != .done {
            task.status = isActive ? .active : .inactive
        }
        task.isOnShortcutsList = isOnShortcutsList
        task.isPinned = isPinned
        task.isContainer = isContainer
        
        task.parent?.addChild(task)
        
        let dataSource: ProjectsDataSource = ServiceLocator.inject()
        dataSource.addOrReplaceTask(task)
        
        return true
    }
    
    func createChild() {
        creatingChild = true
    }
    
    func selectTags() {
        selectingTags = true
    }
}
