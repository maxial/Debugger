//
//  AttributesInspectorView.swift
//
//
//  Created by Maxim Aliev on 10.05.2024.
//

import SwiftUI

struct AttributesInspectorView: View {
    @ObservedObject var viewModel: AttributesInspectorViewModel
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack {
                KeyValueInfoView(
                    key: "Class Name",
                    value: viewModel.className
                )
                
                KeyValueInfoView(
                    key: "Frame",
                    value: viewModel.frame
                )
                
                if let font = viewModel.font {
                    KeyValueInfoView(
                        key: "Font",
                        value: font
                    )
                }
                
                KeyValueInfoView(
                    key: "Background",
                    value: viewModel.backgroundColor
                )
                
                KeyValueInfoView(
                    key: "Clips To Bounds",
                    value: viewModel.clipsToBounds
                )
                
                KeyValueInfoView(
                    key: "Alpha",
                    value: viewModel.alpha
                )
                
                KeyValueInfoView(
                    key: "User Interaction Enabled",
                    value: viewModel.isUserInteractionEnabled
                )
            }
            .padding()
            .list(backgroundColor: .secondarySystemBackground, cornerRadius: 16)
        }
        .padding(.horizontal, 28)
    }
}

#Preview {
    AttributesInspectorView(viewModel: AttributesInspectorViewModel(view: UIView()))
}
