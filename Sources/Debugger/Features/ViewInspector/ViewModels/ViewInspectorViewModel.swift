//
//  ViewInspectorViewModel.swift
//
//
//  Created by Maxim Aliev on 03.05.2024.
//

import SwiftUI
import Combine

final class ViewInspectorViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    private let viewInspectorService: ViewInspectorService
    
    let type: DebugFeature = .viewInspector
    @Published var value: String = ""
    
    @Published var configuration: ViewInspectorConfiguration
    
    init(viewInspectorService: ViewInspectorService = ViewInspectorService()) {
        self.viewInspectorService = viewInspectorService
        self.configuration = viewInspectorService.configuration
        
        $configuration
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.viewInspectorService.configuration = $0
                self?.value = $0.rawValue
                self?.hideDebugger()
            }
            .store(in: &cancellables)
    }
    
    func hideDebugger() {
        UIWindow.updateDebuggerVisibility(false)
    }
}
