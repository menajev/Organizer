//
//  TagCellView.swift
//  Organizer
//
//  Created by mac-1234 on 20/01/2022.
//

import SwiftUI

struct TagCellView: View {
    let tag: TagModel
    
    var body: some View {
        HStack {
            Text(tag.name)
            if let description = tag.description {
                Spacer().frame(width: 30)
                Text(description)
            }
        }
    }
}
