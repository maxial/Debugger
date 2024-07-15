//
//  KeyValueInfoView.swift
//
//
//  Created by Maxim Aliev on 11.05.2024.
//

import SwiftUI

struct KeyValueInfoView: View {
    var key: String
    var value: String
    
    var body: some View {
        HStack {
            Text(key)
                .font(.system(size: 14))
                .foregroundColor(.label)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.secondary)
                .font(.system(size: 13))
        }
        .listRow(isEditable: false)
        .frame(height: 30)
    }
}

#Preview {
    KeyValueInfoView(key: "Key", value: "Value")
}
