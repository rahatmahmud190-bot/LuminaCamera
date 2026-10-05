import SwiftUI

@available(iOS 17.0, *)
public struct AnimatedCounter: View {
    var value: Int
    var fontSize: CGFloat
    
    public var body: some View {
        Text("\(value)")
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .contentTransition(.numericText())
            .animation(.spring(), value: value)
    }
}

@available(iOS 17.0, *)
public struct ExposureSlider: View {
    @Binding var value: Float
    var range: ClosedRange<Float>
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 2)
                
                let normalizedValue = CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound))
                
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 2, height: geometry.size.height * normalizedValue)
                
                Image(systemName: "sun.max.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 14))
                    .offset(y: geometry.size.height * (1 - normalizedValue) - geometry.size.height / 2)
            }
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        let percent = 1 - (gesture.location.y / geometry.size.height)
                        let clamped = min(max(percent, 0), 1)
                        value = range.lowerBound + Float(clamped) * (range.upperBound - range.lowerBound)
                    }
            )
        }
    }
}

public enum GridType {
    case ruleOfThirds, square, goldenRatio
}

@available(iOS 17.0, *)
public struct GridOverlayView: View {
    var gridType: GridType
    
    public init(gridType: GridType = .ruleOfThirds) {
        self.gridType = gridType
    }
    
    public var body: some View {
        GeometryReader { geometry in
            Path { path in
                if gridType == .ruleOfThirds {
                    let w = geometry.size.width
                    let h = geometry.size.height
                    
                    path.move(to: CGPoint(x: w / 3, y: 0))
                    path.addLine(to: CGPoint(x: w / 3, y: h))
                    
                    path.move(to: CGPoint(x: w * 2 / 3, y: 0))
                    path.addLine(to: CGPoint(x: w * 2 / 3, y: h))
                    
                    path.move(to: CGPoint(x: 0, y: h / 3))
                    path.addLine(to: CGPoint(x: w, y: h / 3))
                    
                    path.move(to: CGPoint(x: 0, y: h * 2 / 3))
                    path.addLine(to: CGPoint(x: w, y: h * 2 / 3))
                }
            }
            .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
        }
        .allowsHitTesting(false)
    }
}

@available(iOS 17.0, *)
public struct NightModeCountdownView: View {
    var seconds: Int
    var progress: CGFloat
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.yellow, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
            
            Text("\(seconds)s")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.yellow)
        }
    }
}

@available(iOS 17.0, *)
public struct RecordingIndicatorView: View {
    var duration: TimeInterval
    @State private var isPulsing = false
    
    public var body: some View {
        HStack {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .opacity(isPulsing ? 0.3 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(), value: isPulsing)
            
            Text(timeString(from: duration))
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.5))
        .clipShape(Capsule())
        .onAppear {
            isPulsing = true
        }
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
