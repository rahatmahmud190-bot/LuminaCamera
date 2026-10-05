import Foundation
import CoreGraphics

enum CameraMode: String, Codable {
    case photo
    case video
    case portrait
}

struct PhotoData: Identifiable, Codable {
    var id: UUID
    var localIdentifier: String
    var captureMode: CameraMode
    var filterApplied: String?
    var isPortrait: Bool
    var portraitFStop: Float?
    var zoomFactor: CGFloat
    var hdrMode: String?
    var captureDate: Date
    var isEdited: Bool
    var isFavorite: Bool
}

struct PhotoMetadata: Codable {
    var captureMode: CameraMode
    var filterApplied: String?
    var isPortrait: Bool
    var portraitFStop: Float?
    var zoomFactor: CGFloat
    var hdrMode: String?
}

enum CropRatio: String, CaseIterable, Identifiable, Codable {
    case original = "Original"
    case square = "1:1"
    case portrait45 = "4:5"
    case landscape169 = "16:9"
    case portrait916 = "9:16"
    case freeform = "Freeform"
    
    var id: String { rawValue }
    
    var ratio: CGFloat? {
        switch self {
        case .original, .freeform:
            return nil
        case .square:
            return 1.0
        case .portrait45:
            return 4.0 / 5.0
        case .landscape169:
            return 16.0 / 9.0
        case .portrait916:
            return 9.0 / 16.0
        }
    }
}
