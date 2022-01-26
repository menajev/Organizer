//
//  ProjectsDataSource.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-28.
//

import Foundation
import Combine

typealias ProjectsList = [ProjectIdentifier]

protocol ProjectsRepository {
    func loadProject(withId: String) -> AnyPublisher<ProjectModel, Error>
    func loadProjectsList() -> AnyPublisher<ProjectsList, Error>
    func saveProject(_ project: ProjectModel) -> Future<Void, Error>
    func deleteProject(id: String)
}

protocol SettingsRepository {
    func saveSettings(_ settings: SettingsModel)
    func loadSettings() -> SettingsModel
}

class ProjectsDataSource: ObservableObject {
    enum Source: Int { case local = 0, remote, syncCopy }
    
    @Published private(set) var currentProject: ProjectModel? {
        didSet {
            settings.currentProject = currentProject?.id
            tasks = currentProject?.tasks ?? []
            effort = currentProject?.effort.sorted(by: { $0.startTime > $1.endTime }) ?? []
            tags = currentProject?.tags.sorted(by: { $0.name < $1.name }) ?? []
            targetVersions = currentProject?.targetVersions.sorted(by: { $0.name < $1.name }) ?? []
            ongoingEffort = effort.first(where: { !$0.isFinished })
        }
    }
    @Published private(set) var projects: [String] // TODO: Use ProjectIdentifier
    @Published private(set) var tasks: [TaskBase]
    @Published private(set) var effort: [EffortModel]
    @Published private(set) var tags: [TagModel]
    @Published private(set) var targetVersions: [TagModel]
    @Published private(set) var ongoingEffort: EffortModel?
    
    private let localRepository: ProjectsRepository & SettingsRepository
    private let remoteRepository: ProjectsRepository
    private var settings: SettingsModel
    private var bag = Set<AnyCancellable>()
    
    init() {
        projects = []
        tasks = []
        effort = []
        tags = []
        targetVersions = []
        localRepository = ProjectsRepositoryLocal()
        remoteRepository = ProjectsRepositoryRemote()
        settings = localRepository.loadSettings()
        projects = settings.projectsList // TODO: Not nice
        
        localRepository.loadProject(withId: settings.currentProject ?? projects.first ?? "")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { [weak self] project in
                self?.currentProject = project
            }).store(in: &bag)
        
        //        remoteRepository.project()
        //            .sink(receiveCompletion: { completion in
        //                if case .failure(let error) = completion {
        //                    print(error)
        //                }
        //            }, receiveValue: { [weak self] projects in
        //                self?.remoteProjects = projects
        //            }).store(in: &bag)
        
        $projects.sink(receiveValue: { [weak self] in self?.settings.projectsList = $0 }).store(in: &bag)
    }
    
    // Projects
    
    func selectProject(withId id : String) {
        guard !id.isEmpty && currentProject?.id != id else { return }
        localRepository.loadProject(withId: id)
            .sink(receiveCompletion: { _ in }, // TODO: Hnadle project missing
                  receiveValue: { [weak self] project in
                self?.currentProject = project
            }).store(in: &bag)
    }
    
    func project(withId id: String, from source: Source) -> AnyPublisher<ProjectModel?, Never> {
        if source == .local {
            return localRepository.loadProject(withId: id)
                .map(Optional.some)
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        } else {
            return remoteRepository.loadProject(withId: id)
                .map(Optional.some)
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        // TODO: Sync copy
    }
    
    func addProject(_ project: ProjectModel, setAsCurrent: Bool = true) {
        if !projects.contains(where: { $0 == project.id }) {
            projects.append(project.id)
        }
        
        localRepository.saveProject(project).sink(receiveCompletion: { _ in }, receiveValue: {}).store(in: &bag)
        
        if setAsCurrent || currentProject?.id == project.id {
            currentProject = project
        }
        
        saveSettings()
    }
    
    func editCurrentProject(name: String, id: String) {
        guard currentProject != nil else { return }
        currentProject?.name = name
        currentProject?.id = id
        saveCurrentProject()
    }
    
    func deleteCurrentProject() {
        if let id = currentProject?.id {
            localRepository.deleteProject(id: id)
            selectProject(withId: projects.first ?? "")
            projects.removeAll(where: { $0 == id})
            saveSettings()
        }
    }
    
    func saveCurrentProject() {
        if let currentProject = currentProject {
            localRepository.saveProject(currentProject).sink(receiveCompletion: { _ in }, receiveValue: {}).store(in: &bag)
        }
    }
    
    func allProjectsList() -> AnyPublisher<[ProjectsList], Error> {
        localRepository.loadProjectsList()
            .combineLatest(remoteRepository.loadProjectsList())
            .map { local, remote in
                [local, remote]
            }.eraseToAnyPublisher()
    }
    
    // Tasks
    
    func addOrReplaceTask(_ task: TaskBase) {
        if let index = currentProject?.tasks.firstIndex(where: { $0.id == task.id }) {
            currentProject?.tasks.replaceSubrange(index...index, with: [task])
        } else {
            currentProject?.tasks.append(task)
        }
        saveCurrentProject()
    }
    
    func deleteTask(_ task: TaskBase) {
        if false { //task.hasEffort { // TODO
            task.status = .archived
            addOrReplaceTask(task)
        } else {
            currentProject?.tasks.removeAll(where: { $0.id == task.id })
            saveCurrentProject()
            // Todo: remove children
        }
    }
    
    // Effort
    
    func addOrReplaceEffort(_ model: EffortModel) {
        if let index = currentProject?.effort.firstIndex(where: { $0.id == model.id }) {
            currentProject?.effort.replaceSubrange(index...index, with: [model])
        } else {
            currentProject?.effort.append(model)
        }
        saveCurrentProject()
    }
    
    // Tags
    
    private func addOrReplaceTag(_ model: TagModel, tagsArray: inout [TagModel]) {
        if let index = tagsArray.firstIndex(where: { $0.id == model.id }) {
            tagsArray.replaceSubrange(index...index, with: [model])
        } else {
            tagsArray.append(model)
        }
        saveCurrentProject()
    }
    
    func addOrReplaceTag(_ model: TagModel, type: TagModel.TagType) {
        guard currentProject != nil else { return }
        if type == .tag { // TODO: Not perfect
            addOrReplaceTag(model, tagsArray: &currentProject!.tags)
        } else {
            addOrReplaceTag(model, tagsArray: &currentProject!.targetVersions)
        }
    }
    
    func deleteTag(_ tag: TagModel, type: TagModel.TagType) {
        if type == .tag {
            currentProject?.tags.removeAll(where: { $0.id == tag.id })
        } else {
            currentProject?.targetVersions.removeAll(where: { $0.id == tag.id })
        }
        saveCurrentProject()
    }
    
    // Settings
    
    func saveSettings() {
        localRepository.saveSettings(settings)
    }
}
