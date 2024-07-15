//
//  ConfigurationEditRuleView.swift
//
//
//  Created by Maxim Aliev on 20.04.2024.
//

import SwiftUI

struct ConfigurationEditRuleView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    private var isDoneButtonActive: Bool { viewModel.rule.name.isEmpty == false }
    
    @StateObject var viewModel: ConfigurationRuleViewModel
    var ruleCompletion: (DebuggerConfigurationRule) -> Void
    var isEditing = true
    
    var body: some View {
        List {
            KeyValueView(
                key: .constant("Name"),
                value: $viewModel.rule.name,
                isValueEditable: true
            )
            
            Section {
                KeyValueView(
                    key: .constant("URL Path"),
                    value: .constant(viewModel.rule.path),
                    isEditable: true
                )
                .listRow(
                    isEditable: true,
                    destination: OptionsView(
                        title: "URL Path",
                        options: Debugger.shared.uniqueUrlPaths,
                        selectedOption: viewModel.rule.path,
                        didSelectOption: { viewModel.rule.path = $0 }
                    )
                )
                
                ForEach(viewModel.rule.matchingParams.indices, id: \.self) { i in
                    KeyValueView(
                        key: $viewModel.rule.matchingParams[i].key,
                        value: $viewModel.rule.matchingParams[i].value.value,
                        isKeyEditable: true,
                        isValueEditable: true
                    )
                }
                .onDelete(perform: removeMatchingParams)
            } header: {
                HStack {
                    Text("Matching")
                    
                    Spacer()
                    
                    Button {
                        viewModel.rule.matchingParams.append(
                            ConfigurationRuleParameter(
                                id: UUID(),
                                key: "",
                                value: .string("")
                            )
                        )
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.systemBlue)
                    }
                }
            }
            
            Section {
                Picker("Modify", selection: $viewModel.rule.type) {
                    ForEach(DebuggerConfigurationRuleType.allCases) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.menu)
                
                switch viewModel.rule.type {
                case .requestBody:
                    ForEach(viewModel.rule.updatingParams.indices, id: \.self) { i in
                        KeyValueView(
                            key: $viewModel.rule.updatingParams[i].key,
                            value: $viewModel.rule.updatingParams[i].value.value,
                            isKeyEditable: true,
                            isValueEditable: true
                        )
                    }
                    .onDelete(perform: removeUpdatingParams)
                case .responseBody:
                    TextEditor(text: $viewModel.rule.updatingResponse)
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
            } header: {
                HStack {
                    Text("Updating")
                    
                    Spacer()
                    
                    Button {
                        viewModel.rule.updatingParams.append(
                            ConfigurationRuleParameter(
                                id: UUID(),
                                key: "",
                                value: .string("")
                            )
                        )
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.systemBlue)
                    }
                }
            }
        }
        .padding(.vertical, 5)
        .list()
        .navigationTitle(isEditing ? "Edit Rule" : "New Rule")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: navigationBarItem)
    }
    
    private var navigationBarItem: some View {
        Button(
            action: {
                ruleCompletion(viewModel.rule)
                presentationMode.wrappedValue.dismiss()
            },
            label: {
                Text("Save")
                    .bold()
                    .foregroundColor(isDoneButtonActive ? .systemBlue : .systemGray)
            }
        )
        .disabled(isDoneButtonActive == false)
    }
    
    private func removeMatchingParams(at offsets: IndexSet) {
        viewModel.rule.matchingParams.remove(atOffsets: offsets)
    }
    
    private func removeUpdatingParams(at offsets: IndexSet) {
        viewModel.rule.updatingParams.remove(atOffsets: offsets)
    }
}

#Preview {
    ConfigurationEditRuleView(
        viewModel: ConfigurationRuleViewModel(
            rule: DebuggerConfigurationRule(
                id: UUID(),
                type: .requestBody
            )
        ),
        ruleCompletion: { _ in }
    )
}
