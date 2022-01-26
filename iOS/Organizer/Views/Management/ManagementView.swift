//
//  ManagementView.swift
//  Organizer
//
//  Created by XCodeClub on 2021-12-13.
//

import SwiftUI

struct ManagementView: View {
    @ObservedObject private var viewModel = ManagementViewModel()
    @State private var showingCreateNewProject = false
    @State private var showingEditProject = false
    @State private var showingDeleteConfirmation = false
    @State private var projectName: String = ""
    @State private var projectId = ""
    @State private var createNewProjectError: String?
    
    var projectFullName: String {
        viewModel.currentProjectName + "(\(viewModel.currentProject))"
    }
    
    var body: some View {
        let showingProjectPopover = Binding<Bool>(
            get: { showingEditProject || showingCreateNewProject },
            set: { _ in
                showingEditProject = false
                showingCreateNewProject = false
            }
        )
        
        NavigationView {
            ZStack {
                NavigationLink(destination: MergeView(syncManager: viewModel.syncManager), isActive: $viewModel.showingMergeScreen) { EmptyView() }
                if viewModel.showingActivityIndicator {
                    ProgressView()
                        .zIndex(1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.white.opacity(0.1))
                }
                ScrollView {
                    VStack {
                        makeHeader(title: "Project".localized)
                        makeProjectGroup()
                        Spacer().frame(height: 30)
                        makeHeader(title: "Remote".localized)
                        makeRemoteGroup()
                        Spacer().frame(height: 40)
                        makeHeader(title: "Tags".localized)
                        makeTagsGroup()
                    }
                    .multilineTextAlignment(.center)
                    .popover(
                        isPresented: showingProjectPopover,
                        arrowEdge: .bottom
                    ) {
                        makeProjectPopover()
                    }
                }
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                makeDeleteConfirmationAlert()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private func makeHeader(title: String) -> some View {
        VStack {
            Text(title)
                .foregroundColor(.gray.opacity(0.5))
                .frame(height: 14)
            Rectangle()
                .foregroundColor(.gray.opacity(0.5))
                .frame(width: 200, height: 1)
            Spacer().frame(height: 10)
        }
    }
    
    private func makeProjectGroup() -> some View {
        Group {
            Menu {
                Picker(selection: $viewModel.currentProject, label: EmptyView()) {
                    ForEach(viewModel.projects, id: \.self) {
                        Text($0)
                    }
                }
            } label: {
                if viewModel.projects.isEmpty {
                    Text("NoProjects".localized)
                } else {
                    Text(projectFullName)
                }
            }.disabled(viewModel.projects.isEmpty)
            Spacer().frame(height: 20)
            HStack {
                Button("NewProject".localized) {
                    showingCreateNewProject = true
                }
                Button("EditProject".localized) {
                    projectName = viewModel.currentProjectName
                    projectId = viewModel.currentProjectId
                    showingEditProject = true
                }
            }
            Spacer().frame(height: 20)
            Button("RemoveProject".localized) {
                showingDeleteConfirmation = true
            }.tint(.red)
        }
    }
    
    private func makeRemoteGroup() -> some View {
        Group {
            TextField("ServerAddress".localized, text: $viewModel.serverUrl)
                .keyboardType(.URL)
                .disabled(viewModel.isLoggedIn)
            Spacer().frame(height: 10)
            if viewModel.isLoggedIn {
                VStack(spacing: 10.0) {
                    Button("LogoutButton".localized) {
                        viewModel.performLogout()
                    }
                    Spacer().frame(width: 10)
                    HStack {
                        makeSyncProjectPicker()
                        Spacer().frame(width: 40)
                        Button("SyncButton".localized) {
                            viewModel.sync()
                        }
                    }
                    if viewModel.syncCompletedSuccessfully {
                        Text("SyncCompletedSuccessfully".localized).foregroundColor(.green)
                    }
                }
            } else {
                VStack(spacing: 10.0) {
                    TextField("Login".localized, text: $viewModel.login)
                    SecureField("Password".localized, text: $viewModel.password)
                    Button("LoginButton".localized) {
                        viewModel.performLogin()
                    }
                }
            }
        }
        .textInputAutocapitalization(.never)
        .disableAutocorrection(true)
    }
    
    private func makeTagsGroup() -> some View {
        Group {
            NavigationLink(destination: TagsView()) {
                Text("EditTags".localized)
            }
            Spacer().frame(height: 30)
        }
    }
    
    private func makeSyncProjectPicker() -> some View {
        Menu {
            Picker(selection: $viewModel.syncSelectedProject, label: EmptyView()) {
                ForEach(viewModel.allProjectsList, id: \.id) {
                    Text($0.name + (!$0.id.isEmpty ? " (\($0.id))" : "")).tag($0)
                }
            }
        } label: {
            Text(viewModel.syncSelectedProject.name)
        }
    }
    
    private func makeProjectPopover() -> some View {
        VStack(spacing: 20.0) {
            TextField("ProjectName".localized, text: $projectName).onChange(of: projectName, perform: { _ in createNewProjectError = nil })
            TextField("ProjectId".localized, text: $projectId).onChange(of: projectId, perform: { _ in createNewProjectError = nil })
            HStack(spacing: 40.0) {
                Button("Common.Cancel".localized) {
                    closeCreteNewProjectPopover()
                }
                Button("Common.Save".localized) {
                    var error: String? = nil
                    
                    if showingCreateNewProject {
                        error = viewModel.createNewProject(projectName, id: projectId)
                    } else {
                        error = viewModel.editCurrentProject(name: projectName, id: projectId)
                    }
                    if let error = error {
                        createNewProjectError = error
                    } else {
                        closeCreteNewProjectPopover()
                    }
                }
                Text(createNewProjectError ?? "").foregroundColor(.red)
            }
        }.padding(.horizontal)
    }
    
    private func makeDeleteConfirmationAlert() -> Alert {
        Alert(
            title: Text("TasksListCell.ConfirmDeleteTask".localizeWithFormat(projectFullName)),
            primaryButton: .destructive(Text("Common.Delete".localized)) {
                viewModel.deleteCurrentProject()
            },
            secondaryButton: .cancel()
        )
    }
    
    private func closeCreteNewProjectPopover() {
        projectName = ""
        projectId = ""
        showingCreateNewProject = false
        showingEditProject = false
    }
}

struct ManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ManagementView()
    }
}
