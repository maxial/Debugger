//
//  DebuggerItemView.swift
//
//
//  Created by Maxim Aliev on 15.03.2024.
//

import SwiftUI

struct DebuggerItemView<Destination>: View where Destination: View {
    @ObservedObject var viewModel: DebuggerItemViewModel
    var destination: Destination
    
    var body: some View {
        HStack {
            Text(viewModel.type.name)
                .foregroundColor(.label)
            
            if viewModel.value.isEmpty == false {
                Spacer()
                
                Text(viewModel.value)
                    .foregroundColor(.secondary)
                    .padding(.trailing, 8)
                    .font(.system(size: 14))
            }
        }
        .padding(.vertical, 8)
        .listRow(isEditable: false, destination: destination)
    }
}

#Preview {
    DebuggerItemView(
        viewModel: DebuggerItemViewModel(type: .networkSniffer, value: "100"),
        destination: NetworkSnifferView(viewModel: NetworkSnifferViewModel())
    )
}
