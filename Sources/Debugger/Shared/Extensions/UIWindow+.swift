//
//  UIWindow+.swift
//
//
//  Created by Maxim Aliev on 15.03.2024.
//

import UIKit
import SwiftUI

extension UIWindow {
    private static var _scene: UIWindowScene? { UIApplication.shared.connectedScenes.first as? UIWindowScene }
    
    private static var _widgetWindow: UIWindow?
    private static var _attributesInspectorWindow: UIWindow?
    private static var _debuggerWindow: UIWindow?
    private static var _debuggerController: UIHostingController<DebuggerView>?
    
    private static var _debuggerAnimationDuration: CGFloat = 0.3
    
    static var allDebuggableWindows: [UIWindow] { getAllDebuggableWindows() }
    static var keyWindow: UIWindow? { _scene?.windows.first(where: \.isKeyWindow) }
    static var safeAreaInsets: UIEdgeInsets { keyWindow?.safeAreaInsets ?? .zero }
    
    var isDebuggableWindow: Bool { UIWindow.allDebuggableWindows.contains(self) }
    var rootView: UIView? { rootViewController?.view }
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard Debugger.shared.isDebuggerEnabled && motion == .motionShake else {
            return
        }
        
        if UIWindow._debuggerWindow == nil || UIWindow._debuggerWindow?.isHidden == true {
            endEditing(true)
            UIWindow.updateDebuggerVisibility(true)
        }
    }
    
    static func updateSystemWidgetVisibility(_ isVisible: Bool) {
        if isVisible && _widgetWindow == nil {
            createWidgetWindow()
        }
        
        _widgetWindow?.isHidden = isVisible == false
    }
    
    static func updateAttributesInspectorVisibility(
        _ isVisible: Bool,
        for view: UIView?,
        isUserInteractionEnabledBackup: Bool? = nil
    ) {
        if let view = view, isVisible {
            if _attributesInspectorWindow == nil {
                createAttributesInspectorWindow(
                    for: view,
                    isUserInteractionEnabledBackup: isUserInteractionEnabledBackup
                )
            }
            _attributesInspectorWindow?.isHidden = false
        } else {
            _attributesInspectorWindow?.isHidden = true
            _attributesInspectorWindow?.rootViewController = nil
            _attributesInspectorWindow?.removeFromSuperview()
            _attributesInspectorWindow = nil
        }
    }
    
    static func updateDebuggerVisibility(_ isVisible: Bool) {
        if isVisible {
            if _debuggerWindow == nil {
                createDebuggerWindow()
            }
            
            _debuggerWindow?.isHidden = false
            _debuggerWindow?.frame.origin.y = _debuggerWindow?.frame.height ?? .zero
        }
        
        UIView.animate(withDuration: _debuggerAnimationDuration, animations: {
            _debuggerWindow?.frame.origin.y = isVisible ? .zero : _debuggerWindow?.frame.height ?? .zero
        }, completion: { isFinished in
            if isFinished && isVisible == false {
                _debuggerWindow?.isHidden = true
            }
        })
    }
    
    private static func getAllDebuggableWindows() -> [UIWindow] {
        return UIApplication.shared.connectedScenes
            .reduce([], { result, scene in
                let windows = (scene as? UIWindowScene)?.windows ?? []
                return result + windows.filter {
                    $0 != _debuggerWindow &&
                    $0 != _widgetWindow &&
                    $0 != _attributesInspectorWindow &&
                    String(describing: type(of: $0)).contains("UITextEffectsWindow") == false &&
                    String(describing: type(of: $0)).contains("UIRemoteKeyboardWindow") == false
                }
            })
    }
    
    private static func createDebuggerWindow() {
        guard let scene = _scene, let keyWindow = keyWindow else {
            return
        }
        
        if _debuggerController == nil {
            _debuggerController = UIHostingController(
                rootView: DebuggerView(
                    configurationSwitcherViewModel: Debugger.shared.configurationSwitcherViewModel,
                    networkSnifferViewModel: Debugger.shared.networkSnifferViewModel,
                    viewInspectorViewModel: Debugger.shared.viewInspectorViewModel,
                    animationControlViewModel: Debugger.shared.animationControlViewModel,
                    systemDebuggerViewModel: Debugger.shared.systemDebuggerViewModel
                )
            )
            
            _debuggerController?.view.frame = keyWindow.bounds
        }
        
        _debuggerWindow = UIWindow(windowScene: scene)
        _debuggerWindow?.frame = keyWindow.frame
        _debuggerWindow?.windowLevel = UIWindow.Level.alert + 2
        _debuggerWindow?.rootViewController = _debuggerController
    }
    
    private static func createWidgetWindow() {
        guard let scene = _scene, let keyWindow = keyWindow else {
            return
        }
        
        let systemWidgetView = SystemDebuggerWidgetView(viewModel: Debugger.shared.systemDebuggerViewModel)
        let systemWidgetController = UIHostingController(rootView: systemWidgetView)
        
        systemWidgetController.view.backgroundColor = .clear
        systemWidgetController.view.frame = CGRect(
            origin: CGPoint(x: keyWindow.center.x - systemWidgetView.externalSize.width / 2, y: .zero),
            size: systemWidgetView.externalSize
        )
        
        _widgetWindow = UIWindow(windowScene: scene)
        _widgetWindow?.frame = systemWidgetController.view.frame.inset(by: .bottom(-UIWindow.safeAreaInsets.top))
        _widgetWindow?.backgroundColor = .clear
        _widgetWindow?.windowLevel = UIWindow.Level.alert + 1
        _widgetWindow?.rootViewController = systemWidgetController
        
        systemWidgetController.view.addGestureRecognizer(
            UIPanGestureRecognizer(
                target: keyWindow,
                action: #selector(handleSystemWidgetPanGesture)
            )
        )
    }
    
    private static func createAttributesInspectorWindow(
        for view: UIView,
        isUserInteractionEnabledBackup: Bool? = nil
    ) {
        guard let scene = _scene, let keyWindow = keyWindow else {
            return
        }
        
        let attributesInspectorView = AttributesInspectorView(
            viewModel: AttributesInspectorViewModel(
                view: view,
                isUserInteractionEnabledBackup: isUserInteractionEnabledBackup
            )
        )
        let attributesInspectorController = UIHostingController(rootView: attributesInspectorView)
        
        attributesInspectorController.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        attributesInspectorController.view.frame = keyWindow.frame
        
        _attributesInspectorWindow = UIWindow(windowScene: scene)
        _attributesInspectorWindow?.backgroundColor = .clear
        _attributesInspectorWindow?.windowLevel = UIWindow.Level.alert
        _attributesInspectorWindow?.rootViewController = attributesInspectorController
        
        attributesInspectorController.view.addGestureRecognizer(
            UITapGestureRecognizer(
                target: keyWindow,
                action: #selector(handleAttributesInspectorOutsideTapGesture)
            )
        )
    }
    
    @objc private func handleSystemWidgetPanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let window = gesture.view?.window else {
            return
        }
        
        let translation = gesture.translation(in: window)
        window.center = CGPoint(x: window.center.x + translation.x, y: window.center.y + translation.y)
        gesture.setTranslation(.zero, in: window)
    }
    
    @objc private func handleAttributesInspectorOutsideTapGesture(_ gesture: UITapGestureRecognizer) {
        UIWindow.updateAttributesInspectorVisibility(false, for: nil)
    }
}
