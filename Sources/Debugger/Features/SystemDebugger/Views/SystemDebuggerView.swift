//
//  SystemDebuggerView.swift
//
//
//  Created by Maxim Aliev on 25.04.2024.
//

import SwiftUI

struct SystemDebuggerView: View {
    @ObservedObject var viewModel: SystemDebuggerViewModel
    
    var body: some View {
        List {
            Toggle(isOn: $viewModel.isShowWidget) {
                Text("Show Widget On Screen")
            }
            .padding(.vertical, 4)
            .listNavigationRow()
            
            Toggle(isOn: $viewModel.isDetectLeaks) {
                Text("Memory Leak Detection")
            }
            .padding(.vertical, 4)
            .listNavigationRow()
            
            Section(header: Text("Metrics").frame(height: .zero)) {
                ForEach(viewModel.metrics) {
                    KeyValueView(
                        key: .constant($0.type.rawValue),
                        value: .constant($0.value)
                    )
                    .frame(height: 64)
                }
            }
        }
        .list()
        .navigationTitle(viewModel.type.name)
    }
}

#Preview {
    SystemDebuggerView(viewModel: SystemDebuggerViewModel())
}
