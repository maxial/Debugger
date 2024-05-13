//
//  RequestTagItemViewModel.swift
//  
//
//  Created by Maxim Aliev on 25.03.2024.
//

import SwiftUI

final class RequestTagItemViewModel: ObservableObject, Hashable {
    @Published var imageName: String?
    @Published var text: String
    @Published var color: Color?
    
    init(imageName: String? = nil, text: String, color: Color? = nil) {
        self.imageName = imageName
        self.text = text
        self.color = color
    }
    
    static func == (lhs: RequestTagItemViewModel, rhs: RequestTagItemViewModel) -> Bool {
        lhs.imageName == rhs.imageName && lhs.text == rhs.text
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(imageName)
        hasher.combine(text)
    }
}
