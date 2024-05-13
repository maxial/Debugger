//
//  ViewInspectorConfigurationView.swift
//
//
//  Created by Maxim Aliev on 04.05.2024.
//

import SwiftUI

struct ViewInspectorConfigurationView: View {
    var configuration: ViewInspectorConfiguration
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(configuration.rawValue)
                .foregroundColor(.label)
                .padding(.vertical, 8)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .resizable()
                    .foregroundColor(.systemBlue)
                    .frame(width: 16, height: 16)
            }
        }
        .listNavigationRow()
    }
}

#Preview {
    ViewInspectorConfigurationView(configuration: .attributesInspector, isSelected: true)
}
