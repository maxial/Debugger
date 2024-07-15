//
//  KeyValueView.swift
//
//
//  Created by Maxim Aliev on 06.04.2024.
//

import SwiftUI

struct KeyValueView: View {
    private var isEditableRow: Bool { isKeyEditable || isValueEditable || isEditable }
    
    @Binding var key: String
    @Binding var value: String
    var isKeyEditable = false
    var isValueEditable = false
    var isEditable = false
    
    var body: some View {
        HStack {
            if isKeyEditable {
                TextField(isValueEditable ? "Key" : "Type something...", text: $key)
                    .foregroundColor(.secondary)
            } else {
                Text(key)
                    .foregroundColor(.label)
            }
            
            Spacer()
            
            if isValueEditable {
                TextField(isKeyEditable ? "Value" : "Type something...", text: $value)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            } else {
                Text(value)
                    .foregroundColor(.secondary)
                    .font(.system(size: 14))
            }
        }
        .listRow(isEditable: isEditableRow)
    }
}

#Preview {
    KeyValueView(key: .constant("Key"), value: .constant("Value"))
}
