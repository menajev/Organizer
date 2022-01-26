//
//  EffortListCellViewModel.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-22.
//

import Foundation

class EffortListCellViewModel: ObservableObject {
    @Published var model: EffortModel
    @Published var displayPeriod: String // TODO: rename
    
    var taskName: String {
        model.parent?.name ?? "EffortListCell-UnknownParent".localized
    }
    
    var duration: String {
        // TODO: Static date formatter
        
        let endTime = model.endTime == EffortModel.ongoingEndTime ? Date().millisecondsSince1970 : model.endTime
        let time = (endTime - model.startTime) / 1000
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return (hours > 0 ? "\(hours):" : "")
        + (minutes > 0 || hours > 0 ? String(format:"%02i:", minutes) : "00:")
        + String(format:"%02i", seconds)
    }
    
    init(_ model: EffortModel, displayPeriod: String) {
        self.model = model
        self.displayPeriod = displayPeriod
    }
}
