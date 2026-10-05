import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import AVFoundation
import UIKit

struct ProcessingSettings {
    var noiseReductionLevel: Float = 0.02
    var applyHDR: Bool = false
    var hdrMode: HDRProcessor.HDRMode = .natural
    var whiteBalanceTemp: Float? // e.g. 6500
    var sharpness: Float = 0.5
    var zoomFactor: CGFloat = 1.0
}

final class PhotoProcessor {
    private let context = CIContext(options: [.useSoftwareRenderer: false])
    private let hdrProcessor = HDRProcessor()
    
    func process(_ photo: AVCapturePhoto, settings: ProcessingSettings) async throws -> UIImage {
        guard let fileData = photo.fileDataRepresentation(),
              let ciImage = CIImage(data: fileData) else {
            throw NSError(domain: "PhotoProcessor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid photo data"])
        }
        
        var currentImage = ciImage
        
        // 1. Zoom
        currentImage = applyComputationalZoom(to: currentImage, factor: settings.zoomFactor)
        
        // 2. Noise Reduction
        currentImage = applyNoiseReduction(to: currentImage, amount: settings.noiseReductionLevel)
        
        // 3. HDR
        if settings.applyHDR {
            currentImage = await hdrProcessor.processHDR(images: [currentImage], mode: settings.hdrMode)
        }
        
        // 4. Tone Mapping
        currentImage = applyToneMapping(to: currentImage)
        
        // 5. Sharpening
        currentImage = applySharpening(to: currentImage, amount: settings.sharpness)
        
        guard let cgImage = context.createCGImage(currentImage, from: currentImage.extent) else {
            throw NSError(domain: "PhotoProcessor", code: 2, userInfo: [NSLocalizedDescriptionKey: "Render failed"])
        }
        
        // Orientation handling would be added based on device motion
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: .right)
    }
    
    func applyComputationalZoom(to image: CIImage, factor: CGFloat) -> CIImage {
        guard factor > 1.0 else { return image }
        let extent = image.extent
        let width = extent.width / factor
        let height = extent.height / factor
        let x = (extent.width - width) / 2.0
        let y = (extent.height - height) / 2.0
        let rect = CGRect(x: x, y: y, width: width, height: height)
        return image.cropped(to: rect).transformed(by: CGAffineTransform(translationX: -x, y: -y))
    }
    
    func applySharpening(to image: CIImage, amount: Float) -> CIImage {
        let unsharp = CIFilter.unsharpMask()
        unsharp.inputImage = image
        unsharp.intensity = amount
        unsharp.radius = 2.5
        return unsharp.outputImage ?? image
    }
    
    func applyNoiseReduction(to image: CIImage, amount: Float) -> CIImage {
        let nr = CIFilter.noiseReduction()
        nr.inputImage = image
        nr.noiseLevel = amount
        nr.sharpness = 1.0 - amount
        return nr.outputImage ?? image
    }
    
    func applyToneMapping(to image: CIImage) -> CIImage {
        let controls = CIFilter.colorControls()
        controls.inputImage = image
        controls.contrast = 1.05
        controls.saturation = 1.02
        return controls.outputImage ?? image
    }
}
