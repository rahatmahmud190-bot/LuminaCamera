import CoreImage
import UIKit
import SwiftUI

extension CIImage {
    func toUIImage(context: CIContext = CIContext()) -> UIImage? {
        if let cgImage = context.createCGImage(self, from: self.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    func cropped(to normalizedRect: CGRect) -> CIImage {
        let x = normalizedRect.origin.x * extent.width
        let y = normalizedRect.origin.y * extent.height
        let w = normalizedRect.width * extent.width
        let h = normalizedRect.height * extent.height
        let rect = CGRect(x: x, y: y, width: w, height: h)
        return self.cropped(to: rect)
    }
    
    func resized(to size: CGSize) -> CIImage {
        let scaleX = size.width / extent.width
        let scaleY = size.height / extent.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        return self.transformed(by: transform)
    }
    
    var averageLuminance: CGFloat {
        let extent = self.extent
        let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: self, kCIInputExtentKey: CIVector(cgRect: extent)])
        guard let outputImage = filter?.outputImage else { return 0.5 }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        let r = CGFloat(bitmap[0]) / 255.0
        let g = CGFloat(bitmap[1]) / 255.0
        let b = CGFloat(bitmap[2]) / 255.0
        
        return (r * 0.299 + g * 0.587 + b * 0.114)
    }
    
    var histogram: (red: [Float], green: [Float], blue: [Float]) {
        // Dummy implementation for compilation
        return (red: [], green: [], blue: [])
    }
}

extension UIImage {
    func toCIImage() -> CIImage? {
        if let ciImage = self.ciImage {
            return ciImage
        }
        if let cgImage = self.cgImage {
            return CIImage(cgImage: cgImage)
        }
        return nil
    }
    
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }
    
    func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func jpegData(quality: Float) -> Data? {
        return self.jpegData(compressionQuality: CGFloat(quality))
    }
    
    var hasAlpha: Bool {
        guard let alphaInfo = self.cgImage?.alphaInfo else { return false }
        return alphaInfo != .none && alphaInfo != .noneSkipFirst && alphaInfo != .noneSkipLast
    }
}

extension Color {
    static let glassWhite = Color.white.opacity(0.15)
    static let glassBorder = Color.white.opacity(0.2)
    static let glassHighlight = Color.white.opacity(0.08)
    static let luminaAccent = Color(red: 1, green: 0.84, blue: 0.4) // warm gold
    static let nightModeBlue = Color(red: 0.4, green: 0.7, blue: 1.0)
}
