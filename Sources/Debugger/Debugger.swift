//
//  Debugger.swift
//
//
//  Created by Maxim Aliev on 15.03.2024.
//

import SwiftUI

public typealias ApplyCustomRequestModification = (
    _ customRules: [DebuggerConfigurationRule]?,
    _ request: inout URLRequest
) -> Void

public typealias ApplyCustomResponseModification = (
    _ customRules: [DebuggerConfigurationRule]?,
    _ responseData: inout Data,
    _ request: URLRequest
) -> Void

public final class Debugger: NSObject, ObservableObject {
    static let shared = Debugger()
    
    var isDebuggerEnabled = false
    var uniqueUrlPaths: [String] { networkSnifferViewModel.uniqueUrlPaths }
    
    @Published var configurationSwitcherViewModel: ConfigurationSwitcherViewModel
    @Published var networkSnifferViewModel: NetworkSnifferViewModel
    @Published var viewInspectorViewModel: ViewInspectorViewModel
    @Published var animationControlViewModel: AnimationControlViewModel
    @Published var systemDebuggerViewModel: SystemDebuggerViewModel
    
    private var networkModifierService: NetworkModifierService
    private var applyCustomRequestModification: ApplyCustomRequestModification?
    private var applyCustomResponseModification: ApplyCustomResponseModification?
    
    init(
        configurationSwitcherViewModel: ConfigurationSwitcherViewModel = ConfigurationSwitcherViewModel(),
        networkSnifferViewModel: NetworkSnifferViewModel = NetworkSnifferViewModel(),
        viewInspectorViewModel: ViewInspectorViewModel = ViewInspectorViewModel(),
        animationControlViewModel: AnimationControlViewModel = AnimationControlViewModel(),
        systemDebuggerViewModel: SystemDebuggerViewModel = SystemDebuggerViewModel(),
        networkModifierService: NetworkModifierService = NetworkModifierService()
    ) {
        self.configurationSwitcherViewModel = configurationSwitcherViewModel
        self.networkSnifferViewModel = networkSnifferViewModel
        self.viewInspectorViewModel = viewInspectorViewModel
        self.animationControlViewModel = animationControlViewModel
        self.systemDebuggerViewModel = systemDebuggerViewModel
        self.networkModifierService = networkModifierService
    }
    
    public static func setup(
        ignoreHosts: [String] = [],
        onConfigurationSwitched: (() -> Void)? = nil,
        applyCustomRequestModification: ApplyCustomRequestModification? = nil,
        applyCustomResponseModification: ApplyCustomResponseModification? = nil
    ) {
        shared.isDebuggerEnabled = true
        
        URLSessionConfiguration.setupSwizzledSessionConfiguration()
        
        DebugHTTPProtocol.ignoreHosts = ignoreHosts
        
        Debugger.shared.configurationSwitcherViewModel.onConfigurationSwitched = onConfigurationSwitched
        
        Debugger.shared.applyCustomRequestModification = applyCustomRequestModification
        Debugger.shared.applyCustomResponseModification = applyCustomResponseModification
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIWindow.updateSystemWidgetVisibility(Debugger.shared.systemDebuggerViewModel.isShowWidget)
        }
    }
    
    func save(request: RequestModel) {
        networkSnifferViewModel.save(request: request)
    }
    
    func applyDebugSettings(to request: inout URLRequest) {
        guard let selectedConfiguration = configurationSwitcherViewModel.selectedConfiguration else {
            return
        }
        
        networkModifierService.applyHostSpoofing(
            to: &request,
            selectedConfiguration: selectedConfiguration
        )
        networkModifierService.apply(
            rules: selectedConfiguration.customRules,
            to: &request
        )
        
        applyCustomRequestModification?(selectedConfiguration.customRules, &request)
    }
    
    func applyDebugSettings(to responseData: inout Data, on request: URLRequest) {
        guard let selectedConfiguration = configurationSwitcherViewModel.selectedConfiguration else {
            return
        }
        
        networkModifierService.apply(
            rules: selectedConfiguration.customRules,
            to: &responseData,
            on: request
        )
        
        applyCustomResponseModification?(selectedConfiguration.customRules, &responseData, request)
    }
    
    func isResponseWillBeModified(for request: URLRequest) -> Bool {
        return (configurationSwitcherViewModel.selectedConfiguration?.customRules ?? [])
            .filter { $0.type.isResponseType }
            .contains { networkModifierService.isMatching(request: request, to: $0) }
    }
    
    func hideDebugger() {
        UIWindow.updateDebuggerVisibility(false)
    }
}
