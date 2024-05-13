//
//  NetworkSnifferView.swift
//
//
//  Created by Maxim Aliev on 16.03.2024.
//

import SwiftUI
import Combine

struct NetworkSnifferView: View {
    @ObservedObject var viewModel: NetworkSnifferViewModel
    
    @State private var searchText = ""
    @State private var showingActionSheet = false
    
    var body: some View {
        List {
            SearchBar(text: $searchText)
                .listRow(backgroundColor: .clear)
            
            ForEach(getFilteredRequests()) { request in
                RequestItemView(requestModel: request)
                    .listNavigationRow(destination: RequestView(requestModel: request))
            }
            .onDelete(perform: removeRequests)
        }
        .list()
        .navigationTitle(viewModel.type.name)
        .navigationBarItems(trailing:
            Button(action: {
                self.showingActionSheet = true
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.systemBlue)
            }
        )
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text("Requests List Actions"), buttons: [
                .default(Text("Clear"), action: removeAllRequests),
                .cancel()
            ])
        }
        .navigationViewStyle(.stack)
    }
    
    private func getFilteredRequests() -> [RequestModel] {
        return searchText.isEmpty
            ? viewModel.requests
            : viewModel.requests
            .filter { 
                let urlString = $0.url?.absoluteString.lowercased()
                return urlString?.contains(searchText.lowercased()) ?? false
            }
    }
    
    private func removeRequests(at offsets: IndexSet) {
        viewModel.removeRequests(at: offsets)
    }
    
    private func removeAllRequests() {
        viewModel.removeAllRequests()
    }
}

#Preview {
    NetworkSnifferView(viewModel: NetworkSnifferViewModel())
}
