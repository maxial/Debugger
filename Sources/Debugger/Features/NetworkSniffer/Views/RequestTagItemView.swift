//
//  RequestTagItemView.swift
//
//
//  Created by Maxim Aliev on 24.03.2024.
//

import SwiftUI

struct RequestTagItemView: View {
    @ObservedObject var viewModel: RequestTagItemViewModel
    
    var body: some View {
        let foregroundColor: Color = viewModel.color == nil ? .secondaryLabel : .white
        let padding: CGFloat = viewModel.color == nil ? .zero : 4
        
        HStack(spacing: 4) {
            if let imageName = viewModel.imageName {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 9, height: 9)
                    .foregroundColor(foregroundColor)
            }
            
            Text(viewModel.text)
                .font(.system(size: 12))
                .foregroundColor(foregroundColor)
        }
        .padding(padding)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(viewModel.color ?? .clear)
        )
    }
}

#Preview {
    RequestTagItemView(viewModel: RequestTagItemViewModel(text: "POST"))
}
