//
//  TimeFormatter.swift
//  Organizer
//
//  Created by mac-1234 on 23/01/2022.
//

import Foundation

class TimeFormatter {
    typealias TimeComponents = (days: Int, hours: Int, minutes: Int)
    
    static func estimatedTime(from string: String) -> Int64 {
        let multipliers = [Int64(24 * 3600), Int64(3600), Int64(60)];
        var string = string.filter { $0 != " " }
        var components = [Int64]()
        var estimatedTime: Int64 = 0
        
        for _ in 0..<3 { components.append(0) }
        
        for (i, val) in ["d", "h", "m"].enumerated() {
            if let index = string.firstIndex(of: Character(val)) {
                components[i] = Int64(string[string.startIndex..<index]) ?? 0
                string = String(string[string.index(after: index)..<string.endIndex])
            }
        }
        
        for (index, val) in components.enumerated() {
            estimatedTime += val * multipliers[index]
        }        
        return estimatedTime
    }
    
    static func estimatedTime(from time: Int64) -> String {        
        let components = TimeFormatter.components(from: time)
        
        return (components.days > 0 ? String(components.days) + "d " : "")
        + (components.hours > 0 ? String(components.hours) + "h " : "")
        + (String(components.minutes) + "m")
    }
}

fileprivate extension TimeFormatter {
    static func components(from time: Int64) -> TimeComponents {
        var time = time
        let days = time / (3600 * 24); time -= days * 3600 * 24;
        let hrs = time / 3600; time -= hrs * 3600;
        let minutes = time / 60; time -= minutes * 60;
        
        return (days: Int(days), hours: Int(hrs), minutes: Int(minutes))
    }
}
