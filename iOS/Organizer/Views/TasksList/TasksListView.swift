//
//  TasksListView.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-21.
//

import SwiftUI
import SwiftUISideMenu

struct TasksListView: View {
    @ObservedObject var viewModel: TasksListViewModel
    @EnvironmentObject var settings: TasksListSettings
    @State var showSideMenu = false
    @State var showNewTaskView = false
    @State var showDeleteConfirmation = false
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationView {
            ZStack() {
                List(viewModel.tasks.filter({ taskMatchSearchQuery($0.task) }), id: \.task.id) { task, isCollapsable in
                    NavigationLink(
                        destination: TaskDetailsView(
                            viewModel: TaskDetailsViewModel(task: task)
                        )) {
                            createCell(forTask: task, isCollapsable: isCollapsable)
                                .background(task == viewModel.trackedTask ? .brown : .white)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button {
                                viewModel.toggleTaskTracking(task)
                            } label: {
                                Text(task == viewModel.trackedTask ? "TasksListCell.StopTracking".localized : "TasksListCell.StartTracking".localized)
                            }.tint(viewModel.isTaskTracked(task) ? .red : .green)
                            if task.status != .done {
                                Button {
                                    viewModel.taskDone(task)
                                } label: {
                                    Label("TasksListCell.Done".localized, systemImage: "checkmark")
                                }.tint(.blue)
                            }
                            Button {
                                viewModel.toggleTaskActive(task)
                            } label: {
                                Text(task.status.isActive ? "TasksListCell.SetInactive".localized : "TasksListCell.SetActive".localized)
                            }
                            .tint(task.status.isActive ? .gray : .green)
                            Button {
                                viewModel.filters.masterTask = task
                            } label: {
                                Text("M")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                showDeleteConfirmation = true
                            } label: {
                                Label("TasksListCell.Delete".localized, systemImage: "trash")
                            }
                        }
                        .alert(isPresented: $showDeleteConfirmation) {
                            Alert(
                                title: Text("TasksListCell.ConfirmDeleteTask".localizeWithFormat(task.name)),
                                primaryButton: .destructive(Text("Common.Delete".localized)) {
                                    viewModel.deleteTask(task)
                                },
                                secondaryButton: .cancel()
                            )
                        }
                }
                .zIndex(0)
                .searchable(text: $searchQuery)
                if viewModel.tasks.isEmpty {
                    Text("TasksListEmpty".localized).zIndex(1)
                }
            }
            .navigationBarTitle(viewModel.activeMasterTask?.name ?? "", displayMode: .inline)
            .navigationBarItems(leading: Button(action : {
                withAnimation {
                    showSideMenu.toggle()
                }
            }) {
                Image(systemName: "line.horizontal.3")
                    .imageScale(.large)
            }).background {
                NavigationLink(
                    destination: TaskDetailsView(viewModel: TaskDetailsViewModel()),
                    isActive: $showNewTaskView,
                    label: {})
            }
        }        
        .sideMenu(isShowing: $showSideMenu) {
            TasksListSideMenu(isShowing: $showSideMenu,
                              showNewTaskView: $showNewTaskView,
                              filters: $viewModel.filters,
                              comparator: $viewModel.comparator,
                              settings: settings)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func createCell(forTask task: TaskBase,
                            isCollapsable: Bool) -> TasksListCellView {
        TasksListCellView(
            viewModel: TasksListCellViewModel(task,
                                              isCollapsable: isCollapsable,
                                              settings: settings))
    }
    
    private func taskMatchSearchQuery(_ task: TaskBase) -> Bool {
        searchQuery.isEmpty
        || task.name.lowercased().contains(searchQuery.lowercased())
        || task.description.lowercased().contains(searchQuery.lowercased())
    }
}

struct TasksListView_Previews: PreviewProvider {
    static var previews: some View {
        TasksListView(viewModel: TasksListViewModel())
    }
}
