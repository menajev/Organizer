//
//  TagModel.swift
//  Organizer
//
//  Created by mac-1234 on 17/01/2022.
//

import Foundation

protocol TargetVersion {
    func isEqualOrLowerTo(_ targetVersion: TagModel?) -> Bool
    static func validateVersion(_ version: String) -> Bool
}

class TagModel : Identifiable, Codable, Equatable, Hashable {
    enum TagType { case tag, targetVersion }
    
    var id: IDTags
    var name: String
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case description = "Description"
    }
    
    init(name: String, description: String? = nil) {
        id = IDTags()
        self.name = name
        self.description = description
    }
    
    static func == (lhs: TagModel, rhs: TagModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension TagModel: TargetVersion {
    func isEqualOrLowerTo(_ targetVersion: TagModel?) -> Bool {
        guard let targetVersion = targetVersion else { return false }
        
        var firstNumber = name
        var secondNumber = targetVersion.name
        let firstDesc = splitDesc(version: &firstNumber)
        let secondDesc = splitDesc(version: &secondNumber)
        
        if firstNumber != secondNumber {
            return firstNumber.compare(secondNumber, options: .numeric) != .orderedDescending
        } else if firstDesc != secondDesc {
            return firstDesc.compare(secondDesc) != .orderedDescending
        } else {
            return true
        }
    }
    
    static func validateVersion(_ version: String) -> Bool {
        let splitted = version.split(separator: ".")
        return splitted.count == 3
        && splitted[0].rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        && splitted[1].rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        && splitted[2].first?.isNumber == true
    }
    
    internal func splitDesc(version: inout String) -> String {
        let vowels: Set<Character> = [" ", "_", "-"]
        version.removeAll(where: { vowels.contains($0) })
        
        let number = version.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }.joined(separator: ".")
        let desc = version.replacingOccurrences(of: number, with: "")
        version = number
        
        return desc
    }
}
