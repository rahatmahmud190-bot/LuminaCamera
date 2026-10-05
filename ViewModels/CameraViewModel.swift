import SwiftUI
import AVFoundation
import Combine

public enum SwipeDirection {
    case left, right
}

@MainActor
public final class CameraViewModel: ObservableObject {

    // MARK: - UI State
    @Published public var showFilterDrawer: Bool = false
    @Published public var showGallery: Bool = false
    @Published public var showSettings: Bool = false
    @Published public var showProMode: Bool = false
    @Published public var lastCapturedImage: UIImage? = nil
    @Published public var isCapturing: Bool = false
    @Published public var timerSeconds: Int = 0
    @Published public var isTimerActive: Bool = false
    @Published public var countdownValue: Int = 0

    // MARK: - Camera Engine (injected / shared)
    public var cameraEngine: CameraEngine

    /// Convenience passthrough so views can pass the session to CameraPreviewView
    public var session: AVCaptureSession { cameraEngine.captureManager.session }

    private var cancellables = Set<AnyCancellable>()

    public init(engine: CameraEngine = CameraEngine()) {
        self.cameraEngine = engine
    }

    // MARK: - Capture

    public func captureWithTimer() {
        guard timerSeconds > 0 else {
            cameraEngine.capturePhoto()
            return
        }
        isTimerActive = true
        countdownValue = timerSeconds
        Task {
            for remaining in stride(from: timerSeconds, through: 1, by: -1) {
                countdownValue = remaining
                HapticManager.shared.modeChange()
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            isTimerActive = false
            countdownValue = 0
            cameraEngine.capturePhoto()
        }
    }

    // MARK: - Gestures

    public func handlePinchZoom(scale: CGFloat) {
        let clampedZoom = max(0.5, min(scale * cameraEngine.currentZoom, 10.0))
        cameraEngine.setZoom(clampedZoom)
        HapticManager.shared.zoomChange()
    }

    public func handleTapFocus(at point: CGPoint, in size: CGSize) {
        // Convert view coordinates to normalized device coordinates
        let normalizedPoint = CGPoint(
            x: point.x / size.width,
            y: point.y / size.height
        )
        cameraEngine.setFocus(at: normalizedPoint)
    }

    public func handleSwipe(direction: SwipeDirection) {
        let modes = CameraMode.allCases
        guard let currentIndex = modes.firstIndex(of: cameraEngine.currentMode) else { return }
        switch direction {
        case .left:
            let nextIndex = min(currentIndex + 1, modes.count - 1)
            cameraEngine.currentMode = modes[nextIndex]
        case .right:
            let prevIndex = max(currentIndex - 1, 0)
            cameraEngine.currentMode = modes[prevIndex]
        }
        HapticManager.shared.modeChange()
    }

    public func handleVerticalDrag(translation: CGFloat) {
        // Map vertical drag to exposure compensation: -3.0 to +3.0 EV
        let currentEV = cameraEngine.exposureCompensation
        let delta = Float(-translation / 200.0) // drag up = positive EV
        let newEV = max(-3.0, min(3.0, currentEV + delta))
        cameraEngine.setExposureCompensation(newEV)
    }
}
