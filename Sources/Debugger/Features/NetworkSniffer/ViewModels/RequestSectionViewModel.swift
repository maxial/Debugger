//
//  RequestSectionViewModel.swift
//
//
//  Created by Maxim Aliev on 19.03.2024.
//

import SwiftUI

final class RequestSectionViewModel: ObservableObject {
    @Published var name: String
    @Published var description: String
    @Published var searchText: String
    
    init(name: String, description: String, searchText: String = "") {
        self.name = name
        self.description = description
        self.searchText = searchText
    }
}
