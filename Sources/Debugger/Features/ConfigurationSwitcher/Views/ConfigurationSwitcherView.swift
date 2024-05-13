//
//  ConfigurationSwitcherView.swift
//
//
//  Created by Maxim Aliev on 31.03.2024.
//

import SwiftUI

struct ConfigurationSwitcherView: View {
    @ObservedObject var viewModel: ConfigurationSwitcherViewModel
    var didSelectConfiguration: (DebuggerConfiguration) -> Void
    
    var body: some View {
        List {
            ForEach(viewModel.configurations) { configuration in
                ConfigurationItemView(
                    viewModel: ConfigurationItemViewModel(
                        configuration: configuration,
                        isSelected: configuration == viewModel.selectedConfiguration
                    ),
                    didSelectConfiguration: { configuration in
                        didSelectConfiguration(configuration)
                    }
                )
            }
        }
        .list()
        .navigationTitle(viewModel.type.name)
    }
}

#Preview {
    ConfigurationSwitcherView(
        viewModel: ConfigurationSwitcherViewModel(),
        didSelectConfiguration: { _ in }
    )
}
