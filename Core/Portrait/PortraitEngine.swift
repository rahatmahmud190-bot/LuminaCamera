import SwiftUI
import CoreImage
import Vision

struct PortraitResult {
    var originalImage: UIImage
    var portraitImage: UIImage
    var mask: CIImage
    var fStop: PortraitFStop
    var zoomFactor: CGFloat
}

@MainActor
final class PortraitEngine: ObservableObject {
    @Published var isProcessing: Bool = false
    @Published var currentFStop: PortraitFStop = .f18
    @Published var portraitImage: UIImage?
    @Published var originalImage: UIImage?
    @Published var depthMap: CIImage?
    
    private let segmentationEngine = SegmentationEngine()
    private let context = CIContext(options: [.useSoftwareRenderer: false])
    
    func processPortrait(from image: UIImage, zoom: CGFloat) async throws -> PortraitResult {
        isProcessing = true
        defer { isProcessing = false }
        
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "PortraitError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        
        // 1. Zoom crop
        let croppedImage = applyZoom(to: ciImage, factor: zoom)
        
        // 2. Generate mask
        let mask: CIImage
        do {
            mask = try await segmentationEngine.generateMaskFromImage(croppedImage, quality: .accurate)
            self.depthMap = mask
        } catch {
            print("Segmentation failed, returning original image: \(error)")
            let uiCropped = UIImage(ciImage: croppedImage)
            return PortraitResult(originalImage: image, portraitImage: uiCropped, mask: CIImage(color: .white).cropped(to: croppedImage.extent), fStop: currentFStop, zoomFactor: zoom)
        }
        
        // 3. Apply blur
        let radius = currentFStop.blurRadius
        let blurredImage = segmentationEngine.applyPortraitBlur(original: croppedImage, mask: mask, blurRadius: radius, fStop: currentFStop.rawValue)
        
        guard let outputCGImage = context.createCGImage(blurredImage, from: blurredImage.extent) else {
            throw NSError(domain: "PortraitError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Render failed"])
        }
        
        let finalUIImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
        let originalCroppedUIImage = UIImage(ciImage: croppedImage)
        
        self.portraitImage = finalUIImage
        self.originalImage = originalCroppedUIImage
        
        return PortraitResult(
            originalImage: originalCroppedUIImage,
            portraitImage: finalUIImage,
            mask: mask,
            fStop: currentFStop,
            zoomFactor: zoom
        )
    }
    
    func adjustDepth(fStop: PortraitFStop) async -> UIImage? {
        guard let original = originalImage,
              let cgOriginal = original.cgImage,
              let mask = depthMap else { return nil }
              
        isProcessing = true
        defer { isProcessing = false }
        
        self.currentFStop = fStop
        let ciOriginal = CIImage(cgImage: cgOriginal)
        
        let radius = fStop.blurRadius
        let blurredImage = segmentationEngine.applyPortraitBlur(original: ciOriginal, mask: mask, blurRadius: radius, fStop: fStop.rawValue)
        
        guard let outputCGImage = context.createCGImage(blurredImage, from: blurredImage.extent) else { return nil }
        
        let newImage = UIImage(cgImage: outputCGImage, scale: original.scale, orientation: original.imageOrientation)
        self.portraitImage = newImage
        return newImage
    }
    
    func changeFocusSubject(at point: CGPoint, in image: UIImage) async {
        // Tap to change focus implementation using Vision bounding boxes could be added here
        print("Focus changed to \(point)")
    }
    
    private func applyZoom(to image: CIImage, factor: CGFloat) -> CIImage {
        guard factor > 1.0 else { return image }
        let extent = image.extent
        let width = extent.width / factor
        let height = extent.height / factor
        let x = (extent.width - width) / 2.0
        let y = (extent.height - height) / 2.0
        let rect = CGRect(x: x, y: y, width: width, height: height)
        return image.cropped(to: rect).transformed(by: CGAffineTransform(translationX: -x, y: -y))
    }
}
