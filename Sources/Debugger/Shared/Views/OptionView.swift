//
//  OptionView.swift
//
//
//  Created by Maxim Aliev on 03.06.2024.
//

import SwiftUI

struct OptionView: View {
    let option: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text(option)
                .foregroundColor(.label)
                .font(.system(size: 14))
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .resizable()
                    .foregroundColor(.systemBlue)
                    .frame(width: 16, height: 16)
            }
        }
        .listRow(isEditable: true)
    }
}

#Preview {
    OptionView(option: "Option", isSelected: true)
}
