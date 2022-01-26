//
//  ContentView.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-17.
//

import SwiftUI

struct ContentView: View {
    @StateObject var mainListSettings = TasksListSettings.main
    @StateObject var shortcutsListSettings = TasksListSettings.shortcutsList
    
    var body: some View {
        TabView {
            TasksListView(viewModel: TasksListViewModel())
                .tabItem({
                    Image(systemName: "circle")
                    Text("Tasks".localized)
                })
                .environmentObject(mainListSettings)
                .tag(0)
            EffortListView(viewModel: EffortListViewModel())
                .tabItem({
                    Image(systemName: "circle")
                    Text("Effort".localized)
                })
                .tag(1)
            ManagementView()
                .tabItem({
                    Image(systemName: "circle")
                    Text("Management".localized)
                })
                .tag(2)
            TasksListView(
                viewModel: TasksListViewModel(
                    filters: TasksListFilters(hideDone: true, shortcutsListOnly: true)
                ))
                .tabItem({
                    Image(systemName: "circle")
                    Text("Shortcuts".localized)
                })
                .environmentObject(shortcutsListSettings)
                .tag(3)
        }
        .font(Font.system(size: 14))
        .listStyle(PlainListStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
