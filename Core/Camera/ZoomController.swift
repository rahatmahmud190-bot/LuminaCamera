import Foundation
import AVFoundation

public final class ZoomController {
    
    public init() {}
    
    public func setZoom(_ factor: CGFloat, on device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.unlockForConfiguration()
            HapticManager.shared.zoomChange()
        } catch {
            print("Error locking device for zoom: \(error)")
        }
    }
    
    public func animateZoom(to factor: CGFloat, on device: AVCaptureDevice, duration: TimeInterval) {
        do {
            try device.lockForConfiguration()
            let targetZoom = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            let rate = Float(abs(device.videoZoomFactor - targetZoom) / CGFloat(duration))
            device.ramp(toVideoZoomFactor: targetZoom, withRate: rate > 0 ? rate : 1.0)
            device.unlockForConfiguration()
        } catch {
            print("Error locking device for zoom animation: \(error)")
        }
    }
    
    public func zoomFactorForPreset(_ preset: ZoomPreset) -> CGFloat {
        return preset.rawValue
    }
}
