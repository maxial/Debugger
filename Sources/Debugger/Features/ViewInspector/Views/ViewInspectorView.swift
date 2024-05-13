//
//  ViewInspectorView.swift
//
//
//  Created by Maxim Aliev on 03.05.2024.
//

import SwiftUI

struct ViewInspectorView: View {
    @ObservedObject var viewModel: ViewInspectorViewModel
    
    var body: some View {
        List {
            ForEach(ViewInspectorConfiguration.allCases) { configuration in
                ViewInspectorConfigurationView(
                    configuration: configuration,
                    isSelected: viewModel.configuration == configuration
                )
                .onTapGesture {
                    viewModel.configuration = configuration
                }
            }
        }
        .list()
        .navigationTitle(viewModel.type.name)
    }
}

#Preview {
    ViewInspectorView(viewModel: ViewInspectorViewModel())
}
