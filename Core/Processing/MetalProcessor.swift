import Foundation
import CoreImage
import Metal
import CoreImage.CIFilterBuiltins

public final class MetalProcessor {
    public static let shared = MetalProcessor()
    
    public let device: MTLDevice
    public let commandQueue: MTLCommandQueue
    public let context: CIContext
    
    private var vignetteKernel: CIKernel?
    private var grainKernel: CIKernel?
    private var bloomKernel: CIColorKernel?
    private var focusPeakingKernel: CIColorKernel?
    private var clarityKernel: CIColorKernel?
    private var depthBlurKernel: CIColorKernel?
    
    private init() {
        guard let mtlDevice = MTLCreateSystemDefaultDevice(),
              let mtlQueue = mtlDevice.makeCommandQueue() else {
            fatalError("Metal not supported on this device")
        }
        self.device = mtlDevice
        self.commandQueue = mtlQueue
        self.context = CIContext(mtlDevice: device, options: [.cacheIntermediates: false])
        
        loadKernels()
    }
    
    private func loadKernels() {
        // In a real bundle, we'd load default.metallib.
        // Assuming LuminaShaders.metal is compiled into the main bundle's metallib.
        guard let url = Bundle.main.url(forResource: "default", withExtension: "metallib"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load default.metallib - Metal kernels may not work.")
            return
        }
        
        do {
            self.vignetteKernel = try CIKernel(functionName: "luminaVignette", fromMetalLibraryData: data)
            self.grainKernel = try CIKernel(functionName: "luminaGrain", fromMetalLibraryData: data)
            self.bloomKernel = try CIColorKernel(functionName: "luminaBloom", fromMetalLibraryData: data)
            self.focusPeakingKernel = try CIColorKernel(functionName: "luminaFocusPeaking", fromMetalLibraryData: data)
            self.clarityKernel = try CIColorKernel(functionName: "luminaClarity", fromMetalLibraryData: data)
            self.depthBlurKernel = try CIColorKernel(functionName: "luminaDepthBlur", fromMetalLibraryData: data)
        } catch {
            print("Error loading kernels: \(error)")
        }
    }
    
    public func applyVignette(to image: CIImage, intensity: Float, radius: Float) -> CIImage {
        guard let kernel = vignetteKernel else {
            // Fallback
            let filter = CIFilter.vignette()
            filter.inputImage = image
            filter.intensity = intensity
            filter.radius = radius
            return filter.outputImage ?? image
        }
        
        let roiCallback: CIKernelROICallback = { _, rect in return rect }
        return kernel.apply(extent: image.extent,
                            roiCallback: roiCallback,
                            arguments: [image, intensity, radius]) ?? image
    }
    
    public func applyGrain(to image: CIImage, amount: Float, size: Float) -> CIImage {
        guard let kernel = grainKernel else {
            // Fallback using CIRandomGenerator
            let noise = CIFilter.randomGenerator().outputImage?.cropped(to: image.extent)
            let colorMatrix = CIFilter.colorMatrix()
            colorMatrix.inputImage = noise
            colorMatrix.rVector = CIVector(x: 0, y: 0, z: 0, w: 0)
            colorMatrix.gVector = CIVector(x: 0, y: 0, z: 0, w: 0)
            colorMatrix.bVector = CIVector(x: 0, y: 0, z: 0, w: 0)
            colorMatrix.aVector = CIVector(x: 0, y: 0, z: 0, w: CGFloat(amount * 0.1))
            
            let composite = CIFilter.sourceOverCompositing()
            composite.inputImage = colorMatrix.outputImage
            composite.backgroundImage = image
            return composite.outputImage ?? image
        }
        
        let roiCallback: CIKernelROICallback = { _, rect in return rect }
        return kernel.apply(extent: image.extent,
                            roiCallback: roiCallback,
                            arguments: [image, amount, size]) ?? image
    }
    
    public func applyBloom(to image: CIImage, intensity: Float, radius: Float) -> CIImage {
        guard let kernel = bloomKernel else {
            let filter = CIFilter.bloom()
            filter.inputImage = image
            filter.intensity = intensity
            filter.radius = radius
            return filter.outputImage ?? image
        }
        
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = image
        blur.radius = radius
        guard let blurred = blur.outputImage?.cropped(to: image.extent) else { return image }
        
        return kernel.apply(extent: image.extent, arguments: [image, blurred, intensity]) ?? image
    }
    
    public func applyFocusPeaking(to image: CIImage) -> CIImage {
        guard let kernel = focusPeakingKernel else { return image }
        
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = image
        blur.radius = 2.0
        guard let blurred = blur.outputImage?.cropped(to: image.extent) else { return image }
        
        let threshold: Float = 0.15
        return kernel.apply(extent: image.extent, arguments: [image, blurred, threshold]) ?? image
    }
    
    public func applyClarity(to image: CIImage, amount: Float) -> CIImage {
        guard let kernel = clarityKernel else {
            let filter = CIFilter.unsharpMask()
            filter.inputImage = image
            filter.intensity = amount
            filter.radius = 2.5
            return filter.outputImage ?? image
        }
        
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = image
        blur.radius = 5.0
        guard let blurred = blur.outputImage?.cropped(to: image.extent) else { return image }
        
        return kernel.apply(extent: image.extent, arguments: [image, blurred, amount]) ?? image
    }
    
    public func applyDepthBlur(image: CIImage, mask: CIImage, maxRadius: Float) -> CIImage {
        guard let kernel = depthBlurKernel else { return image }
        
        let blur = CIFilter.gaussianBlur()
        blur.inputImage = image
        blur.radius = maxRadius
        guard let blurred = blur.outputImage?.cropped(to: image.extent) else { return image }
        
        return kernel.apply(extent: image.extent, arguments: [image, blurred, mask, maxRadius]) ?? image
    }
}
