//
//  TagsView.swift
//  Organizer
//
//  Created by mac-1234 on 20/01/2022.
//

import SwiftUI

struct TagsView: View {
    @ObservedObject private var viewModel: TagsViewModel
    
    init(viewModel: TagsViewModel = TagsViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.showControls {
                makeTopControls()
            }
            makeList()
            if (viewModel.showControls) {
                makeBottomControls()
            }
        }
    }
    
    func makeList() -> some View {
        List {
            ForEach(viewModel.tags, id: \.name) { tag in
                TagCellView(tag: tag)
                    .onTapGesture {
                        viewModel.tagSelected(tag)
                    }
                    .listRowBackground(Rectangle()
                                        .background(Color.clear)
                                        .foregroundColor(viewModel.isTagSelected(tag) ? .red : .white))
            }
        }
        .font(Font.system(size: 12.0))
        .frame(height: viewModel.showControls ? 200 : nil)
    }
    
    func makeTopControls() -> some View {
        return Group {
            HStack {
                TextField("Name".localized, text: $viewModel.name)
                Button("Clear".localized) {
                    
                }.frame(width: 100)
            }
            if viewModel.tagsType == .targetVersion {
                TextField("Description".localized, text: $viewModel.description)
                    .frame(height: 36)
            } else {
                Spacer().frame(height: 36)
            }
            HStack(spacing: 10) {
                Button("Add".localized) {
                    viewModel.addTag()
                }
                Button("EditSelected".localized) {
                    viewModel.editSelectedTag()
                }.disabled(viewModel.selectedTags.count != 1)
                Button("Delete".localized) {
                    viewModel.deleteSelectedTag()
                }.disabled(viewModel.selectedTags.count != 1)
            }
        }
    }
    
    func makeBottomControls() -> some View {
        Group {
            HStack {
                Button("Tags".localized) {
                    viewModel.tagsType = .tag
                }
                Button("Target versions") {
                    viewModel.tagsType = .targetVersion
                }
            }
            Text(viewModel.errorMessage)
                .foregroundColor(.red)
                .frame(height: 20)
        }
    }
}
