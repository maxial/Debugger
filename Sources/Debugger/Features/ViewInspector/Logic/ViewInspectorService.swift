//
//  ViewInspectorService.swift
//
//
//  Created by Maxim Aliev on 03.05.2024.
//

import SwiftUI

final class ViewInspectorService {
    var configuration: ViewInspectorConfiguration = .off { didSet { updateConfiguration() } }
    
    init() {
        swizzleMethods()
    }
    
    private func swizzleMethods() {
        DispatchQueue.once {
            UIView.swizzle(
                originalSelector: #selector(UIView.layoutSubviews),
                with: #selector(UIView.alterLayoutSubviews)
            )
        }
    }
    
    private func updateConfiguration() {
        UIView.viewInspectorConfiguration = configuration
    }
}
