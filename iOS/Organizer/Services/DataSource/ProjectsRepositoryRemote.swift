//
//  ProjectsRepositoryRemote.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-28.
//

import Foundation
import Combine

class ProjectsRepositoryRemote: ProjectsRepository {
    let projectsApi: ProjectsApi
    
    init() {
        projectsApi = ServiceLocator.inject()
    }
    
    func loadProject(withId projectId: String) -> AnyPublisher<ProjectModel, Error> {
        return projectsApi.project(projectId: projectId)
            .eraseToAnyPublisher()
    }
    
    func loadProjectsList() -> AnyPublisher<ProjectsList, Error> {
        projectsApi.projectsList()
            .map { $0.map { ProjectIdentifier(id: $0.id ?? "", name: $0.name ?? "") } }
            .eraseToAnyPublisher()
    }
    
    func saveProject(_ project: ProjectModel) -> Future<Void, Error> {
        Future() { promise in promise(.success(()))}
    }
    
    func deleteProject(id: String) {
        
    }
}
