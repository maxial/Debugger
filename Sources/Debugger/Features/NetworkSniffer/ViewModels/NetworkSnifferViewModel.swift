//
//  NetworkSnifferViewModel.swift
//  
//
//  Created by Maxim Aliev on 17.03.2024.
//

import Foundation

final class NetworkSnifferViewModel: ObservableObject {
    let type: DebugFeature = .networkSniffer
    var value: String { requests.count.description }
    
    @Published var requests: [RequestModel] = []
    
    var uniqueUrlPaths: [String] { getUniqueUrlPaths() }
    
    func save(request: RequestModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let index = requests.firstIndex(where: { $0.id == request.id }) {
                requests[index] = request
            } else {
                requests.insert(request, at: .zero)
            }
        }
    }
    
    func removeRequests(at offsets: IndexSet) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            requests.remove(atOffsets: offsets)
        }
    }
    
    func removeAllRequests() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            requests.removeAll()
        }
    }
    
    private func getUniqueUrlPaths() -> [String] {
        var set = Set<String>()
        let uniqueArray = requests.compactMap { $0.url?.path }.filter { set.insert($0).inserted }
        return uniqueArray
    }
}
