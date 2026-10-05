import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreMedia
import UIKit

public final class FilterEngine {
    public static let shared = FilterEngine()
    
    public let ciContext: CIContext
    
    private init() {
        if let device = MTLCreateSystemDefaultDevice() {
            self.ciContext = CIContext(mtlDevice: device, options: [.cacheIntermediates: false, .name: "LuminaFilterContext"])
        } else {
            self.ciContext = CIContext(options: [.cacheIntermediates: false])
        }
    }
    
    public func apply(_ filter: FilterPreset, to image: CIImage, intensity: Float = 1.0) -> CIImage {
        guard intensity > 0 else { return image }
        
        var outputImage = image
        let p = filter.parameters
        
        // 1. Exposure
        if p.exposure != 0 {
            let exposureFilter = CIFilter.exposureAdjust()
            exposureFilter.inputImage = outputImage
            exposureFilter.ev = p.exposure * intensity
            outputImage = exposureFilter.outputImage ?? outputImage
        }
        
        // 2. Color Controls (Brightness, Contrast, Saturation)
        if p.brightness != 0 || p.contrast != 1.0 || p.saturation != 1.0 {
            let colorControls = CIFilter.colorControls()
            colorControls.inputImage = outputImage
            colorControls.brightness = p.brightness * intensity
            colorControls.contrast = 1.0 + (p.contrast - 1.0) * intensity
            colorControls.saturation = 1.0 + (p.saturation - 1.0) * intensity
            outputImage = colorControls.outputImage ?? outputImage
        }
        
        // 3. Temperature and Tint
        if p.warmth != 0 || p.tint != 0 {
            let tempTint = CIFilter.temperatureAndTint()
            tempTint.inputImage = outputImage
            let neutral = CIVector(x: 6500, y: 0)
            let target = CIVector(x: 6500 + CGFloat(p.warmth * 3000 * intensity), y: CGFloat(p.tint * 100 * intensity))
            tempTint.neutral = neutral
            tempTint.targetNeutral = target
            outputImage = tempTint.outputImage ?? outputImage
        }
        
        // 4. Highlights and Shadows
        if p.highlights != 0 || p.shadows != 0 {
            let highlightShadow = CIFilter.highlightShadowAdjust()
            highlightShadow.inputImage = outputImage
            highlightShadow.highlightAmount = 1.0 + p.highlights * intensity
            highlightShadow.shadowAmount = p.shadows * intensity
            outputImage = highlightShadow.outputImage ?? outputImage
        }
        
        // 5. Bloom
        if p.bloom > 0 {
            outputImage = MetalProcessor.shared.applyBloom(to: outputImage, intensity: p.bloom * intensity, radius: 10.0)
        }
        
        // 6. Sharpen / Clarity
        if p.sharpness > 0 {
            let sharpen = CIFilter.sharpenLuminance()
            sharpen.inputImage = outputImage
            sharpen.sharpness = p.sharpness * intensity
            outputImage = sharpen.outputImage ?? outputImage
        }
        if p.clarity > 0 {
            outputImage = MetalProcessor.shared.applyClarity(to: outputImage, amount: p.clarity * intensity)
        }
        
        // 7. Fade (Lift Blacks via Color Clamp)
        if p.fade > 0 {
            let clamp = CIFilter.colorClamp()
            clamp.inputImage = outputImage
            let lift = CGFloat(p.fade * intensity * 0.2)
            clamp.minComponents = CIVector(x: lift, y: lift, z: lift, w: 0.0)
            clamp.maxComponents = CIVector(x: 1.0, y: 1.0, z: 1.0, w: 1.0)
            outputImage = clamp.outputImage ?? outputImage
        }
        
        // 8. Grain
        if p.grain > 0 {
            outputImage = MetalProcessor.shared.applyGrain(to: outputImage, amount: p.grain * intensity, size: 1.5)
        }
        
        // 9. Vignette
        if p.vignette > 0 {
            outputImage = MetalProcessor.shared.applyVignette(to: outputImage, intensity: p.vignette * intensity, radius: 1.5)
        }
        
        return outputImage
    }
    
    public func apply(_ filter: FilterPreset, to sampleBuffer: CMSampleBuffer, intensity: Float = 1.0) -> CIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        return apply(filter, to: image, intensity: intensity)
    }
    
    public func createThumbnail(for filter: FilterPreset, from image: UIImage, size: CGSize) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        
        // Scale down for thumbnail
        let scaleX = size.width / image.size.width
        let scaleY = size.height / image.size.height
        let scale = min(scaleX, scaleY)
        
        let scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        let filtered = apply(filter, to: scaledImage)
        
        guard let cgResult = ciContext.createCGImage(filtered, from: filtered.extent) else { return nil }
        return UIImage(cgImage: cgResult)
    }
    
    public func blendFilter(original: CIImage, filtered: CIImage, intensity: Float) -> CIImage {
        if intensity >= 1.0 { return filtered }
        if intensity <= 0.0 { return original }
        
        let blendFilter = CIFilter.blendWithAlphaMask()
        blendFilter.inputImage = filtered
        blendFilter.backgroundImage = original
        
        // Create solid color image for alpha mask
        let alpha = CIColor(red: CGFloat(intensity), green: CGFloat(intensity), blue: CGFloat(intensity), alpha: 1.0)
        let mask = CIImage(color: alpha).cropped(to: original.extent)
        blendFilter.maskImage = mask
        
        return blendFilter.outputImage ?? original
    }
}
