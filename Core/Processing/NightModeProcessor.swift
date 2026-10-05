import Foundation
import CoreImage
import CoreMedia
import AVFoundation

final class NightModeProcessor: ObservableObject {
    enum NightModeExposure: Int, CaseIterable {
        case auto = 0
        case one = 1
        case two = 2
        case three = 3
        case five = 5
    }
    
    @Published var isNightModeAvailable: Bool = false
    @Published var recommendedExposure: NightModeExposure = .auto
    @Published var captureProgress: CGFloat = 0.0
    
    func detectLowLight(from sampleBuffer: CMSampleBuffer) -> Bool {
        guard let metadataDict = CMCopyDictionaryOfAttachments(allocator: kCFAllocatorDefault, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate) as? [String: Any],
              let exifDict = metadataDict[kCGImagePropertyExifDictionary as String] as? [String: Any],
              let brightnessValue = exifDict[kCGImagePropertyExifBrightnessValue as String] as? Double else {
            return false
        }
        
        let isLowLight = brightnessValue < 0.0
        
        DispatchQueue.main.async {
            self.isNightModeAvailable = isLowLight
            if isLowLight {
                if brightnessValue < -3.0 {
                    self.recommendedExposure = .three
                } else if brightnessValue < -1.0 {
                    self.recommendedExposure = .one
                } else {
                    self.recommendedExposure = .auto
                }
            } else {
                self.recommendedExposure = .auto
            }
        }
        return isLowLight
    }
    
    func configureNightMode(exposure: NightModeExposure, on captureOutput: AVCapturePhotoOutput) -> AVCapturePhotoSettings {
        let settings = AVCapturePhotoSettings()
        if captureOutput.isAutoDeferredPhotoDeliverySupported {
            settings.isAutoDeferredPhotoDeliveryEnabled = true
        }
        return settings
    }
    
    func processNightCapture(images: [CIImage], exposureDuration: TimeInterval) async -> CIImage {
        guard !images.isEmpty else { return CIImage() }
        
        var baseImage = images.first!
        
        // Frame alignment and averaging
        for i in 1..<images.count {
            let overlay = images[i]
            // In a real app, motion detection and CIAffineTransform alignment occur here
            let blend = CIFilter.sourceOverCompositing() // Simple blend for demo
            blend.inputImage = overlay.applyingFilter("CIColorMatrix", parameters: ["inputAlpha": CIVector(x: 0, y: 0, z: 0, w: 1.0 / CGFloat(i + 1))])
            blend.backgroundImage = baseImage
            if let blended = blend.outputImage {
                baseImage = blended
            }
        }
        
        // Apply shadows and noise reduction
        let highlightShadow = CIFilter.highlightShadowAdjust()
        highlightShadow.inputImage = baseImage
        highlightShadow.shadowAmount = 0.6
        highlightShadow.highlightAmount = 0.9
        
        var result = highlightShadow.outputImage ?? baseImage
        
        let noiseReduction = CIFilter.noiseReduction()
        noiseReduction.inputImage = result
        noiseReduction.noiseLevel = 0.05
        noiseReduction.sharpness = 0.7
        
        result = noiseReduction.outputImage ?? result
        
        return result
    }
}
