//
//  VariableBlurLayerView.swift
//  VariableBlur
//
//  Created by Phil Zakharchenko on 6/16/26.
//

import QuartzCore
import SwiftUI

struct VariableBlurLayerView: View {
    let blurRadius: CGFloat
    let maskType: VariableBlur.MaskType
    
    @Environment(\.displayScale) private var displayScale
    
    var body: some View {
        _CALayerView(type: VariableBlurLayer.self) { layer in
            layer.update(
                blurRadius: blurRadius,
                maskType: maskType,
                displayScale: displayScale
            )
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private final class VariableBlurLayer: CALayer {
    private let backdropLayer: CALayer?
    private var maskType: VariableBlur.MaskType?
    private var blurRadius: CGFloat = 0
    private var displayScale: CGFloat = 1
    private var needsFilterUpdate = true
    
    override init() {
        self.backdropLayer = VariableBlurRuntime.makeBackdropLayer()
        super.init()
        configure()
    }
    
    override init(layer: Any) {
        if let layer = layer as? VariableBlurLayer {
            self.backdropLayer = VariableBlurRuntime.makeBackdropLayer()
            self.maskType = layer.maskType
            self.blurRadius = layer.blurRadius
            self.displayScale = layer.displayScale
            self.needsFilterUpdate = layer.needsFilterUpdate
        } else {
            self.backdropLayer = VariableBlurRuntime.makeBackdropLayer()
        }
        
        super.init(layer: layer)
        configure()
    }
    
    required init?(coder: NSCoder) {
        self.backdropLayer = VariableBlurRuntime.makeBackdropLayer()
        super.init(coder: coder)
        configure()
    }
    
    override class func defaultAction(forKey event: String) -> CAAction? {
        NSNull()
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        if backdropLayer?.frame != bounds {
            backdropLayer?.frame = bounds
            needsFilterUpdate = true
        }
        
        configureFilterIfNeeded()
    }
    
    func update(blurRadius: CGFloat, maskType: VariableBlur.MaskType, displayScale: CGFloat) {
        self.blurRadius = blurRadius
        self.maskType = maskType
        self.displayScale = max(displayScale, 1)
        self.needsFilterUpdate = true
        self.contentsScale = self.displayScale
        self.backdropLayer?.contentsScale = self.displayScale
        
        VariableBlurRuntime.configureBackdropLayer(
            backdropLayer,
            groupName: VariableBlur.Constants.groupName,
            scale: self.displayScale
        )
        configureFilterIfNeeded()
    }
    
    private func configure() {
        masksToBounds = true
        contentsGravity = .resize
        
        guard let backdropLayer else { return }
        backdropLayer.frame = bounds
        addSublayer(backdropLayer)
    }
    
    private func configureFilterIfNeeded() {
        guard needsFilterUpdate,
              !bounds.isEmpty,
              let maskType,
              let backdropLayer else { return }
        
        needsFilterUpdate = false
        
        nonisolated(unsafe) let currentMaskType = maskType
        let currentSize = bounds.size
        let currentScale = displayScale
        
        let maskImage = MainActor.assumeIsolated {
            BlurMaskBuilder.generateMaskImage(
                maskType: currentMaskType,
                size: currentSize,
                scale: currentScale
            )
        }
        guard let variableBlur = BlurMaskBuilder.configureVariableBlurFilter(
            blurRadius: blurRadius,
            maskImage: maskImage
        ) else { return }
        
        backdropLayer.filters = [variableBlur]
    }
}

enum VariableBlurRuntime {
    private enum Constants {
        static let backdropLayerClassName = "CABackdropLayer"
        static let filterClassName = "CAFilter"
        static let filterFactorySelector = "filterWithName:"
        static let groupNameKey = "groupName"
        static let scaleKey = "scale"
        static let allowsInPlaceFilteringKey = "allowsInPlaceFiltering"
        static let windowServerAwareKey = "windowServerAware"
    }
    
    static func makeBackdropLayer() -> CALayer? {
        guard let layerClass = NSClassFromString(Constants.backdropLayerClassName) as? CALayer.Type else {
            return nil
        }
        
        let layer = layerClass.init()
        layer.setValue(false, forKey: Constants.allowsInPlaceFilteringKey)
        #if canImport(AppKit)
        layer.setValue(false, forKey: Constants.windowServerAwareKey)
        #endif
        return layer
    }
    
    static func configureBackdropLayer(_ layer: CALayer?, groupName: String, scale: CGFloat) {
        guard let layer else { return }
        let effectiveScale = scale > 0 ? scale : 1
        layer.setValue(groupName, forKey: Constants.groupNameKey)
        layer.setValue(NSNumber(value: Double(effectiveScale)), forKey: Constants.scaleKey)
    }
    
    static func makeFilter(named name: String) -> NSObject? {
        guard let filterClass = NSClassFromString(Constants.filterClassName) as? NSObject.Type else {
            return nil
        }
        
        let selector = NSSelectorFromString(Constants.filterFactorySelector)
        guard filterClass.responds(to: selector) else { return nil }
        
        return filterClass
            .perform(selector, with: name)?
            .takeUnretainedValue() as? NSObject
    }
}
