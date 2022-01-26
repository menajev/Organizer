//
//  EffortListViewModel.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-22.
//

import Foundation
import Combine

enum EffortDisplayPeriod: Int {
    case detailed, day, month, count
    
    static var defaultValue: EffortDisplayPeriod {
        .day
    }
    
    var name: String {
        switch self {
        case .detailed: return "EffortDisplayPeriodName.Detailed".localized
        case .day: return "EffortDisplayPeriodName.Day".localized
        case .month: return "EffortDisplayPeriodName.Month".localized
        default: return ""
        }
    }
};

class EffortListViewModel: ObservableObject{    
    @Published var effort: [(effort: EffortModel, period: String)]
    @Published var displayPeriod: EffortDisplayPeriod = .month
    private var bag = Set<AnyCancellable>()
    private let dateFormatter = DateFormatter()
    
    init() {
        effort = []
        
        let dataSource: ProjectsDataSource = ServiceLocator.inject()
        dataSource.$effort.combineLatest($displayPeriod).sink(receiveValue: { [weak self] effort, period in
            self?.effort = []
            var tempEffort = [(effort: EffortModel, period: String)]()
            var durationSum: Int64 = -1
            
            for (index, model) in effort.reversed().enumerated() { // TODO: Optimize
                var periodText = self?.displayedPeriod(of: model, forPeriod: period) ?? ""
                let nextPeriodText = index < effort.count - 1 ? self?.displayedPeriod(of: effort.reversed()[index + 1], forPeriod: period) ?? "" : ""
                let endTime = model.isFinished ? model.endTime : Date().millisecondsSince1970
                durationSum += endTime - model.startTime
                
                if periodText == nextPeriodText {
                    periodText = ""
                } else {
                    if period != .detailed {
                        periodText += "\n(" + (self?.duration(durationSum) ?? "") + ")"
                    }
                    durationSum = 0
                }
                
                tempEffort.append((model, periodText))
            }
            
            self?.effort = tempEffort.reversed()
        }).store(in: &bag)
    }
    
    func displayedPeriod(of model: EffortModel, forPeriod period: EffortDisplayPeriod) -> String {
        if period == .detailed {
            dateFormatter.dateFormat = "dd.MM.YY\nhh:mm"
            let start = dateFormatter.string(from: model.startDate)
            dateFormatter.dateFormat = "hh:mm"
            let end = model.endTime == -1 ? "now" : dateFormatter.string(from: model.endDate)
            return start + " - " + end
        } else if period == .day {
            dateFormatter.dateFormat = "dd MMM YY"
            return dateFormatter.string(from: model.startDate)
        } else {
            dateFormatter.dateFormat = "Y MMM"
            return dateFormatter.string(from: model.startDate)
        }
    }
    
    func duration(_ duration: Int64) -> String {
        let time = TimeInterval(duration) / 1000.0
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        return (hours > 0 ? "\(hours):" : "")
        + (minutes > 0 || hours > 0 ? String(format:"%02i", minutes) : "00")
    }
}

//Time current = Time::getCurrentTime();
//Time start = Time(startTime);
//Time end = Time(endTime);
//
//if (type == eptDetailed)
//{
//    String day = start.formatted("%d %m %Y");
//    if (current.getYear() == start.getYear())
//    {
//        if (current.getDayOfYear() == start.getDayOfYear())
//            day = "";
//        if (current.getDayOfYear() == start.getDayOfYear() + 1)
//            day = "Yesterday";
//    }
//
//    return day.replaceCharacter(' ', '.') + (day.isNotEmpty() ? " " : "")
//        + start.toString(false, true, false, true)
//        + " - " + (endTime == -1 ? "now" : end.toString(false, true, false, true).replaceFirstOccurrenceOf(" ", ".").replaceFirstOccurrenceOf(" ", "."));
//}
//if (type == eptDay)
//{
//    if (current.getYear() == start.getYear())
//    {
//        if (current.getDayOfYear() == start.getDayOfYear())
//            return "Today";
//        if (current.getDayOfYear() == start.getDayOfYear() + 1)
//            return "Yesterday";
//    }
//    return start.toString(true, false);
//}
//if (type == eptMonth)
//{
//    return start.formatted("%Y %B");
//}
