import UIKit
import CoreHaptics

public final class HapticManager {
    public static let shared = HapticManager()
    
    private init() {}
    
    public func shutter() {
        guard isHapticsEnabled() else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    public func modeChange() {
        guard isHapticsEnabled() else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    public func zoomChange() {
        guard isHapticsEnabled() else { return }
        lightImpact()
    }
    
    public func focusLock() {
        guard isHapticsEnabled() else { return }
        success()
    }
    
    public func exposureChange() {
        guard isHapticsEnabled() else { return }
        lightImpact()
    }
    
    public func error() {
        guard isHapticsEnabled() else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    public func success() {
        guard isHapticsEnabled() else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    public func lightImpact() {
        guard isHapticsEnabled() else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private func isHapticsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "hapticsEnabled")
    }
}
