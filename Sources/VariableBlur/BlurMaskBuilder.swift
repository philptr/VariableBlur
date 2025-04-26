//
//  BlurMaskBuilder.swift
//  VariableBlur
//
//  Created by Phil Zakharchenko on 4/26/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import QuartzCore

/// Factory for creating and configuring blur masks and filters.
enum BlurMaskBuilder {
    private enum Constants {
        static let filterTypeName = "variableBlur"
        static let inputRadiusKey = "inputRadius"
        static let inputMaskImageKey = "inputMaskImage"
        static let inputNormalizeEdgesKey = "inputNormalizeEdges"
        static let filterTypeSelector = "filterWithType:"
    }
    
    /// Creates a gradient image to be used as a mask for the variable blur.
    /// - Parameters:
    ///   - size: The size of the gradient image.
    ///   - startPoint: Starting point in unit space.
    ///   - endPoint: Ending point in unit space.
    ///   - gradientStyle: The style of built-in gradient transition.
    /// - Returns: A gradient image or nil if creation failed.
    static func makeGradientImage(
        size: CGSize,
        startPoint: UnitPoint,
        endPoint: UnitPoint,
        gradientStyle: VariableBlur.GradientStyle
    ) -> CGImage? {
        // Convert UnitPoint to CGPoint based on size.
        let point0 = CGPoint(
            x: startPoint.x * size.width,
            y: (1 - startPoint.y) * size.height
        )
        
        let point1 = CGPoint(
            x: endPoint.x * size.width,
            y: (1 - endPoint.y) * size.height
        )
        
        // Choose the appropriate gradient filter.
        let ciGradientFilter: CIFilter
        switch gradientStyle {
        case .linear:
            let filter = CIFilter.linearGradient()
            filter.color0 = CIColor.black
            filter.color1 = CIColor.clear
            filter.point0 = point0
            filter.point1 = point1
            ciGradientFilter = filter
        case .smoothLinear:
            let filter = CIFilter.smoothLinearGradient()
            filter.color0 = CIColor.black
            filter.color1 = CIColor.clear
            filter.point0 = point0
            filter.point1 = point1
            ciGradientFilter = filter
        }
        
        guard let outputImage = ciGradientFilter.outputImage else { return nil }
        return CIContext().createCGImage(
            outputImage,
            from: CGRect(origin: .zero, size: size)
        )
    }
    
    /// Generates a mask image based on the mask type.
    /// - Parameters:
    ///   - maskType: The type of mask to generate.
    ///   - size: The desired size of the mask.
    /// - Returns: A mask image or nil if generation failed.
    @MainActor
    static func generateMaskImage(maskType: VariableBlur.MaskType, size: CGSize) -> CGImage? {
        switch maskType {
        case .view(let view):
            let renderer = ImageRenderer(content: view)
            renderer.proposedSize = ProposedViewSize(size)
            return renderer.cgImage
        case .image(let image):
            return image
        case .gradient(let start, let end, let style):
            return makeGradientImage(
                size: size,
                startPoint: start,
                endPoint: end,
                gradientStyle: style
            )
        }
    }
    
    /// Configures a variable blur filter with the specified parameters.
    /// - Parameters:
    ///   - blurRadius: The maximum blur radius to apply.
    ///   - maskImage: The mask image controlling blur intensity.
    /// - Returns: A configured filter object or nil if configuration failed.
    static func configureVariableBlurFilter(blurRadius: CGFloat, maskImage: CGImage?) -> NSObject? {
        guard let CAFilter = NSClassFromString("CAFilter") as? NSObject.Type,
              let variableBlur = CAFilter.perform(
                NSSelectorFromString(Constants.filterTypeSelector),
                with: Constants.filterTypeName
              )?.takeUnretainedValue() as? NSObject,
              let maskImage = maskImage else {
            return nil
        }
        
        // Configure the filter.
        variableBlur.setValue(blurRadius, forKey: Constants.inputRadiusKey)
        variableBlur.setValue(maskImage, forKey: Constants.inputMaskImageKey)
        variableBlur.setValue(true, forKey: Constants.inputNormalizeEdgesKey)
        
        return variableBlur
    }
}
