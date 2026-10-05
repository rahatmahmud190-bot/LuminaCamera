import SwiftUI

@available(iOS 17.0, *)
public struct ControlsOverlayView: View {
    @Binding var flashMode: Int // 0: Off, 1: On, 2: Auto
    @Binding var livePhotoEnabled: Bool
    @Binding var timerState: Int // 0: Off, 3, 5, 10
    @Binding var isFrontCamera: Bool
    var onSettingsTapped: () -> Void
    
    @State private var isActive: Bool = true
    @State private var hideTimer: Timer?
    
    public var body: some View {
        HStack {
            // Flash
            GlassIconButton(icon: flashIcon(), size: 44) {
                flashMode = (flashMode + 1) % 3
                resetTimer()
            }
            Spacer()
            
            // Live Photo
            GlassIconButton(icon: livePhotoEnabled ? "livephoto" : "livephoto.slash", size: 44) {
                livePhotoEnabled.toggle()
                resetTimer()
            }
            Spacer()
            
            // Timer
            GlassIconButton(icon: timerIcon(), size: 44) {
                timerState = nextTimerState()
                resetTimer()
            }
            Spacer()
            
            // Settings
            GlassIconButton(icon: "gear", size: 44) {
                onSettingsTapped()
                resetTimer()
            }
            Spacer()
            
            // Camera Switch
            GlassIconButton(icon: "arrow.triangle.2.circlepath.camera", size: 44) {
                isFrontCamera.toggle()
                resetTimer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .opacity(isActive ? 1.0 : 0.0)
        .onAppear {
            resetTimer()
        }
    }
    
    private func flashIcon() -> String {
        switch flashMode {
        case 0: return "bolt.slash.fill"
        case 1: return "bolt.fill"
        default: return "bolt.badge.a.fill"
        }
    }
    
    private func timerIcon() -> String {
        switch timerState {
        case 3: return "timer"
        case 5: return "timer"
        case 10: return "timer"
        default: return "timer" // could use a slash if available
        }
    }
    
    private func nextTimerState() -> Int {
        switch timerState {
        case 0: return 3
        case 3: return 5
        case 5: return 10
        case 10: return 0
        default: return 0
        }
    }
    
    private func resetTimer() {
        isActive = true
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation(.easeInOut) {
                isActive = false
            }
        }
    }
}
