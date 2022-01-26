//
//  MergeView.swift
//  Organizer
//
//  Created by mac-1234 on 22/01/2022.
//

import SwiftUI

struct MergeView: View {
    var syncManager: SyncManager
    
    var body: some View {
        VStack {
            Text(syncManager.mergeConflictsDescription)
            HStack {
                Button("UseLocal".localized) {
                    syncManager.continueMerge(useLocal: true)
                }
                Button("UseRemote".localized) {
                    syncManager.continueMerge(useLocal: false)
                }
            }
        }
    }
}
