//
//  VariableBlurViewRepresentable+UIKit.swift
//  VariableBlur
//
//  Created by Phil Zakharchenko on 4/26/25.
//

#if canImport(UIKit)

import SwiftUI

typealias PlatformVariableBlurViewRepresentable = UIKitVariableBlurViewRepresentable

/// UIKit implementation of the variable blur view representable.
struct UIKitVariableBlurViewRepresentable: UIViewRepresentable {
    let blurRadius: CGFloat
    let maskType: VariableBlur.MaskType
    
    func makeUIView(context: Context) -> BlurPlatformView {
        BlurPlatformView(
            blurRadius: blurRadius,
            maskType: maskType
        )
    }
    
    func updateUIView(_ uiView: BlurPlatformView, context: Context) {
        uiView.update(blurRadius: blurRadius, maskType: maskType)
    }
}

/// iOS-specific implementation of the variable blur effect.
final class BlurPlatformView: UIView {
    private enum Constants {
        static let windowServerAwareSelector = "setWindowServerAware:"
    }
    
    private var maskType: VariableBlur.MaskType
    private var blurRadius: CGFloat
    private var needsLayerConfiguration = true
    
    init(blurRadius: CGFloat, maskType: VariableBlur.MaskType) {
        self.blurRadius = blurRadius
        self.maskType = maskType
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var layerClass: AnyClass {
        NSClassFromString(VariableBlur.Constants.backdropLayerClassName) ?? CALayer.self
    }
    
    func update(blurRadius: CGFloat, maskType: VariableBlur.MaskType) {
        self.blurRadius = blurRadius
        self.maskType = maskType
        needsLayerConfiguration = true
        configureVariableBlurIfNeeded()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        configureBaseLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureVariableBlurIfNeeded()
    }
    
    private func configureBaseLayer() {
        layer.perform(Selector(VariableBlur.Constants.setGroupNameSelector), with: VariableBlur.Constants.groupName)
        layer.perform(Selector(VariableBlur.Constants.setScaleSelector), with: window?.contentScaleFactor ?? 1)
    }
    
    private func configureVariableBlurIfNeeded() {
        guard bounds.size != .zero, needsLayerConfiguration else { return }
        needsLayerConfiguration = false
        
        // Generate a mask image.
        let maskImage = BlurMaskBuilder.generateMaskImage(maskType: maskType, size: bounds.size)
        
        // Configure the filter
        guard let variableBlur = BlurMaskBuilder.configureVariableBlurFilter(
            blurRadius: blurRadius,
            maskImage: maskImage
        ) else { return }
        
        // Apply the filter directly to the layer.
        layer.filters = [variableBlur]
    }
}

#endif
