//
//  EffortListCellView.swift
//  Organizer
//
//  Created by XCodeClub on 2021-11-22.
//

import SwiftUI
import Combine

struct EffortListCellView: View {
    @ObservedObject var viewModel: EffortListCellViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            HStack(alignment: .center) {
            Text(viewModel.displayPeriod)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                Spacer()
            }.frame(width: 100.0)
            Text(viewModel.taskName)
            Spacer()
            Text(viewModel.duration).fixedSize(horizontal: true, vertical: false)
        }
    }
}

struct EffortListCellView_Previews: PreviewProvider {
    static var previews: some View {
        EffortListCellView(viewModel:
                            EffortListCellViewModel(EffortModel(),
                                                    displayPeriod: "2012 Feb"))
    }
}
