//
//  OptionsView.swift
//
//
//  Created by Maxim Aliev on 03.06.2024.
//

import SwiftUI

struct OptionsView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    
    let title: String
    let options: [String]
    let selectedOption: String
    let didSelectOption: ((String) -> Void)?
    
    var body: some View {
        List {
            ForEach(options, id: \.self) { option in
                OptionView(option: option, isSelected: option == selectedOption)
                    .onTapGesture {
                        didSelectOption?(option)
                        presentationMode.wrappedValue.dismiss()
                    }
            }
        }
        .list()
        .navigationTitle(title)
    }
}

#Preview {
    OptionsView(title: "Title", options: ["Option"], selectedOption: "Option", didSelectOption: nil)
}
