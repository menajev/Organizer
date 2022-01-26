//
//  ProjectsRepositoryLocal.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-28.
//

import Foundation
import Combine
import Alamofire
import OSLog

// TODO: Rename ProjectsRepository- to Repository-?

class ProjectsRepositoryLocal: ProjectsRepository {
    private var projectsList = [String]()
    
    private func path(for list: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appendingPathComponent(list)
    }
    
    func loadProject(withId id: String) -> AnyPublisher<ProjectModel, Error> {
        var projectModel: ProjectModel?
        var er: Error?

//        let path = URL(fileURLWithPath: Bundle.main.path(forResource: "Osobiste", ofType:"txt")!); if true { // TODO: Debug
        if let path = path(for: id) {
            do {
                let jsonData = try Data(contentsOf: path)
                let project = try JSONDecoder().decode(ProjectModel.self, from: jsonData)
                projectModel = project
                os_log("Loaded project path:\n\(path)")
            } catch {
                er = error
            }
        }
        
        if let projectModel = projectModel {
            return Just<ProjectModel>(projectModel)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: er!).eraseToAnyPublisher()
        }
    }
    
    func loadProjectsList() -> AnyPublisher<ProjectsList, Error> {
        Future<ProjectsList, Error>() { [weak self] promise in
            let list = self?.loadSettings().projectsList
                .map { ProjectIdentifier(id: $0, name: $0) } // TODO: Store both id & name
            promise(.success(list ?? []))
        }.eraseToAnyPublisher()
    }
    
    func saveProject(_ project: ProjectModel) -> Future<Void, Error> {
        if projectsList.first(where: { $0 == project.id }) == nil {
            projectsList.append(project.id)
        }
        
        return Future() { [weak self] promise in
            do {
                if let url = self?.path(for: project.id) {
                    let jsonData = try JSONEncoder().encode(project)
                    try jsonData.write(to: url)
                    promise(.success(()))
                }
            } catch {
                promise(.failure(error))
            }
        }
    }
    
    func deleteProject(id: String) {
        if let path = path(for: id) {
            try? FileManager.default.removeItem(atPath: path.path)
        }
        projectsList.removeAll(where: { $0 == id })
    }
}

extension ProjectsRepositoryLocal: SettingsRepository {
    func saveSettings(_ settings: SettingsModel) {
        if var url = path(for: "Config") {
            do {
                if !FileManager.default.fileExists(atPath: url.absoluteString) {
                    try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
                }
                url.appendPathComponent("Settings")
                let jsonData = try JSONEncoder().encode(settings)
                try jsonData.write(to: url)
            } catch {
                print(error)
            }
        }
    }
    
    func loadSettings() -> SettingsModel {
        do {
            if let path = path(for: "Config/Settings") {
                let jsonData = try Data(contentsOf: path)
                let model = try JSONDecoder().decode(SettingsModel.self, from: jsonData)
                return model
            }
        } catch {
            print(error)
        }
        return SettingsModel()
    }
}
