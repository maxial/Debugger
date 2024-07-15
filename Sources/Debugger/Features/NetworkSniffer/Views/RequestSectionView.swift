//
//  RequestSectionView.swift
//
//
//  Created by Maxim Aliev on 19.03.2024.
//

import SwiftUI

struct RequestSectionView: View {
    private enum Constants {
        static let descriptionThreshold = 5000
    }
    
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
                    if viewModel.description.count > Constants.descriptionThreshold {
                        if let pdfUrl = createPdfUrl(text: viewModel.description) {
                            NavigationLink(
                                destination: RequestSectionLongView(pdfURL: pdfUrl),
                                label: {
                                    Text("Response Data")
                                        .font(.system(size: 12))
                                        .foregroundColor(.systemBlue)
                                        .frame(height: 40)
                                }
                            )
                        }
                    } else {
                        highlight(searchText: viewModel.searchText, in: viewModel.description)
                            .font(.system(size: 12))
                            .foregroundColor(.label)
                    }
                    
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
    
    private func createPdfUrl(text: String) -> URL? {
        let A4paperSize = CGSize(width: 595, height: 842)
        let pdf = SimplePDF(pageSize: A4paperSize)
        
        pdf.addText(text)
        
        let pdfPath = getDocumentsDirectory().appendingPathComponent("sample.pdf")
        
        let pdfData = pdf.generatePDFdata()

        do {
            try pdfData.write(to: pdfPath, options: .atomic)
            print("PDF создан по пути: \(pdfPath)")
            return pdfPath
        } catch {
            print("Не удалось создать PDF: \(error)")
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

#Preview {
    RequestSectionView(
        viewModel: RequestSectionViewModel(name: "Title", description: "Desc")
    )
}
