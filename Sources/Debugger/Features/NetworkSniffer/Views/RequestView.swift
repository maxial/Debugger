//
//  RequestView.swift
//
//
//  Created by Maxim Aliev on 16.03.2024.
//

import SwiftUI

enum RequestSection: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case overview = "Overview"
    case requestHeader = "Request Header"
    case requestBody = "Request Body"
    case responseHeader = "Response Header"
    case responseBody = "Response Body"
}

struct RequestView: View {
    @State private var showingActionSheet = false
    @State private var showingShareSheet = false
    @State private var searchText = ""
    
    @ObservedObject var requestModel: RequestModel
    
    var body: some View {
        List {
            SearchBar(text: $searchText)
                .listRow(isEditable: false, backgroundColor: .clear)
            
            ForEach(RequestSection.allCases) { section in
                RequestSectionView(viewModel: getRequestSectionViewModel(for: section))
            }
        }
        .listStyle(.plain)
        .navigationBarTitle(Text(requestModel.url?.relativePath ?? ""), displayMode: .inline)
        .navigationBarItems(trailing:
            Button(action: {
                showingActionSheet = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.systemBlue)
            }
        )
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Request Sharing Options"), buttons: [
                .default(Text("Share txt")) {
                    showingShareSheet = true
                },
                .cancel()
            ])
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: ShareUtils.getActivityItems(requests: [requestModel]))
        }
    }
    
    private func getRequestSectionViewModel(for section: RequestSection) -> RequestSectionViewModel {
        var description: String = ""
        
        switch section {
        case .overview:
            description = RequestModelBeautifier.overview(request: requestModel).string
        case .requestHeader:
            description = RequestModelBeautifier.header(requestModel.headers).string
        case .requestBody:
            description = RequestModelBeautifier.body(requestModel.httpBody)
        case .responseHeader:
            description = RequestModelBeautifier.header(requestModel.responseHeaders).string
        case .responseBody:
            description = RequestModelBeautifier.body(requestModel.dataResponse)
        }
        
        return RequestSectionViewModel(
            name: section.rawValue,
            description: description,
            searchText: searchText
        )
    }
}

#Preview {
    RequestView(
        requestModel: RequestModel(
            request: URLRequest(url: URL(string: "google.com")!),
            session: nil
        )
    )
}
