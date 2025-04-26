//
//  VariableBlurViewRepresentable+AppKit.swift
//  VariableBlur
//
//  Created by Phil Zakharchenko on 4/26/25.
//

#if canImport(AppKit)

import SwiftUI

typealias PlatformVariableBlurViewRepresentable = AppKitVariableBlurViewRepresentable

/// AppKit implementation of the variable blur view representable.
struct AppKitVariableBlurViewRepresentable: NSViewRepresentable {
    let blurRadius: CGFloat
    let maskType: VariableBlur.MaskType
    
    func makeNSView(context: Context) -> BlurPlatformView {
        BlurPlatformView(
            blurRadius: blurRadius,
            maskType: maskType
        )
    }
    
    func updateNSView(_ nsView: BlurPlatformView, context: Context) {
        nsView.update(blurRadius: blurRadius, maskType: maskType)
    }
}

/// macOS-specific implementation of the variable blur effect.
final class BlurPlatformView: NSView {
    private enum Constants {
        static let windowServerAwareSelector = "setWindowServerAware:"
        static let groupName = "variableView"
    }
    
    private var maskType: VariableBlur.MaskType
    private var blurRadius: CGFloat
    private var needsLayerConfiguration = true
    
    init(blurRadius: CGFloat, maskType: VariableBlur.MaskType) {
        self.blurRadius = blurRadius
        self.maskType = maskType
        
        super.init(frame: .zero)
        
        // To set a hosted layer, we want to set `wantsLayer` after setting `layer` to the instance we'd like to host.
        layer = Self.layer()
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        configureVariableBlurIfNeeded()
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        configureBaseLayer()
    }
    
    func update(blurRadius: CGFloat, maskType: VariableBlur.MaskType) {
        self.blurRadius = blurRadius
        self.maskType = maskType
        self.needsLayerConfiguration = true
        configureVariableBlurIfNeeded()
    }
    
    private func configureBaseLayer() {
        guard let layer else { return }
        layer.perform(Selector(VariableBlur.Constants.setGroupNameSelector), with: Constants.groupName)
        layer.perform(Selector(Constants.windowServerAwareSelector), with: false)
        layer.perform(Selector(VariableBlur.Constants.setScaleSelector), with: window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 1)
    }
    
    private func configureVariableBlurIfNeeded() {
        guard !bounds.isEmpty, let layer, needsLayerConfiguration else { return }
        needsLayerConfiguration = false
        
        // Generate a mask image.
        let maskImage = BlurMaskBuilder.generateMaskImage(maskType: maskType, size: bounds.size)
        
        // Configure the filter.
        guard let variableBlur = BlurMaskBuilder.configureVariableBlurFilter(
            blurRadius: blurRadius,
            maskImage: maskImage
        ) else { return }
        
        // Apply the filter to the layer.
        layer.filters = [variableBlur]
    }
    
    private static func layer() -> CALayer? {
        guard let layerClass = NSClassFromString(VariableBlur.Constants.backdropLayerClassName) as? CALayer.Type else { return nil }
        return layerClass.perform(#selector(getter: NSView.layer)).takeUnretainedValue() as? CALayer
    }
}

#endif
