import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import Vision
import AVFoundation

@MainActor
final class SegmentationEngine: ObservableObject {
    @Published var segmentationMask: CIImage?
    
    private let context = CIContext(options: [.useSoftwareRenderer: false])
    
    enum Quality {
        case accurate
        case balanced
        case fast
    }
    
    enum SubjectType {
        case person
        case face
        case pet
    }
    
    func generateMask(from pixelBuffer: CVPixelBuffer, quality: Quality = .balanced) async throws -> CIImage {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNGeneratePersonSegmentationRequest()
            
            switch quality {
            case .accurate:
                request.qualityLevel = .accurate
            case .balanced:
                request.qualityLevel = .balanced
            case .fast:
                request.qualityLevel = .fast
            }
            
            request.outputPixelFormat = kCVPixelFormatType_OneComponent8
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([request])
                if let result = request.results?.first,
                   let maskPixelBuffer = result.pixelBuffer {
                    let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
                    continuation.resume(returning: maskImage)
                } else {
                    continuation.resume(throwing: NSError(domain: "SegmentationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No segmentation found"]))
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func generateMaskFromImage(_ ciImage: CIImage, quality: Quality = .balanced) async throws -> CIImage {
        return try await withCheckedThrowingContinuation { continuation in
            let request = VNGeneratePersonSegmentationRequest()
            
            switch quality {
            case .accurate:
                request.qualityLevel = .accurate
            case .balanced:
                request.qualityLevel = .balanced
            case .fast:
                request.qualityLevel = .fast
            }
            
            request.outputPixelFormat = kCVPixelFormatType_OneComponent8
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            do {
                try handler.perform([request])
                if let result = request.results?.first,
                   let maskPixelBuffer = result.pixelBuffer {
                    let maskImage = CIImage(cvPixelBuffer: maskPixelBuffer)
                    // Scale mask to original image size
                    let scaleX = ciImage.extent.width / maskImage.extent.width
                    let scaleY = ciImage.extent.height / maskImage.extent.height
                    let scaledMask = maskImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
                    continuation.resume(returning: scaledMask)
                } else {
                    continuation.resume(throwing: NSError(domain: "SegmentationError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No segmentation found"]))
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func refineEdges(mask: CIImage, radius: CGFloat = 2.0) -> CIImage {
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = mask
        blurFilter.radius = Float(radius)
        return blurFilter.outputImage?.cropped(to: mask.extent) ?? mask
    }
    
    func applyPortraitBlur(original: CIImage, mask: CIImage, blurRadius: CGFloat, fStop: Float) -> CIImage {
        let refinedMask = refineEdges(mask: mask, radius: 2.0)
        
        let blurFilter = CIFilter.maskedVariableBlur()
        blurFilter.inputImage = original
        blurFilter.mask = refinedMask
        blurFilter.radius = Float(blurRadius)
        
        return blurFilter.outputImage?.cropped(to: original.extent) ?? original
    }
    
    func getBlurRadius(for fStop: Float) -> CGFloat {
        switch fStop {
        case ..<1.6: return 35.0
        case 1.6..<2.0: return 28.0
        case 2.0..<2.5: return 22.0
        case 2.5..<3.5: return 16.0
        case 3.5..<4.8: return 10.0
        case 4.8..<6.8: return 6.0
        default: return 3.0
        }
    }
}
