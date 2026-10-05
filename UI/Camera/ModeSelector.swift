import SwiftUI

@available(iOS 17.0, *)
public struct ModeSelector: View {
    @Binding var selectedMode: CameraMode
    @State private var isActive: Bool = true
    @State private var hideTimer: Timer?
    
    let modes = CameraMode.allCases
    
    public init(selectedMode: Binding<CameraMode>) {
        self._selectedMode = selectedMode
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(modes, id: \.self) { mode in
                        VStack(spacing: 4) {
                            Text(mode.rawValue.uppercased())
                                .font(.system(size: 13, weight: selectedMode == mode ? .bold : .medium))
                                .foregroundColor(selectedMode == mode ? .white : .white.opacity(0.6))
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedMode = mode
                                    }
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    resetTimer()
                                }
                            
                            Circle()
                                .fill(selectedMode == mode ? Color.white : Color.clear)
                                .frame(width: 4, height: 4)
                        }
                        .id(mode)
                    }
                }
                .padding(.horizontal, UIScreen.main.bounds.width / 2 - 40)
            }
            .onChange(of: selectedMode) { old, newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
            .onAppear {
                proxy.scrollTo(selectedMode, anchor: .center)
                resetTimer()
            }
        }
        .frame(height: 50)
        .opacity(isActive ? 1.0 : 0.3)
        .gesture(
            DragGesture().onChanged { _ in
                resetTimer()
            }
        )
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
