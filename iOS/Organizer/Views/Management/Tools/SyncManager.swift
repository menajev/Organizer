//
//  SyncManager.swift
//  Organizer
//
//  Created by mac-1234 on 21/01/2022.
//

import Foundation
import Combine
import SwiftUI

class SyncManager {
    enum Status { case success, failed(message: String), conflicts }
    
    @Published var isWorking: Bool = false
    @Published var hasMergeConflicts: Bool = false
    private(set) var mergeConflictsDescription = ""
    
    private var localProject: ProjectModel?
    private var remoteProject: ProjectModel?
    private let dataSource: ProjectsDataSource
    private var bag = Set<AnyCancellable>()
    
    init() {
        dataSource = ServiceLocator.inject()
    }
    
    func sync(identifier: ProjectIdentifier) -> AnyPublisher<Status, Never> {
        isWorking = true
        localProject = nil
        remoteProject = nil
        
        let id = identifier.id.isEmpty ? (dataSource.currentProject?.id ?? "") : identifier.id
        
        return dataSource.project(withId: id, from: .local)
            .combineLatest(dataSource.project(withId: id, from: .remote))
            .map { [weak self] in self?.merge(local: $0, remote: $1) }
            .flatMap { [weak self] project -> AnyPublisher<String, Never> in
                if let self = self, let project = project {
                    return self.saveAndUploadProject(project)
                } else {
                    return Just("").eraseToAnyPublisher()
                }
            }
            .map { [weak self] error -> Status in
                self?.isWorking = false
                
                if self?.localProject != nil {
                    return .conflicts
                } else if error.isEmpty {
                    return .success
                } else {
                    return .failed(message: error)
                }
            }.eraseToAnyPublisher()
    }
    
    private func merge(local: ProjectModel?, remote: ProjectModel?) -> ProjectModel? {
        if local == nil || remote == nil {
            return local ?? remote
        }
        
        //         git merge should be here
        //         if fail:
        localProject = local
        remoteProject = remote
        
        for project in [local, remote].compactMap({ $0 }) {
            mergeConflictsDescription += "Tasks: \(project.tasks.count) "
            mergeConflictsDescription += "Effort: \(project.tasks.count)"
            
            mergeConflictsDescription += "\n"
        }
        
        return nil
    }
    
    private func saveAndUploadProject(_ project: ProjectModel) -> AnyPublisher<String, Never> {
        dataSource.addProject(project, setAsCurrent: false)
        
        let projectsApi: ProjectsApi = ServiceLocator.inject()
        return projectsApi.uploadProject(project: project)
            .map { return "" }
            .catch { error in Just(error.localizedDescription).eraseToAnyPublisher() }
            .eraseToAnyPublisher()
        
    }
    
    func continueMerge(useLocal: Bool) {
        if let project = useLocal ? localProject : remoteProject, isWorking == false {
            isWorking = true
            
            saveAndUploadProject(project)
                .sink(receiveValue: { [weak self] _ in
                    self?.isWorking = false
                    self?.hasMergeConflicts = false
                }).store(in: &bag)
        }
    }
}
