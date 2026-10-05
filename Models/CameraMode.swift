import Foundation
import CoreGraphics

public enum CameraMode: String, CaseIterable, Identifiable {
    case photo = "Photo"
    case portrait = "Portrait"
    case video = "Video"
    case cinematic = "Cinematic"
    case slowMotion = "Slo-Mo"
    case timeLapse = "Time Lapse"
    case night = "Night"
    case pro = "Pro"
    case macro = "Macro"
    case panorama = "Panorama"
    
    public var id: String { rawValue }
    
    public var systemIcon: String {
        switch self {
        case .photo: return "camera"
        case .portrait: return "person.crop.circle"
        case .video: return "video"
        case .cinematic: return "film"
        case .slowMotion: return "slowmo"
        case .timeLapse: return "timelapse"
        case .night: return "moon.stars"
        case .pro: return "camera.aperture"
        case .macro: return "leaf"
        case .panorama: return "pano"
        }
    }
    
    public var supportsZoom: Bool {
        return self != .macro && self != .panorama
    }
    
    public var defaultZoom: CGFloat {
        return 1.0
    }
}

public enum ZoomPreset: CGFloat, CaseIterable {
    case ultraWide = 0.5
    case normal = 1.0
    case twoX = 2.0
    case threeX = 3.0
    
    public var label: String {
        switch self {
        case .ultraWide: return "0.5x"
        case .normal: return "1x"
        case .twoX: return "2x"
        case .threeX: return "3x"
        }
    }
    
    public var isComputational: Bool {
        return self == .twoX || self == .threeX // true for 2x and 3x on modern devices like iPhone 14
    }
}
