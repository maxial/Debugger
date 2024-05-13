//
//  ConfigurationView.swift
//
//
//  Created by Maxim Aliev on 06.04.2024.
//

import SwiftUI

struct ConfigurationView: View {
    @ObservedObject var viewModel: ConfigurationViewModel
    
    @State private var isShowAddConfigurationRule = false
    
    var body: some View {
        List {
            Section(header: Text("Settings").frame(height: .zero)) {
                KeyValueView(
                    key: .constant("Base URL"),
                    value: .constant(viewModel.configuration.baseURL.absoluteString)
                )
                .frame(height: 64)
            }
            
            if viewModel.configuration.customRules.isEmpty == false {
                Section(header: Text("Custom Rules").frame(height: .zero)) {
                    ForEach(viewModel.configuration.customRules) {
                        ConfigurationRuleView(
                            viewModel: ConfigurationRuleViewModel(rule: $0),
                            updateRuleCompletion: { viewModel.update(rule: $0) }
                        )
                    }
                    .onDelete(perform: removeCustomRules)
                }
            }
        }
        .list()
        .navigationTitle(viewModel.configuration.name)
        .navigationBarItems(trailing: navigationBarItem)
    }
    
    private var navigationBarItem: some View {
        ZStack {
            NavigationLink(
                destination: ConfigurationEditRuleView(
                    viewModel: ConfigurationRuleViewModel(
                        rule: DebuggerConfigurationRule(
                            id: UUID(),
                            type: .requestBody,
                            name: "Untitled"
                        )
                    ),
                    ruleCompletion: { viewModel.update(rule: $0) },
                    isEditing: false
                ),
                isActive: $isShowAddConfigurationRule
            ) {
                Button(
                    action: {
                        isShowAddConfigurationRule = true
                    },
                    label: {
                        Image(systemName: "plus")
                            .foregroundColor(.systemBlue)
                    }
                )
            }
        }
        .onAppear {
            isShowAddConfigurationRule = false
        }
    }
    
    private func removeCustomRules(at offsets: IndexSet) {
        viewModel.removeCustomRules(at: offsets)
    }
}

#Preview {
    ConfigurationView(
        viewModel: ConfigurationViewModel(
            configuration: DebuggerConfiguration(
                name: "Configuration",
                baseURL: URL(string: "google.com")!
            )
        )
    )
}
