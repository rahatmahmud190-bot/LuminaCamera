import Foundation
import CoreGraphics

struct PortraitData: Identifiable, Codable {
    var id: UUID = UUID()
    var originalImageData: Data?
    var portraitImageData: Data?
    var maskImageData: Data?
    var fStop: Float
    var zoomFactor: CGFloat
    var captureDate: Date
    var isEdited: Bool = false
}

enum PortraitFStop: Float, CaseIterable, Identifiable, Codable {
    case f14 = 1.4
    case f18 = 1.8
    case f22 = 2.2
    case f28 = 2.8
    case f40 = 4.0
    case f56 = 5.6
    case f80 = 8.0
    
    var id: Float { rawValue }
    
    var displayString: String {
        return "f/\(rawValue)"
    }
    
    var blurRadius: CGFloat {
        switch self {
        case .f14: return 35.0
        case .f18: return 28.0
        case .f22: return 22.0
        case .f28: return 16.0
        case .f40: return 10.0
        case .f56: return 6.0
        case .f80: return 3.0
        }
    }
    
    var label: String {
        return "f/\(rawValue)"
    }
}
