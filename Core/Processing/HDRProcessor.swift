import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins

final class HDRProcessor {
    enum HDRMode: String, CaseIterable {
        case natural = "Natural"
        case smartHDR = "Smart HDR"
        case hdrMax = "HDR Max"
    }
    
    private let context = CIContext(options: [.useSoftwareRenderer: false])
    
    func processHDR(images: [CIImage], mode: HDRMode) async -> CIImage {
        guard !images.isEmpty else { return CIImage() }
        
        if images.count == 1 {
            return applyToneMapping(to: images[0], mode: mode)
        }
        
        // For multiple images, we would align and merge them.
        // Simplified approach for demonstration: average them then apply tone mapping.
        let merged = blendImages(images)
        return applyToneMapping(to: merged, mode: mode)
    }
    
    private func applyToneMapping(to image: CIImage, mode: HDRMode) -> CIImage {
        let highlightShadow = CIFilter.highlightShadowAdjust()
        highlightShadow.inputImage = image
        
        let noiseReduction = CIFilter.noiseReduction()
        
        switch mode {
        case .natural:
            highlightShadow.highlightAmount = 0.8
            highlightShadow.shadowAmount = 0.2
            noiseReduction.noiseLevel = 0.02
        case .smartHDR:
            highlightShadow.highlightAmount = 0.6
            highlightShadow.shadowAmount = 0.6
            noiseReduction.noiseLevel = 0.04
        case .hdrMax:
            highlightShadow.highlightAmount = 0.3
            highlightShadow.shadowAmount = 0.9
            noiseReduction.noiseLevel = 0.06
        }
        
        var result = highlightShadow.outputImage ?? image
        
        noiseReduction.inputImage = result
        noiseReduction.sharpness = 0.8
        result = noiseReduction.outputImage ?? result
        
        // Skin tone protection could involve a color cube or custom CIColorKernel.
        // For simplicity, we apply a gentle color controls to preserve vibrancy.
        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = result
        colorControls.saturation = 1.1
        colorControls.contrast = 1.05
        
        return colorControls.outputImage ?? result
    }
    
    private func blendImages(_ images: [CIImage]) -> CIImage {
        var base = images[0]
        for i in 1..<images.count {
            let blend = CIFilter.additionCompositing()
            blend.inputImage = images[i]
            blend.backgroundImage = base
            if let out = blend.outputImage {
                base = out
            }
        }
        return base
    }
}
