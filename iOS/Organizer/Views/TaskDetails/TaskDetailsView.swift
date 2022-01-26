//
//  TaskDetailsView.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-30.
//

import SwiftUI
import Combine

struct TaskDetailsView: View {
    @ObservedObject var viewModel: TaskDetailsViewModel
    @State var showError = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        let presentingError = Binding(get: { !viewModel.errorMessage.isEmpty }, set: { _ in })
        
        NavigationLink(destination: TaskDetailsView(viewModel: TaskDetailsViewModel(parent: viewModel.task)), isActive: $viewModel.creatingChild) { EmptyView() }        
        NavigationLink(destination: TagsView(viewModel: viewModel.tagsViewModel), isActive: $viewModel.selectingTags) { EmptyView() }
        
        ScrollView {
            VStack(spacing: 10) {
                TextField("Common.Name".localized, text: $viewModel.name)
                    .lineLimit(1)
                    .disableAutocorrection(true)
                TextEditor(text: $viewModel.description)
                    .frame(height: 50)
                    .lineLimit(nil)
                    .border(.gray)
                
                makePriorityPicker()
                makeTargetVersionPicker()
                
                HStack {
                    Text("EstimatedTime".localized)
                    Spacer()
                    makeEstimatedTimeTextField()
                }
                
                Group {
                    Toggle("Common.Active".localized + ":", isOn: $viewModel.isActive).disabled(!viewModel.supports(.togglingStatus))
                    Toggle("ShortcutsList".localized + ":", isOn: $viewModel.isOnShortcutsList).disabled(!viewModel.supports(.shortcuting))
                    Toggle("IsPinned".localized + ":", isOn: $viewModel.isPinned)
                    Toggle("Common.Container".localized + ":", isOn: $viewModel.isContainer).disabled(!viewModel.supports(.editingIsContainer))
                }
                Button("TaskDetails.SelectTags".localized) {
                    viewModel.selectTags()
                }
                if !viewModel.taskCreation {
                    Button("TaskDetails.CreateChild".localized) {
                        viewModel.createChild()
                    }
                    .padding(.top, 20.0)
                    .disabled(!viewModel.supports(.parenting))
                }
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action : {
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Common.Cancel".localized)
        }, trailing: Button(action : {
            if viewModel.save() {
                presentationMode.wrappedValue.dismiss()
            } else {
                showError = true
            }
        }) {
            Text("Common.Save".localized)
        })
        .alert(viewModel.errorMessage, isPresented: presentingError) {
            Button("Common.OK".localized, role: .cancel) { }
        }
    }
    
    private func makePriorityPicker() -> some View {
        HStack {
            Text("Common.Priority".localized + ":")
            Spacer()
            Menu {
                Picker(selection: $viewModel.priority, label: EmptyView()) {
                    ForEach(-1 ..< 10) {
                        Text(String($0)).tag($0)
                    }
                }
            } label: {
                Text(String(viewModel.priority))
            }
        }.disabled(!viewModel.supports(.editingPriority))
    }
    
    private func makeTargetVersionPicker() -> some View {
        HStack {
            Text("Common.TargetVersion".localized + ":")
            Spacer()
            Menu {
                Picker(selection: $viewModel.targetVersion, label: EmptyView()) {
                    ForEach(viewModel.targetVersions) {
                        Text($0.name).tag($0 as TagModel?)
                    }
                }
            } label: {
                Text(viewModel.targetVersion?.name ?? "(none)")
            }
        }
    }
    
    private func makeEstimatedTimeTextField() -> some View {
        TextField("", text: $viewModel.estimatedTime)
            .frame(width: 100)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .onReceive(Just(viewModel.estimatedTime)) { newValue in
                // TODO: Mess...
                var filtered = newValue.filter { "0123456789dhm ".contains($0) }
                removeDuplicatedLastCharacter(char: "d", fromString: &filtered)
                removeDuplicatedLastCharacter(char: "h", fromString: &filtered)
                removeDuplicatedLastCharacter(char: "m", fromString: &filtered)
                if let index = filtered.firstIndex(of: "h"), index < (filtered.firstIndex(of: "d") ?? filtered.startIndex) {
                    filtered.remove(at: index)
                }
                if let index = filtered.firstIndex(of: "m"), index < (filtered.firstIndex(of: "h") ?? filtered.startIndex) || index < (filtered.firstIndex(of: "d") ?? filtered.startIndex) {
                    filtered.remove(at: index)
                }
                
                if filtered != newValue {
                    viewModel.estimatedTime = filtered
                }
            }
    }
    
    private func removeDuplicatedLastCharacter(char: Character, fromString string: inout String) {
        while let lastIndex = string.lastIndex(of: char), string.firstIndex(of: char) != lastIndex {
            string.remove(at: lastIndex)
        }
    }
}

struct TaskDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailsView(viewModel: TaskDetailsViewModel(task: TaskModel()))
    }
}
