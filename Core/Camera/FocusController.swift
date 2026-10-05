import Foundation
import AVFoundation
import CoreMedia

public final class FocusController {
    
    public init() {}
    
    public func focus(at point: CGPoint, in previewLayer: AVCaptureVideoPreviewLayer, on device: AVCaptureDevice) {
        let cameraPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
        
        do {
            try device.lockForConfiguration()
            
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
                device.focusPointOfInterest = cameraPoint
                device.focusMode = .autoFocus
            }
            
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.autoExpose) {
                device.exposurePointOfInterest = cameraPoint
                device.exposureMode = .autoExpose
            }
            
            device.isSubjectAreaChangeMonitoringEnabled = true
            device.unlockForConfiguration()
            HapticManager.shared.lightImpact()
        } catch {
            print("Error locking device for focus: \(error)")
        }
    }
    
    public func lockAEAF(on device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(.locked) {
                device.focusMode = .locked
            }
            
            if device.isExposureModeSupported(.locked) {
                device.exposureMode = .locked
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Error locking AE/AF: \(error)")
        }
    }
    
    public func unlockAEAF(on device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            
            if device.isFocusModeSupported(.continuousAutoFocus) {
                device.focusMode = .continuousAutoFocus
            }
            
            if device.isExposureModeSupported(.continuousAutoExposure) {
                device.exposureMode = .continuousAutoExposure
            }
            
            device.isSubjectAreaChangeMonitoringEnabled = true
            device.unlockForConfiguration()
        } catch {
            print("Error unlocking AE/AF: \(error)")
        }
    }
    
    public func setManualFocus(lensPosition: Float, on device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            if device.isFocusModeSupported(.locked) {
                device.setFocusModeLocked(lensPosition: lensPosition, completionHandler: nil)
            }
            device.unlockForConfiguration()
        } catch {
            print("Error setting manual focus: \(error)")
        }
    }
    
    public func setManualISO(_ iso: Float, on device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            let clampedISO = min(max(iso, device.activeFormat.minISO), device.activeFormat.maxISO)
            device.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: clampedISO, completionHandler: nil)
            device.unlockForConfiguration()
        } catch {
            print("Error setting manual ISO: \(error)")
        }
    }
    
    public func setManualShutterSpeed(_ duration: CMTime, on device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            let clampedDuration = max(min(duration, device.activeFormat.maxExposureDuration), device.activeFormat.minExposureDuration)
            device.setExposureModeCustom(duration: clampedDuration, iso: AVCaptureDevice.currentISO, completionHandler: nil)
            device.unlockForConfiguration()
        } catch {
            print("Error setting manual shutter speed: \(error)")
        }
    }
    
    public func setWhiteBalance(_ mode: AVCaptureDevice.WhiteBalanceMode, gains: AVCaptureDevice.WhiteBalanceGains?, on device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()
            if device.isWhiteBalanceModeSupported(mode) {
                device.whiteBalanceMode = mode
                if mode == .locked, let gains = gains {
                    let clampedGains = device.deviceWhiteBalanceGains(for: device.temperatureAndTintValues(for: gains))
                    device.setWhiteBalanceModeLocked(with: clampedGains, completionHandler: nil)
                }
            }
            device.unlockForConfiguration()
        } catch {
            print("Error setting white balance: \(error)")
        }
    }
}
