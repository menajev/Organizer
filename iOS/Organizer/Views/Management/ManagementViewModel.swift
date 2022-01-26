//
//  ManagementViewModel.swift
//  Organizer
//
//  Created by XCodeClub on 2021-12-13.
//

import Foundation
import Combine

class ManagementViewModel: ObservableObject {
    @Published var projects: [String] = [] // TODO: Clean this list
    @Published var currentProject = ""
    @Published var serverUrl = ""
    @Published var isLoggedIn: Bool = false
    @Published var login = ""
    @Published var password = ""
    @Published var showingActivityIndicator = false
    @Published var showingMergeScreen = false
    @Published var syncCompletedSuccessfully = false    
    @Published var allProjectsList: ProjectsList = []
    @Published var syncSelectedProject = ProjectIdentifier(id: "", name: "(Current)") {
        didSet {
            syncCompletedSuccessfully = false
        }
    }
    let syncManager: SyncManager
    
    private let dataSource: ProjectsDataSource
    private var bag = Set<AnyCancellable>()
    
    var currentProjectName: String {
        dataSource.currentProject?.name ?? ""
    }
    
    var currentProjectId: String {
        dataSource.currentProject?.id ?? ""
    }
    
    init() {
        dataSource = ServiceLocator.inject()
        syncManager = SyncManager()
        
        syncManager.$isWorking.assign(to: &$showingActivityIndicator)
        syncManager.$hasMergeConflicts.assign(to: &$showingMergeScreen)
        
        dataSource.$projects
            .sink(receiveValue: { [weak self] in
                self?.currentProject = self?.dataSource.currentProject?.id ?? ""
                self?.projects = $0
            }).store(in: &bag)
        
        $currentProject
            .sink(receiveValue: { [weak self] id in
                self?.dataSource.selectProject(withId: id)
            }).store(in: &bag)
        
        dataSource.allProjectsList().sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print(error)
                }
            },
            receiveValue: { [weak self] list in
                var projects = list[ProjectsDataSource.Source.local.rawValue]
                let remote = list[ProjectsDataSource.Source.remote.rawValue]
                for id in remote {
                    if !projects.contains(where: { $0.id == id.id }) {
                        projects.append(id)
                    }
                }
                
                self?.allProjectsList.append(ProjectIdentifier(id: "", name: "(Current)"))
                self?.allProjectsList.append(contentsOf: projects)
            }).store(in: &bag)
        
        let apiClient: ApiClient = ServiceLocator.inject()
        apiClient.isLoggedIn.sink(receiveValue: { [weak self] in self?.isLoggedIn = $0 }).store(in: &bag)
        serverUrl = apiClient.basePath ?? ""
    }
    
    func createNewProject(_ name: String, id: String) -> String? {
        guard !name.isEmpty && !id.isEmpty else { return "Error.FieldsEmpty".localized }
        guard projects.first(where: { $0 == id }) == nil else { return "Error.ProjectIdInUse".localized }
        
        dataSource.addProject(ProjectModel(id: id, name: name))
        
        return nil
    }
    
    func editCurrentProject(name: String, id: String) -> String? {
        guard !name.isEmpty && !id.isEmpty else { return "Error.FieldsEmpty".localized }
        guard currentProjectId == id || projects.first(where: { $0 == id }) == nil else { return "Error.ProjectIdInUse".localized }
        
        dataSource.editCurrentProject(name: name, id: id)
        
        return nil
    }
    
    func deleteCurrentProject() {
        dataSource.deleteCurrentProject()
    }
    
    func performLogin() {
        guard !serverUrl.isEmpty && !login.isEmpty && !password.isEmpty else { return }
        let userApi: UserApi = ServiceLocator.inject()
        userApi.login(loginRequest: LoginRequest(login: login, password: password),
                      serverUrl: serverUrl)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): NSLog(error.localizedDescription)
                }
            }, receiveValue: {})
            .store(in: &bag)
    }
    
    func performLogout() {
        let userApi: UserApi = ServiceLocator.inject()
        userApi.logout()
        password = ""
    }
    
    func sync() {
        syncManager.sync(identifier: syncSelectedProject)
            .sink(receiveValue: { [weak self] status in
                switch status {
                case .success: self?.syncCompletedSuccessfully = true
                case .conflicts: self?.showingMergeScreen = true
                case .failed: break // TODO: Show error
                }
            }).store(in: &bag)
    }
}
