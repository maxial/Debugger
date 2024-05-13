//
//  UIView+.swift
//
//
//  Created by Maxim Aliev on 03.05.2024.
//

import UIKit

extension UIView {
    private static var _borderLayerKey: UInt8 = 1
    private static var _tapGestureRecognizerKey: UInt8 = 2
    private static var _distanceLayerKey: UInt8 = 3
    private static var _outlinesLayerKey: UInt8 = 4
    private static var _horizontalDistanceLabelKey: UInt8 = 5
    private static var _verticalDistanceLabelKey: UInt8 = 6
    private static var _layoutInspectorFirstViewKey: UInt8 = 7
    private static var _layoutInspectorSecondViewKey: UInt8 = 8
    private static var _isUserInteractionEnabledBackupKey: UInt8 = 9
    
    private weak var _borderLayer: CALayer? {
        get { getAssociatedObject(self, key: &UIView._borderLayerKey) }
        set { setAssociatedObject(self, key: &UIView._borderLayerKey, value: newValue) }
    }
    
    private weak var _tapGestureRecognizer: UITapGestureRecognizer? {
        get { getAssociatedObject(self, key: &UIView._tapGestureRecognizerKey) }
        set { setAssociatedObject(self, key: &UIView._tapGestureRecognizerKey, value: newValue) }
    }
    
    private static var _distanceLayer: CAShapeLayer? {
        get { getAssociatedObject(self, key: &UIView._distanceLayerKey) }
        set { setAssociatedObject(self, key: &UIView._distanceLayerKey, value: newValue) }
    }
    
    private static var _outlinesLayer: CAShapeLayer? {
        get { getAssociatedObject(self, key: &UIView._outlinesLayerKey) }
        set { setAssociatedObject(self, key: &UIView._outlinesLayerKey, value: newValue) }
    }
    
    private static var _horizontalDistanceLabel: UILabel? {
        get { getAssociatedObject(self, key: &UIView._horizontalDistanceLabelKey) }
        set { setAssociatedObject(self, key: &UIView._horizontalDistanceLabelKey, value: newValue) }
    }
    
    private static var _verticalDistanceLabel: UILabel? {
        get { getAssociatedObject(self, key: &UIView._verticalDistanceLabelKey) }
        set { setAssociatedObject(self, key: &UIView._verticalDistanceLabelKey, value: newValue) }
    }
    
    private static var _layoutInspectorFirstView: UIView? {
        get { getAssociatedObject(self, key: &UIView._layoutInspectorFirstViewKey) }
        set { setAssociatedObject(self, key: &UIView._layoutInspectorFirstViewKey, value: newValue) }
    }
    
    private static var _layoutInspectorSecondView: UIView? {
        get { getAssociatedObject(self, key: &UIView._layoutInspectorSecondViewKey) }
        set { setAssociatedObject(self, key: &UIView._layoutInspectorSecondViewKey, value: newValue) }
    }
    
    private var _isUserInteractionEnabledBackup: Bool? {
        get { getAssociatedObject(self, key: &UIView._isUserInteractionEnabledBackupKey) }
        set { setAssociatedObject(self, key: &UIView._isUserInteractionEnabledBackupKey, value: newValue) }
    }
    
    static var viewInspectorConfiguration: ViewInspectorConfiguration = .off {
        didSet { UIWindow.allDebuggableWindows.forEach { $0.rootView?.updateConfigurationRecursively() } }
    }
    
    func updateConfiguration(isResetNeeded: Bool = false) {
        guard getIsAllowedViewType() else {
            return
        }
        
        if isResetNeeded {
            resetConfiguration()
        }
        
        switch UIView.viewInspectorConfiguration {
        case .attributesInspector:
            updateBordersVisibility(true)
            updateTapGestureRecognizerActive(true)
        case .layoutInspector:
            updateTapGestureRecognizerActive(true)
        case .off:
            break
        }
    }
    
    private func updateConfigurationRecursively() {
        updateConfiguration(isResetNeeded: true)
        subviews.forEach { $0.updateConfigurationRecursively() }
    }
    
    private func resetConfiguration() {
        switch UIView.viewInspectorConfiguration {
        case .attributesInspector:
            resetDrawnLayoutConstraints()
            resetLayoutInspectorViews()
        case .layoutInspector:
            updateBordersVisibility(false)
        case .off:
            resetDrawnLayoutConstraints()
            resetLayoutInspectorViews()
            updateBordersVisibility(false)
            updateTapGestureRecognizerActive(false)
        }
    }
    
    private func updateBordersVisibility(_ isVisible: Bool) {
        if isVisible {
            if _borderLayer == nil {
                let borderLayer = CALayer()
                _borderLayer = borderLayer
                _borderLayer?.cornerRadius = layer.cornerRadius
                layer.addSublayer(borderLayer)
            }
            
            _borderLayer?.borderColor = UIView.viewInspectorConfiguration == .attributesInspector
                ? UIColor.systemRed.cgColor
                : UIColor.systemBlue.cgColor
            _borderLayer?.borderWidth = UIView.viewInspectorConfiguration == .attributesInspector
                ? 1
                : 2
            _borderLayer?.frame = bounds
        } else {
            _borderLayer?.removeFromSuperlayer()
            _borderLayer = nil
        }
    }
    
    private func updateTapGestureRecognizerActive(_ isActive: Bool) {
        if isActive {
            if _tapGestureRecognizer == nil {
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                addGestureRecognizer(tapGestureRecognizer)
                _tapGestureRecognizer = tapGestureRecognizer
            }
            
            _isUserInteractionEnabledBackup = isUserInteractionEnabled
            isUserInteractionEnabled = true
        } else {
            if let _tapGestureRecognizer {
                removeGestureRecognizer(_tapGestureRecognizer)
            }
            _tapGestureRecognizer = nil
            
            if let isUserInteractionEnabledBackup = _isUserInteractionEnabledBackup {
                isUserInteractionEnabled = isUserInteractionEnabledBackup
            }
            _isUserInteractionEnabledBackup = nil
        }
    }
    
    @objc private func handleTap(_ recognizer: UITapGestureRecognizer) {
        switch UIView.viewInspectorConfiguration {
        case .attributesInspector:
            UIWindow.updateAttributesInspectorVisibility(
                true,
                for: self,
                isUserInteractionEnabledBackup: _isUserInteractionEnabledBackup
            )
        case .layoutInspector:
            drawLayoutConstraints()
        case .off:
            break
        }
    }
    
    private func drawLayoutConstraints() {
        resetDrawnLayoutConstraints()
        
        if UIView._layoutInspectorFirstView == nil {
            UIView._layoutInspectorFirstView = self
        } else if UIView._layoutInspectorFirstView == self {
            UIView._layoutInspectorFirstView?.updateBordersVisibility(false)
            UIView._layoutInspectorFirstView = nil
            if UIView._layoutInspectorSecondView != nil {
                UIView._layoutInspectorFirstView = UIView._layoutInspectorSecondView
            }
        } else if UIView._layoutInspectorSecondView == nil {
            UIView._layoutInspectorSecondView = self
        } else if UIView._layoutInspectorSecondView == self {
            UIView._layoutInspectorSecondView?.updateBordersVisibility(false)
            UIView._layoutInspectorSecondView = nil
        } else {
            UIView._layoutInspectorFirstView?.updateBordersVisibility(false)
            UIView._layoutInspectorFirstView = UIView._layoutInspectorSecondView
            UIView._layoutInspectorSecondView = self
        }
        
        UIView._layoutInspectorFirstView?.updateBordersVisibility(true)
        UIView._layoutInspectorSecondView?.updateBordersVisibility(true)
        
        if
            let firstView = UIView._layoutInspectorFirstView,
            let secondView = UIView._layoutInspectorSecondView,
            let keyWindow = UIWindow.keyWindow
        {
            let firstFrame = keyWindow.convert(firstView.frame, from: firstView.superview)
            let secondFrame = keyWindow.convert(secondView.frame, from: secondView.superview)
            
            let distancesPath = UIBezierPath()
            
            // Вертикальная линия
            var minY: CGFloat?
            var maxY: CGFloat?
            var verticalDistance: CGFloat?
            
            if firstFrame.minY > secondFrame.maxY {
                distancesPath.move(to: CGPoint(x: firstFrame.midX, y: secondFrame.maxY + 2))
                distancesPath.addLine(to: CGPoint(x: firstFrame.midX, y: firstFrame.minY - 2))
                minY = secondFrame.maxY
                maxY = firstFrame.minY
                verticalDistance = firstFrame.minY - secondFrame.maxY
            } else if firstFrame.maxY < secondFrame.minY {
                distancesPath.move(to: CGPoint(x: firstFrame.midX, y: secondFrame.minY - 2))
                distancesPath.addLine(to: CGPoint(x: firstFrame.midX, y: firstFrame.maxY + 2))
                minY = firstFrame.maxY
                maxY = secondFrame.minY
                verticalDistance = firstFrame.maxY - secondFrame.minY
            }
            if let minY, let maxY {
                distancesPath.move(to: CGPoint(x: firstFrame.midX - 5, y: minY + 2))
                distancesPath.addLine(to: CGPoint(x: firstFrame.midX - 1, y: minY + 2))
                distancesPath.move(to: CGPoint(x: firstFrame.midX + 1, y: minY + 2))
                distancesPath.addLine(to: CGPoint(x: firstFrame.midX + 5, y: minY + 2))
                distancesPath.move(to: CGPoint(x: firstFrame.midX - 5, y: maxY - 2))
                distancesPath.addLine(to: CGPoint(x: firstFrame.midX - 1, y: maxY - 2))
                distancesPath.move(to: CGPoint(x: firstFrame.midX + 1, y: maxY - 2))
                distancesPath.addLine(to: CGPoint(x: firstFrame.midX + 5, y: maxY - 2))
            }
            
            // Горизонтальная линия
            var minX: CGFloat?
            var maxX: CGFloat?
            var horizontalDistance: CGFloat?
            
            if firstFrame.minX > secondFrame.maxX {
                distancesPath.move(to: CGPoint(x: secondFrame.maxX + 2, y: firstFrame.midY))
                distancesPath.addLine(to: CGPoint(x: firstFrame.minX - 2, y: firstFrame.midY))
                minX = secondFrame.maxX
                maxX = firstFrame.minX
                horizontalDistance = firstFrame.minX - secondFrame.maxX
            } else if firstFrame.maxX < secondFrame.minX {
                distancesPath.move(to: CGPoint(x: secondFrame.minX - 2, y: firstFrame.midY))
                distancesPath.addLine(to: CGPoint(x: firstFrame.maxX + 2, y: firstFrame.midY))
                minX = firstFrame.maxX
                maxX = secondFrame.minX
                horizontalDistance = secondFrame.minX - firstFrame.maxX
            }
            if let minX, let maxX {
                distancesPath.move(to: CGPoint(x: minX + 2, y: firstFrame.midY - 5))
                distancesPath.addLine(to: CGPoint(x: minX + 2, y: firstFrame.midY - 1))
                distancesPath.move(to: CGPoint(x: minX + 2, y: firstFrame.midY + 1))
                distancesPath.addLine(to: CGPoint(x: minX + 2, y: firstFrame.midY + 5))
                distancesPath.move(to: CGPoint(x: maxX - 2, y: firstFrame.midY - 5))
                distancesPath.addLine(to: CGPoint(x: maxX - 2, y: firstFrame.midY - 1))
                distancesPath.move(to: CGPoint(x: maxX - 2, y: firstFrame.midY + 1))
                distancesPath.addLine(to: CGPoint(x: maxX - 2, y: firstFrame.midY + 5))
            }
            
            UIView._distanceLayer = CAShapeLayer()
            UIView._distanceLayer?.path = distancesPath.cgPath
            UIView._distanceLayer?.strokeColor = UIColor.systemBlue.cgColor
            UIView._distanceLayer?.lineWidth = 2
            UIView._distanceLayer?.fillColor = nil
            
            keyWindow.layer.addSublayer(UIView._distanceLayer!)
            
            let outlinesPath = UIBezierPath()
            
            outlinesPath.move(to: CGPoint(x: .zero, y: firstFrame.minY))
            outlinesPath.addLine(to: CGPoint(x: keyWindow.bounds.maxX, y: firstFrame.minY))
            outlinesPath.move(to: CGPoint(x: .zero, y: firstFrame.maxY))
            outlinesPath.addLine(to: CGPoint(x: keyWindow.bounds.maxX, y: firstFrame.maxY))
            outlinesPath.move(to: CGPoint(x: firstFrame.minX, y: .zero))
            outlinesPath.addLine(to: CGPoint(x: firstFrame.minX, y: keyWindow.bounds.maxY))
            outlinesPath.move(to: CGPoint(x: firstFrame.maxX, y: .zero))
            outlinesPath.addLine(to: CGPoint(x: firstFrame.maxX, y: keyWindow.bounds.maxY))
            
            outlinesPath.move(to: CGPoint(x: .zero, y: secondFrame.minY))
            outlinesPath.addLine(to: CGPoint(x: keyWindow.bounds.maxX, y: secondFrame.minY))
            outlinesPath.move(to: CGPoint(x: .zero, y: secondFrame.maxY))
            outlinesPath.addLine(to: CGPoint(x: keyWindow.bounds.maxX, y: secondFrame.maxY))
            outlinesPath.move(to: CGPoint(x: secondFrame.minX, y: .zero))
            outlinesPath.addLine(to: CGPoint(x: secondFrame.minX, y: keyWindow.bounds.maxY))
            outlinesPath.move(to: CGPoint(x: secondFrame.maxX, y: .zero))
            outlinesPath.addLine(to: CGPoint(x: secondFrame.maxX, y: keyWindow.bounds.maxY))
            
            UIView._outlinesLayer = CAShapeLayer()
            UIView._outlinesLayer?.path = outlinesPath.cgPath
            UIView._outlinesLayer?.strokeColor = UIColor.systemBlue.cgColor
            UIView._outlinesLayer?.lineWidth = 1
            UIView._outlinesLayer?.fillColor = nil
            UIView._outlinesLayer?.lineDashPattern = [4, 4]
            
            keyWindow.layer.addSublayer(UIView._outlinesLayer!)
            
            if let horizontalDistance, let minX, let maxX {
                let horizontalDistanceLabel = UILabel()
                horizontalDistanceLabel.text = Int(abs(horizontalDistance)).description
                horizontalDistanceLabel.font = .systemFont(ofSize: 10, weight: .medium)
                horizontalDistanceLabel.textAlignment = .center
                horizontalDistanceLabel.sizeToFit()
                horizontalDistanceLabel.frame = horizontalDistanceLabel.frame.insetBy(dx: -4, dy: -4)
                horizontalDistanceLabel.center = CGPoint(x: (minX + maxX) / 2, y: firstFrame.midY)
                horizontalDistanceLabel.backgroundColor = .systemBackground
                horizontalDistanceLabel.textColor = .systemBlue
                horizontalDistanceLabel.layer.masksToBounds = true
                horizontalDistanceLabel.layer.cornerRadius = 8
                horizontalDistanceLabel.layer.borderWidth = 2
                horizontalDistanceLabel.layer.borderColor = UIColor.systemBlue.cgColor
                UIView._horizontalDistanceLabel = horizontalDistanceLabel
                keyWindow.addSubview(horizontalDistanceLabel)
            }
            
            if let verticalDistance, let minY, let maxY {
                let verticalDistanceLabel = UILabel()
                verticalDistanceLabel.text = Int(abs(verticalDistance)).description
                verticalDistanceLabel.font = .systemFont(ofSize: 10, weight: .medium)
                verticalDistanceLabel.textAlignment = .center
                verticalDistanceLabel.sizeToFit()
                verticalDistanceLabel.frame = verticalDistanceLabel.frame.insetBy(dx: -4, dy: -4)
                verticalDistanceLabel.center = CGPoint(x: firstFrame.midX, y: (minY + maxY) / 2)
                verticalDistanceLabel.backgroundColor = .systemBackground
                verticalDistanceLabel.textColor = .systemBlue
                verticalDistanceLabel.layer.masksToBounds = true
                verticalDistanceLabel.layer.cornerRadius = 8
                verticalDistanceLabel.layer.borderWidth = 2
                verticalDistanceLabel.layer.borderColor = UIColor.systemBlue.cgColor
                UIView._verticalDistanceLabel = verticalDistanceLabel
                keyWindow.addSubview(verticalDistanceLabel)
            }
        }
    }
    
    private func resetDrawnLayoutConstraints() {
        UIView._distanceLayer?.removeFromSuperlayer()
        UIView._distanceLayer = nil
        UIView._outlinesLayer?.removeFromSuperlayer()
        UIView._outlinesLayer = nil
        UIView._horizontalDistanceLabel?.removeFromSuperview()
        UIView._horizontalDistanceLabel = nil
        UIView._verticalDistanceLabel?.removeFromSuperview()
        UIView._verticalDistanceLabel = nil
    }
    
    private func resetLayoutInspectorViews() {
        UIView._layoutInspectorFirstView = nil
        UIView._layoutInspectorSecondView = nil
    }
    
    private func getIsAllowedViewType() -> Bool {
        let isDebuggableView = window?.isDebuggableWindow ?? false
        let className = String(describing: type(of: self))
        let isAllowedViewType =
            self is UIVisualEffectView == false &&
            className.contains("_UIContextMenu") == false
        
        return isDebuggableView && isAllowedViewType
    }
}
