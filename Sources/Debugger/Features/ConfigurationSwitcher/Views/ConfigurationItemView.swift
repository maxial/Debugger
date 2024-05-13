//
//  ConfigurationItemView.swift
//
//
//  Created by Maxim Aliev on 31.03.2024.
//

import SwiftUI

struct ConfigurationItemView: View {
    @ObservedObject var viewModel: ConfigurationItemViewModel
    var didSelectConfiguration: (DebuggerConfiguration) -> Void
    
    @State private var isShowConfigurationInfo = false
    
    var body: some View {
        NavigationLink(
            destination: ConfigurationView(
                viewModel: ConfigurationViewModel(configuration: viewModel.configuration)
            ),
            isActive: $isShowConfigurationInfo
        ) {
            HStack {
                ZStack {
                    Color.secondarySystemGroupedBackground
                    
                    HStack {
                        Text(viewModel.configuration.name)
                            .foregroundColor(.label)
                            .padding(.vertical, 8)
                        
                        Spacer()
                        
                        if viewModel.isSelected {
                            Image(systemName: "checkmark")
                                .resizable()
                                .foregroundColor(.systemBlue)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                .onTapGesture {
                    didSelectConfiguration(viewModel.configuration)
                }
                
                Spacer(minLength: 8)
                
                Button {
                    isShowConfigurationInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .resizable()
                        .padding(6)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .listNavigationRow()
        .onAppear {
            isShowConfigurationInfo = false
        }
    }
}

#Preview {
    ConfigurationItemView(
        viewModel: ConfigurationItemViewModel(
            configuration: DebuggerConfiguration(
                name: "Configuration",
                baseURL: URL(string: "google.com")!
            ),
            isSelected: true
        ),
        didSelectConfiguration: { _ in }
    )
}
