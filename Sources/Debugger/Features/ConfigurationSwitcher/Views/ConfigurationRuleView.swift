//
//  ConfigurationRuleView.swift
//
//
//  Created by Maxim Aliev on 20.04.2024.
//

import SwiftUI

struct ConfigurationRuleView: View {
    @ObservedObject var viewModel: ConfigurationRuleViewModel
    var updateRuleCompletion: (DebuggerConfigurationRule) -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            checkboxView
            
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.rule.name)
                    .foregroundColor(.label)
                
                let modify = "Modify " + viewModel.rule.type.rawValue
                if viewModel.rule.path.isEmpty {
                    Text(modify)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                } else {
                    Text(modify + ": " + viewModel.rule.path)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
        }
        .listNavigationRow(
            destination: ConfigurationEditRuleView(
                viewModel: viewModel,
                ruleCompletion: updateRuleCompletion
            )
        )
    }
    
    private var checkboxView: some View {
        Button(action: {
            viewModel.rule.isEnabled.toggle()
            updateRuleCompletion(viewModel.rule)
        }) {
            Image(systemName: viewModel.rule.isEnabled ? "checkmark.square.fill" : "square")
                .foregroundColor(viewModel.rule.isEnabled ? .blue : .gray)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}

#Preview {
    ConfigurationRuleView(
        viewModel: ConfigurationRuleViewModel(
            rule: DebuggerConfigurationRule(
                id: UUID(),
                type: .requestBody,
                name: "Untitled",
                path: "fakepath/tosomething/verylongpath/tosomething"
            )
        ),
        updateRuleCompletion: { _ in }
    )
}
