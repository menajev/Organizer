//
//  TasksListSideMenu.swift
//  Organizer
//
//  Created by XCodeClub on 2021-12-04.
//

import SwiftUI

// TODO: resume last?

struct TasksListSideMenu: View {
    @Binding var isShowing: Bool
    @Binding var showNewTaskView: Bool
    @Binding var filters: TasksListFilters
    @Binding var comparator: TasksComparator
    let settings: TasksListSettings
    
    init(isShowing: Binding<Bool>,
         showNewTaskView: Binding<Bool>,
         filters: Binding<TasksListFilters>,
         comparator: Binding<TasksComparator>,
         settings: TasksListSettings) {
        _isShowing = isShowing
        _showNewTaskView = showNewTaskView
        _filters = filters
        _comparator = comparator
        self.settings = settings
    }
    
    var body: some View {
        let minPriority = Binding(
            get: { filters.minPriority + 1 },
            set: { filters.minPriority = $0 - 1 }
        )
        VStack(alignment: .leading) {
            Group { // Top buttons
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isShowing = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "xmark")
                            Text("SideMenu.Close".localized)
                        }
                        .padding(.all, 5.0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(.gray, lineWidth: 2))
                    }
                }
                Divider()
                    .frame(height: 20)
                
                if !settings.hideNewTaskButton {
                    Button(action: {
                        showNewTaskView = true
                        isShowing = false
                    }) {
                        Text("SideMenu.CreateNewTask".localized) // TODO: With master task on, it creates child
                            .padding(.all, 5.0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(.gray, lineWidth: 2)
                            )
                    }
                }
                
                Divider()
                    .frame(height: 2)
                    .background(.gray)
                    .padding(.vertical, 10.0)
            }
            
            Group { // Filtering
                makePriorityPicker(minPriority)
                if !settings.forceHideDoneTasks {
                    Toggle("SideMenu.HideDone".localized, isOn: $filters.hideDone)
                }
                Toggle("SideMenu.HideInactive".localized, isOn: $filters.hideInactive)
                Toggle("SideMenu.HideBlocked".localized, isOn: $filters.hideBlocked)
                
                if !settings.hideMasterTaskFilter {
                    Toggle("SideMenu.MasterTask".localized + "\n" + (filters.masterTask != nil ? (filters.masterTask?.name ?? "") : "SideMenu.MasterTaskEmpty".localized) , isOn: $filters.masterTaskActive)
                        .disabled(filters.masterTask == nil)
                }
                
                Divider()
                    .frame(height: 2)
                    .background(.gray)
                    .padding(.vertical, 10.0)
            }
            
            Group { // Sorting
                // TODO: Sort
                HStack {
                    Text("SideMenu.SortingParam".localized + ":")
                    Spacer()
                    Button(comparator.comparedParam.name) {
                        comparator.comparedParam.toggle()
                    }
                }
                HStack {
                    Text("SideMenu.SortingDirection".localized + ":")
                    Spacer()
                    Button(comparator.order.name) {
                        comparator.order.toggle()
                    }
                }
            }            
            Spacer()
        }
        .padding()
        .font(.system(size: 13))
        .background(Color.black)
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.all)
    }
    
    func makePriorityPicker(_ minPriority: Binding<Int>) -> some View {
        Menu {
            Picker(selection: minPriority, label: EmptyView()) {
                ForEach(-1 ..< 10) {
                    Text($0 == -1 ? "SideMenu.MinPriority.Off".localized : "\($0)")
                }
            }
        } label: {
            HStack {
                Text("SideMenu.MinPriority".localized + ": ")
                Text(minPriority.wrappedValue == 0 ? "SideMenu.MinPriority.Off".localized : "\(minPriority.wrappedValue - 1)")
            }
        }
    }
}

struct TasksListSideMenu_Previews: PreviewProvider {
    @State static var isShowing: Bool = true
    @State static var showNewTaskView: Bool = false
    @State static var filters = TasksListFilters()
    @State static var comparator = TasksComparator()
    
    static var previews: some View {
        TasksListSideMenu(isShowing: $isShowing,
                          showNewTaskView: $showNewTaskView,
                          filters: $filters,
                          comparator: $comparator,
                          settings: TasksListSettings.main
        )
    }
}
