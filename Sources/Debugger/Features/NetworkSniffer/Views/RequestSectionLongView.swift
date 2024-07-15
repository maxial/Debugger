//
//  RequestSectionLongView.swift
//
//
//  Created by Maxim Aliev on 15.07.2024.
//

import SwiftUI
import PDFKit

class PDFSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var searchResults: [PDFSelection] = []
}

struct RequestSectionLongViewWrapper: UIViewRepresentable {
    let url: URL
    @ObservedObject var viewModel: PDFSearchViewModel

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        if uiView.document == nil {
            if let document = PDFDocument(url: url) {
                uiView.document = document
            }
        }

        DispatchQueue.main.async {
            if let document = uiView.document {
                if !viewModel.searchText.isEmpty {
                    let selections = document.findString(viewModel.searchText, withOptions: .caseInsensitive)
                    viewModel.searchResults = selections
                    
                    uiView.highlightedSelections = selections
                } else {
                    uiView.highlightedSelections = nil
                }
            }
        }
    }
}

struct RequestSectionLongView: View {
    @StateObject private var viewModel = PDFSearchViewModel()
    let pdfURL: URL

    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: $viewModel.searchText, onCommit: {
                    viewModel.searchResults.removeAll()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                Button(action: {
                    viewModel.searchResults.removeAll()
                }) {
                    Text("Search")
                }
                .padding()
            }
            
            RequestSectionLongViewWrapper(url: pdfURL, viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
