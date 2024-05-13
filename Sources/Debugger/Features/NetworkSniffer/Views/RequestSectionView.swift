//
//  RequestSectionView.swift
//
//
//  Created by Maxim Aliev on 19.03.2024.
//

import SwiftUI

struct RequestSectionView: View {
    var viewModel: RequestSectionViewModel
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    highlight(searchText: viewModel.searchText, in: viewModel.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.label)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                HStack {
                    highlight(searchText: viewModel.searchText, in: viewModel.description)
                        .font(.system(size: 12))
                        .foregroundColor(.label)
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    private func highlight(searchText: String, in text: String) -> some View {
        let searchText = searchText.lowercased()
        
        if #available(iOS 15.0, *) {
            var attributedString = AttributedString(text)
            
            var highlightAttributes = AttributeContainer()
            highlightAttributes.backgroundColor = UIColor.systemYellow
            
            var currentPosition = attributedString.startIndex
            
            while
                currentPosition < attributedString.endIndex,
                let range = attributedString[currentPosition...].range(of: searchText)
            {
                attributedString[range].mergeAttributes(highlightAttributes)
                currentPosition = range.upperBound
            }
            
            return Text(attributedString)
                .textSelection(.enabled)
        } else {
            guard searchText.isEmpty == false else {
                return Text(text)
            }
            
            var result: Text!
            let parts = text.components(separatedBy: searchText)
            
            for i in parts.indices {
                result = (result == nil ? Text(parts[i]) : result + Text(parts[i]))
                if i != parts.count - 1 {
                    result = result + Text(searchText).bold()
                }
            }
            
            return result ?? Text(text)
        }
    }
}

#Preview {
    RequestSectionView(
        viewModel: RequestSectionViewModel(name: "Title", description: "Desc")
    )
}
