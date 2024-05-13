//
//  Debugger.swift
//
//
//  Created by Maxim Aliev on 15.03.2024.
//

import SwiftUI

public typealias ApplyCustomModification = ((
    _ request: inout NSMutableURLRequest,
    _ customRules: [DebuggerConfigurationRule]?) -> Void
)

public final class Debugger: NSObject, ObservableObject {
    static let shared = Debugger()
    
    var isDebuggerEnabled = false
    
    @Published var configurationSwitcherViewModel: ConfigurationSwitcherViewModel
    @Published var networkSnifferViewModel: NetworkSnifferViewModel
    @Published var viewInspectorViewModel: ViewInspectorViewModel
    @Published var animationControlViewModel: AnimationControlViewModel
    @Published var systemDebuggerViewModel: SystemDebuggerViewModel
    
    private var requestModifierService: RequestModifierService
    private var applyCustomModification: ApplyCustomModification?
    
    init(
        configurationSwitcherViewModel: ConfigurationSwitcherViewModel = ConfigurationSwitcherViewModel(),
        networkSnifferViewModel: NetworkSnifferViewModel = NetworkSnifferViewModel(),
        viewInspectorViewModel: ViewInspectorViewModel = ViewInspectorViewModel(),
        animationControlViewModel: AnimationControlViewModel = AnimationControlViewModel(),
        systemDebuggerViewModel: SystemDebuggerViewModel = SystemDebuggerViewModel(),
        requestModifierService: RequestModifierService = RequestModifierService()
    ) {
        self.configurationSwitcherViewModel = configurationSwitcherViewModel
        self.networkSnifferViewModel = networkSnifferViewModel
        self.viewInspectorViewModel = viewInspectorViewModel
        self.animationControlViewModel = animationControlViewModel
        self.systemDebuggerViewModel = systemDebuggerViewModel
        self.requestModifierService = requestModifierService
    }
    
    public static func setup(
        ignoreHosts: [String] = [],
        onConfigurationSwitched: (() -> Void)? = nil,
        applyCustomModification: ApplyCustomModification? = nil
    ) {
        shared.isDebuggerEnabled = true
        
        URLSessionConfiguration.setupSwizzledSessionConfiguration()
        
        DebugHTTPProtocol.ignoreHosts = ignoreHosts
        Debugger.shared.configurationSwitcherViewModel.onConfigurationSwitched = onConfigurationSwitched
        Debugger.shared.applyCustomModification = applyCustomModification
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            UIWindow.updateSystemWidgetVisibility(Debugger.shared.systemDebuggerViewModel.isShowWidget)
        }
    }
    
    func save(request: RequestModel) {
        networkSnifferViewModel.save(request: request)
    }
    
    func applyDebugSettings(to request: inout NSMutableURLRequest) {
        guard let selectedConfiguration = configurationSwitcherViewModel.selectedConfiguration else {
            return
        }
        
        requestModifierService.applyHostSpoofing(to: &request, selectedConfiguration: selectedConfiguration)
        requestModifierService.applyCustomRules(selectedConfiguration.customRules, to: &request)
        
        applyCustomModification?(&request, selectedConfiguration.customRules)
    }
    
    func hideDebugger() {
        UIWindow.updateDebuggerVisibility(false)
    }
}
