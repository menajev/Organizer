//
//  TasksListCell.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-19.
//

import SwiftUI

struct TasksListCellView: View {
    @ObservedObject var viewModel: TasksListCellViewModel
    
    var textColor: Color {
        if viewModel.task.isBlocked { return .gray }
        
        switch viewModel.task.status {
        case .inactive: return .gray
        case .done: return .green
        default: return .black
        }
    }
    
    var backgroundColor: Color { // TODO
        if viewModel.task.type == .milestone {
            return .yellow.opacity(0.4)
        } else if viewModel.task.isContainer {
            return .gray.opacity(0.4)
        } else if viewModel.task.isPinned {
            return .brown.opacity(0.4)
        }
        return .white
    }
    
    var body: some View {
        HStack {
            Spacer()
                .frame(width: CGFloat(viewModel.indent))
            if !viewModel.settings.flatStucture {
                Button(viewModel.collapsed) {
                    viewModel.toggleCollapsed()
                }
                .frame(width: 30)
                .opacity(viewModel.isCollapsable ? 1.0 : 0.0)
                .buttonStyle(PlainButtonStyle())
            }
            Text(viewModel.name)
            Spacer()
            Text(viewModel.shortcutsList + viewModel.priority)
                .multilineTextAlignment(.trailing)
        }
        .frame(height: 40.0)
        .foregroundColor(textColor)
        .background(backgroundColor)
    }
}

struct TasksListCellView_Previews: PreviewProvider {
    static var previews: some View {
        TasksListCellView(
            viewModel: TasksListCellViewModel(
                TaskModel(),
                isCollapsable: true,
                settings: TasksListSettings.main
            )
        )
    }
}
