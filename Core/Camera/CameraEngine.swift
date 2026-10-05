import Foundation
import SwiftUI
import Combine
import AVFoundation


@MainActor
public final class CameraEngine: NSObject, ObservableObject {
    @Published public var isRunning: Bool = false
    @Published public var currentMode: CameraMode = .photo
    @Published public var currentZoom: CGFloat = 1.0
    @Published public var isNightModeActive: Bool = false
    @Published public var thermalState: ProcessInfo.ThermalState = ProcessInfo.processInfo.thermalState
    @Published public var isRecording: Bool = false
    @Published public var recordingDuration: TimeInterval = 0
    @Published public var flashMode: AVCaptureDevice.FlashMode = .off
    @Published public var focusPoint: CGPoint?
    @Published public var isAEAFLocked: Bool = false
    @Published public var exposureCompensation: Float = 0
    @Published public var currentFilter: FilterPreset? = nil
    
    public let captureManager = CaptureManager()
    public let zoomController = ZoomController()
    public let focusController = FocusController()
    
    private var cancellables = Set<AnyCancellable>()
    private var recordingTimer: Timer?
    
    public override init() {
        super.init()
        setupThermalMonitoring()
        
        // Forward preview layer
        // In a real implementation, we might expose captureManager.previewLayer via a view
    }
    
    private func setupThermalMonitoring() {
        NotificationCenter.default.publisher(for: ProcessInfo.thermalStateDidChangeNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.thermalState = ProcessInfo.processInfo.thermalState
            }
            .store(in: &cancellables)
    }
    
    public func startSession() {
        Task.detached {
            await self.captureManager.startSession()
            await MainActor.run {
                self.isRunning = self.captureManager.session.isRunning
            }
        }
    }
    
    public func stopSession() {
        captureManager.stopSession()
        isRunning = false
    }
    
    public func capturePhoto() {
        guard !isRecording else { return }
        captureManager.capturePhoto(flashMode: flashMode)
        HapticManager.shared.shutter()
    }
    
    public func startRecording() {
        guard currentMode == .video || currentMode == .cinematic else { return }
        isRecording = true
        recordingDuration = 0
        captureManager.startRecording()
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.recordingDuration += 1
            }
        }
    }
    
    public func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        captureManager.stopRecording()
    }
    
    public func switchCamera() {
        captureManager.switchCamera()
        currentZoom = 1.0
    }
    
    public func setZoom(_ factor: CGFloat) {
        guard let device = captureManager.videoDeviceInput?.device else { return }
        zoomController.setZoom(factor, on: device)
        currentZoom = factor
    }
    
    public func setFocus(at point: CGPoint) {
        guard let device = captureManager.videoDeviceInput?.device else { return }
        focusPoint = point
        focusController.focus(at: point, in: captureManager.previewLayer, on: device)
        isAEAFLocked = false
    }
    
    public func lockAEAF() {
        guard let device = captureManager.videoDeviceInput?.device else { return }
        focusController.lockAEAF(on: device)
        isAEAFLocked = true
        HapticManager.shared.focusLock()
    }
    
    public func unlockAEAF() {
        guard let device = captureManager.videoDeviceInput?.device else { return }
        focusController.unlockAEAF(on: device)
        isAEAFLocked = false
    }
    
    public func setFlash(_ mode: AVCaptureDevice.FlashMode) {
        flashMode = mode
    }
    
    public func setExposureCompensation(_ value: Float) {
        guard let device = captureManager.videoDeviceInput?.device else { return }
        do {
            try device.lockForConfiguration()
            device.setExposureTargetBias(value, completionHandler: nil)
            device.unlockForConfiguration()
            exposureCompensation = value
            HapticManager.shared.exposureChange()
        } catch {
            print("Failed to lock device for exposure compensation: \(error)")
        }
    }
}
