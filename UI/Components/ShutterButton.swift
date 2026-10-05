import SwiftUI

public enum CameraMode: String, CaseIterable, Equatable {
    case photo = "Photo"
    case portrait = "Portrait"
    case video = "Video"
    case cinematic = "Cinematic"
    case sloMo = "Slo-Mo"
    case timeLapse = "Time Lapse"
    case night = "Night"
    case pro = "Pro"
    case macro = "Macro"
    case panorama = "Panorama"
    
    public var isVideoMode: Bool {
        return self == .video || self == .cinematic || self == .sloMo || self == .timeLapse
    }
}

@available(iOS 17.0, *)
public struct ShutterButton: View {
    var mode: CameraMode
    var isRecording: Bool = false
    var onShutter: () -> Void
    
    @State private var isPressed: Bool = false
    
    public init(mode: CameraMode, isRecording: Bool = false, onShutter: @escaping () -> Void) {
        self.mode = mode
        self.isRecording = isRecording
        self.onShutter = onShutter
    }
    
    public var body: some View {
        Button(action: {
            onShutter()
        }) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.8), lineWidth: 4)
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                if mode.isVideoMode {
                    RoundedRectangle(cornerRadius: isRecording ? 8 : 32)
                        .fill(Color.red)
                        .frame(width: isRecording ? 32 : 64, height: isRecording ? 32 : 64)
                } else {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 64, height: 64)
                }
            }
        }
        .buttonStyle(ShutterButtonStyle(isRecording: isRecording))
    }
}

@available(iOS 17.0, *)
struct ShutterButtonStyle: ButtonStyle {
    var isRecording: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .scaleEffect(isRecording ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isRecording)
    }
}
