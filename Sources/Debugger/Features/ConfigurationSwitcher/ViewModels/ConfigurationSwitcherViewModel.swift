//
//  ConfigurationSwitcherViewModel.swift
//
//
//  Created by Maxim Aliev on 31.03.2024.
//

import SwiftUI
import Combine

final class ConfigurationSwitcherViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []
    
    let type: DebugFeature = .configurationSwitcher
    @Published var value: String = ""
    
    @Published var configurations: [DebuggerConfiguration] = []
    @Published var selectedConfiguration: DebuggerConfiguration?
    
    var onConfigurationSwitched: (() -> Void)?
    
    @AppStorage private var selectedConfigurationId: String
    
    init() {
        self._selectedConfigurationId = AppStorage(wrappedValue: "", "Debugger_Configuration")
        
        $selectedConfiguration
            .receive(on: DispatchQueue.main)
            .sink { [weak self] configuration in
                guard let self, let configuration else {
                    return
                }
                
                value = configuration.name
                selectedConfigurationId = configuration.id
                
                onConfigurationSwitched?()
            }
            .store(in: &cancellables)
        
        readConfigurations()
        
        selectedConfiguration = configurations.first { $0.id == selectedConfigurationId }
    }
    
    private func readConfigurations() {
        let plist = readPlist()
        configurations = plist.keys.sorted().compactMap { readConfiguration(named: $0, from: plist[$0]) }
    }
    
    private func readConfiguration(
        named name: String,
        from plist: Any?
    ) -> DebuggerConfiguration? {
        guard let plist = plist as? [String: Any] else {
            return nil
        }
        
        var baseURL: URL?
        var isSelected = false
        
        plist.keys.forEach { key in
            switch key {
            case ConfigurationSetting.defaultFlag.key:
                isSelected = plist[key] as? Bool ?? false
            case ConfigurationSetting.baseURL.key:
                guard
                    let baseURLString = plist[key] as? String,
                    let baseURLValue = URL(string: baseURLString)
                else {
                    break
                }
                baseURL = baseURLValue
            default:
                break
            }
        }
        
        guard let baseURL else {
            return nil
        }
        
        let configuration = DebuggerConfiguration(
            name: name,
            baseURL: baseURL
        )
        
        if isSelected {
            selectedConfiguration = configuration
        }
        
        return configuration
    }
    
    private func readPlist() -> [String: Any] {
        guard
            let plistPath = Bundle.main.path(forResource: "Debugger", ofType: "plist"),
            let plistDict = NSDictionary(contentsOfFile: plistPath) as? [String: Any]
        else {
            return [:]
        }
        
        return plistDict
    }
}
