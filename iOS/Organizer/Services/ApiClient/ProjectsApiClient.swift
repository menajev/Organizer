//
//  ProjectsApiClient.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-24.
//

import Foundation
import Combine
import Alamofire

protocol ProjectsApi {
    func projectsList() -> AnyPublisher<[ProjectIdentifierResponse], Error>
    func project(projectId: String) -> AnyPublisher<ProjectModel, Error>
    func uploadProject(project: ProjectModel) -> AnyPublisher<Void, Error>
}

extension ApiClient: ProjectsApi {
    static private let projectsEndpoint = "/"
    
    func projectsList() -> AnyPublisher<[ProjectIdentifierResponse], Error> {
        request(ApiClient.projectsEndpoint,
                method: .get,
                parameters: emptyParams)
            .decode(type: [ProjectIdentifierResponse].self, decoder: JSONDecoder()).eraseToAnyPublisher()
    }
    
    func project(projectId: String) -> AnyPublisher<ProjectModel, Error> {
        request(ApiClient.projectsEndpoint,
                method: .get,
                parameters: GetProjectsRequest(projectId: projectId))
            .decode(type: ProjectModel.self, decoder: JSONDecoder()).eraseToAnyPublisher()
    }
    
    func uploadProject(project: ProjectModel) -> AnyPublisher<Void, Error> {
        request(ApiClient.projectsEndpoint,
                method: .post,
                parameters: project,
                encoder: JSONParameterEncoder.default)
            .map { _ in
                ()                
            }
            .eraseToAnyPublisher()
    }
}
