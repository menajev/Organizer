//
//  EffortListView.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-21.
//

import SwiftUI

struct EffortListView: View {
    @ObservedObject var viewModel: EffortListViewModel
    
    var body: some View {
        let displayPeriod = Binding(
            get: { viewModel.displayPeriod.rawValue },
            set: { viewModel.displayPeriod = EffortDisplayPeriod(rawValue: $0) ?? .defaultValue }
        )
        
        VStack {
            Picker("", selection: displayPeriod) {
                ForEach(0 ..< EffortDisplayPeriod.count.rawValue) { index in
                    Text(EffortDisplayPeriod(rawValue: index)?.name ?? String(index))
                        .tag(index)
                }
            }.pickerStyle(SegmentedPickerStyle())
            List {
                ForEach(viewModel.effort, id: \.effort.id) {
                    EffortListCellView(viewModel:
                                        EffortListCellViewModel($0.effort,
                                                                displayPeriod: $0.period))
                }
            }
            .font(Font.system(size: 12.0))
        }
    }
}

struct EffortListView_Previews: PreviewProvider {
    static var previews: some View {
        EffortListView(viewModel: EffortListViewModel())
    }
}
