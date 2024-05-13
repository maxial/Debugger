//
//  SystemDebuggerViewModel.swift
//
//
//  Created by Maxim Aliev on 25.04.2024.
//

import SwiftUI
import Combine

final class SystemDebuggerViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    private let systemMetricService: SystemMetricService
    
    let type: DebugFeature = .systemDebugger
    @Published var value: String = ""
    @Published var metrics: [SystemMetric] = []
    @Published var isDetectLeaks: Bool
    
    @AppStorage var isShowWidget: Bool { didSet { toggleSystemWidgetVisibility() } }
    
    init(systemMetricService: SystemMetricService = SystemMetricService()) {
        self._isShowWidget = AppStorage(wrappedValue: false, "Debugger_System_IsShowWidget")
        
        self.systemMetricService = systemMetricService
        self.isDetectLeaks = systemMetricService.isDetectLeaks
        
        $isDetectLeaks
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.systemMetricService.isDetectLeaks = $0
            }
            .store(in: &cancellables)
        
        systemMetricService.delegate = self
    }
    
    func getWidgetText() -> String {
        return metrics.reduce("") { $0 + $1.type.widgetPrefix + $1.value + $1.type.widgetSeparator }
    }
    
    private func toggleSystemWidgetVisibility() {
        UIWindow.updateSystemWidgetVisibility(isShowWidget)
    }
}

extension SystemDebuggerViewModel: SystemMetricServiceDelegate {
    func metricsReceived(_ metrics: [SystemMetric]) {
        self.metrics = metrics
    }
}
