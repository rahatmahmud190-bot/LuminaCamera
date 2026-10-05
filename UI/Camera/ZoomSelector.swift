import SwiftUI

@available(iOS 17.0, *)
public struct ZoomSelector: View {
    @Binding var currentZoom: CGFloat
    var onZoomChange: (CGFloat) -> Void
    
    let zoomLevels: [CGFloat] = [0.5, 1.0, 2.0, 3.0]
    
    public init(currentZoom: Binding<CGFloat>, onZoomChange: @escaping (CGFloat) -> Void) {
        self._currentZoom = currentZoom
        self.onZoomChange = onZoomChange
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(zoomLevels, id: \.self) { zoom in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        currentZoom = zoom
                    }
                    onZoomChange(zoom)
                }) {
                    VStack(spacing: 2) {
                        Text("\(String(format: "%g", zoom))x")
                            .font(.system(size: 14, weight: currentZoom == zoom ? .bold : .medium))
                            .foregroundColor(currentZoom == zoom ? .black : .white)
                            .frame(width: 44, height: 44)
                            .background(currentZoom == zoom ? Color.white : Color.clear)
                            .clipShape(Circle())
                        
                        if zoom == 2.0 || zoom == 3.0 {
                            Text("COMP")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(currentZoom == zoom ? .gray : .white.opacity(0.6))
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.3))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
