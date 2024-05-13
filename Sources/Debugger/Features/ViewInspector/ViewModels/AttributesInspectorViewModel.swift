//
//  AttributesInspectorViewModel.swift
//
//
//  Created by Maxim Aliev on 10.05.2024.
//

import SwiftUI

final class AttributesInspectorViewModel: ObservableObject {
    @Published var className: String
    @Published var frame: String
    @Published var font: String?
    @Published var backgroundColor: String
    @Published var clipsToBounds: String
    @Published var alpha: String
    @Published var isUserInteractionEnabled: String
    
    init(view: UIView, isUserInteractionEnabledBackup: Bool? = nil) {
        self.className = String(describing: view.classForCoder)
        
        let origin = "Origin: (\(Int(view.frame.origin.x)), \(Int(view.frame.origin.y)))"
        let size = "Size: (\(Int(view.frame.size.width)), \(Int(view.frame.size.height)))"
        self.frame = origin + " " + size
        
        var font: UIFont?
        if let label = view as? UILabel {
            font = label.font
        } else if let textField = view as? UITextField {
            font = textField.font
        } else if let textView = view as? UITextView {
            font = textView.font
        }
        if let font {
            self.font = font.fontName + " " + font.pointSize.description.capitalized
        }
        
        self.backgroundColor = view.backgroundColor?.hex ?? "Transparent"
        self.clipsToBounds = view.clipsToBounds.description.capitalized
        self.alpha = view.alpha.description
        self.isUserInteractionEnabled = isUserInteractionEnabledBackup?.description.capitalized ?? ""
    }
}
