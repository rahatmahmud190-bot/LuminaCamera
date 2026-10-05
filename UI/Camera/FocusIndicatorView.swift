import SwiftUI

@available(iOS 17.0, *)
public struct FocusIndicatorView: View {
    @Binding var focusPoint: CGPoint?
    @Binding var isLocked: Bool
    @Binding var exposureOffset: Float
    
    @State private var scale: CGFloat = 1.5
    @State private var opacity: Double = 0.0
    @State private var hideTimer: Timer?
    
    public var body: some View {
        ZStack {
            if let point = focusPoint {
                HStack(spacing: 8) {
                    VStack {
                        Spacer()
                        ExposureSlider(value: $exposureOffset, range: -2.0...2.0)
                            .frame(width: 20, height: 100)
                        Spacer()
                    }
                    
                    ZStack {
                        Rectangle()
                            .stroke(Color.yellow, lineWidth: 1.5)
                            .frame(width: 80, height: 80)
                        
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 16))
                                .offset(y: -50)
                        }
                    }
                }
                .position(point)
                .scaleEffect(scale)
                .opacity(opacity)
                .onChange(of: focusPoint) { _, newValue in
                    if newValue != nil {
                        showFocus()
                    }
                }
                .onChange(of: exposureOffset) { _, _ in
                    resetHideTimer()
                }
            }
        }
    }
    
    private func showFocus() {
        scale = 1.5
        opacity = 1.0
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 1.0
        }
        resetHideTimer()
    }
    
    private func resetHideTimer() {
        hideTimer?.invalidate()
        if !isLocked {
            hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0.0
                }
            }
        }
    }
}
