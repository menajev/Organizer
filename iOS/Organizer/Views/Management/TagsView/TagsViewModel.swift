//
//  TagsViewModel.swift
//  Organizer
//
//  Created by mac-1234 on 20/01/2022.
//

import Foundation
import Combine

class TagsViewModel: ObservableObject {
    enum NameValidationError { case empty, taken, invalid }
    
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var tags: [TagModel]
    @Published var tagsType: TagModel.TagType = .tag
    @Published var selectedTags: [TagModel] = []
    @Published var errorMessage = ""
    private(set) var multiSelection: Bool
    private let dataSource: ProjectsDataSource
    private var bag = Set<AnyCancellable>()
    
    
    var showControls: Bool {
        !multiSelection
    }
    
    init(multiSelection: Bool = false, selectedTags: [TagModel]? = nil) {
        dataSource = ServiceLocator.inject()
        tags = dataSource.targetVersions
        self.multiSelection = multiSelection
        if let selectedTags = selectedTags {
            self.selectedTags.append(contentsOf: selectedTags)
        }
        
        $tagsType.combineLatest(dataSource.$tags, dataSource.$targetVersions).map { type, tags, targetVersions in
            type == .tag ? tags : targetVersions
        }.sink(receiveValue: { [weak self] tags in
            self?.tags = tags
        }).store(in: &bag)
    }
    
    func validateName() -> Bool {
        var error: NameValidationError? = nil
        if name.isEmpty {
            error = .empty
        } else if tags.contains(where: { $0.name == name }) {
            error = .taken
        } else if tagsType == .tag {
            return true
        } else if !TagModel.validateVersion(name) {
            error = .invalid
        }
        if let error = error {
            errorMessage = String(describing: error)
        } else {
            errorMessage = ""
        }
        return error == nil
    }
    
    func addTag() {
        guard validateName() else { return }
        let description = !description.isEmpty ? description : nil
        addOrEditTag(TagModel(name: name, description: description))
    }
    
    func editSelectedTag() {
        guard let tag = selectedTags.first, validateName() else { return }
        tag.name = name
        tag.description = !description.isEmpty ? description : nil
        addOrEditTag(tag)
    }
    
    private func addOrEditTag(_ tag: TagModel) {
        dataSource.addOrReplaceTag(tag, type: tagsType)
        name = ""
        description = ""
        if !multiSelection {
            selectedTags.removeAll()
        }
    }
    
    func deleteSelectedTag() {
        guard let tag = selectedTags.first else { return }
        dataSource.deleteTag(tag, type: tagsType)
    }
    
    func tagSelected(_ tag: TagModel) {
        if multiSelection {
            if selectedTags.contains(tag) {
                selectedTags.removeAll(where: { $0.id == tag.id })
            } else {
                selectedTags.append(tag)
            }
        } else {
            if selectedTags.contains(tag) {
                selectedTags.removeAll()
            } else {
                selectedTags.removeAll()
                selectedTags.append(tag)
                name = tag.name
                description = tag.description ?? ""
            }
        }
    }
    
    func isTagSelected(_ tag: TagModel) -> Bool {
        selectedTags.contains(tag)
    }
}
