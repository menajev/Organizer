//
//  TasksListViewModel.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-21.
//

import Foundation
import Combine

class TasksListViewModel: ObservableObject {
    @Published var tasks: [(task: TaskBase, isCollapsable: Bool)]
    @Published var filters: TasksListFilters
    @Published var comparator = TasksComparator()
    @Published var trackedTask: TaskBase?
    private let dataSource: ProjectsDataSource
    private var bag = Set<AnyCancellable>()
    
    var flatStructure: Bool {
        return !filters.searchText.isEmpty || filters.shortcutsListOnly
    }
    
    var activeMasterTask: TaskBase? {
        if filters.masterTaskActive {
            return filters.masterTask
        }
        return nil
    }
    
    init(filters: TasksListFilters = TasksListFilters()) {
        tasks = []
        self.filters = filters
        
        dataSource = ServiceLocator.inject()
        dataSource.$tasks
            .combineLatest($filters, $comparator)
            .map { [weak self] tasks, filters, comparator in
                if self?.flatStructure ?? false {
                    return tasks.filter { filters.shouldShowTask($0) } .sorted(by: comparator.sort).map { ($0, false) }
                } else {
                    var tree = [(task: TaskBase, isCollapsable: Bool)]()
                    for task in tasks.sorted(by: comparator.sort) {
                        if ((task.parent?.id ?? IDTasks.invalid()) == IDTasks.invalid() && filters.shouldShowTask(task))
                            || filters.isActiveMaster(task: task) {
                            self?.addTasksFamily(task,
                                                 toList: &tree,
                                                 withFilters: filters,
                                                 andComparator: comparator)
                        }
                    }
                    return tree
                }
            }.sink { [weak self] in
                self?.tasks = $0
            }.store(in: &bag)
        
        dataSource.$ongoingEffort
            .sink(receiveValue: { [weak self] in
                self?.trackedTask = $0?.parent
            }).store(in: &bag)
    }
    
    func addTasksFamily(_ task: TaskBase,
                        toList list: inout [(task: TaskBase, isCollapsable: Bool)],
                        withFilters filters: TasksListFilters,
                        andComparator comparator: TasksComparator) {
        let children = task.children.filter { filters.shouldShowTask($0) }.sorted(by: comparator.sort)
        
        if !filters.isActiveMaster(task: task) {
            list.append((task, !children.isEmpty))
            guard !task.isCollapsed else { return }
        }
        
        for child in children {
            addTasksFamily(child, toList: &list, withFilters: filters, andComparator: comparator)
        }
    }
    
    func isTaskTracked(_ task: TaskBase) -> Bool {
        task == trackedTask
    }
    
    func toggleTaskTracking(_ task: TaskBase) {
        let wasTaskTracked = isTaskTracked(task)
        if let ongoing = dataSource.ongoingEffort {
            ongoing.endTime = Date().millisecondsSince1970
            dataSource.addOrReplaceEffort(ongoing)
        }
        if !wasTaskTracked {
            let effort = EffortModel(parent: task)
            dataSource.addOrReplaceEffort(effort)
        }
    }
    
    func toggleTaskActive(_ task: TaskBase) {
        task.status.toggleActive()
        dataSource.addOrReplaceTask(task)
    }
    
    func taskDone(_ task: TaskBase) {
        if isTaskTracked(task) {
            toggleTaskTracking(task)
        }
        task.status = .done
        dataSource.addOrReplaceTask(task)
    }
    
    func deleteTask(_ task: TaskBase) {
        dataSource.deleteTask(task)
    }
}
