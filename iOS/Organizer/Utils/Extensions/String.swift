//
//  String.swift
//  Organizer
//
//  Created by XCodeClub on 2021-12-12.
//

import Foundation

extension String {
    var localized: String {
#if DEBUG
//        let noKeyValue = "__no__key__"
//        if NSLocalizedString(self, value: noKeyValue, comment: "") == noKeyValue {
//            print("Localized key: " + self + " not found")
//        }
#endif
        return NSLocalizedString(self, comment: "")
    }
    
    func localizeWithFormat(_ arguments: CVarArg...) -> String{
        return String(format: self.localized, arguments: arguments)
    }
}
