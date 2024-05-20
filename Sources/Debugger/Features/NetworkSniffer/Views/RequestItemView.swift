//
//  RequestItemView.swift
//
//
//  Created by Maxim Aliev on 16.03.2024.
//

import SwiftUI

struct RequestItemView: View {
    @ObservedObject var requestModel: RequestModel
    
    var body: some View {
        let requestTagItemViewModels = RequestTagItem.allCases.compactMap {
            $0.getViewModel(from: requestModel)
        }
        
        VStack {
            FlexibleView(
                data: requestTagItemViewModels,
                content: { RequestTagItemView(viewModel: $0) }
            )
            
            HStack {
                Text(requestModel.urlWithoutQuery)
                    .font(.system(size: 12))
                    .foregroundColor(.label)
                
                Spacer()
            }
        }
        .frame(minHeight: 48)
    }
}

#Preview {
    RequestItemView(
        requestModel: RequestModel(
            request: URLRequest(url: URL(string: "google.com")!),
            session: nil
        )
    )
}
