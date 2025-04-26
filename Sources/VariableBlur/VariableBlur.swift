//
//  VariableBlur.swift
//  VariableBlur
//
//  Created by Phil Zakharchenko on 4/26/25.
//

import SwiftUI

/// A view that applies a variable blur effect based on a mask.
public struct VariableBlur: View {
    /// Defines the gradient style used for the blur mask.
    public enum GradientStyle {
        /// Linear gradient with sharp transition.
        case linear
        
        /// Smooth linear gradient with eased transition.
        case smoothLinear
    }
    
    enum Constants {
        static let groupName = "variableBlur"
        static let setGroupNameSelector = "setGroupName:"
        static let setScaleSelector = "setScale:"
        static let backdropLayerClassName = "CABackdropLayer"
    }
    
    // MARK: - Properties
    
    /// Maximum blur radius to apply.
    private let blurRadius: CGFloat
    
    // MARK: - Types
    
    /// Defines the type of mask used for controlling blur intensity.
    enum MaskType {
        /// SwiftUI view mask.
        case view(AnyView)
        
        /// `CGImage` mask.
        case image(CGImage)
        
        /// Gradient mask generated from start/end points.
        case gradient(start: UnitPoint, end: UnitPoint, style: GradientStyle)
    }
    
    /// The mask controlling the blur gradient.
    private let maskType: MaskType
    
    // MARK: - Initialization
    
    /// Creates a variable blur with a SwiftUI view mask.
    /// - Parameters:
    ///   - blurRadius: Maximum blur radius to apply.
    ///   - mask: A SwiftUI view to use as the blur mask.
    public init<Content: View>(blurRadius: CGFloat = 20, @ViewBuilder mask: () -> Content) {
        self.blurRadius = blurRadius
        self.maskType = .view(AnyView(mask()))
    }
    
    /// Creates a variable blur with a CGImage mask.
    /// - Parameters:
    ///   - blurRadius: Maximum blur radius to apply.
    ///   - mask: A CGImage to use as the blur mask.
    public init(blurRadius: CGFloat = 20, mask: CGImage) {
        self.blurRadius = blurRadius
        self.maskType = .image(mask)
    }
    
    /// Creates a variable blur with a gradient mask.
    /// - Parameters:
    ///   - gradientType: Type of gradient transition.
    ///   - blurRadius: Maximum blur radius to apply.
    ///   - start: The start point in unit space (0,0 to 1,1).
    ///   - end: The end point in unit space (0,0 to 1,1).
    public init(
        _ gradientStyle: GradientStyle = .smoothLinear,
        blurRadius: CGFloat = 20,
        from start: UnitPoint = .top,
        to end: UnitPoint = .bottom
    ) {
        self.blurRadius = blurRadius
        self.maskType = .gradient(start: start, end: end, style: gradientStyle)
    }
    
    // MARK: - Body
    
    public var body: some View {
        PlatformVariableBlurViewRepresentable(
            blurRadius: blurRadius,
            maskType: maskType
        )
    }
}
