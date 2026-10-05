import Foundation
import CoreGraphics

public struct FilterPreset: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var category: FilterCategory
    public var isCustom: Bool
    public var isFavorite: Bool
    public var intensity: Float // 0.0 to 1.0
    public var parameters: FilterParameters
    
    public init(id: UUID = UUID(), name: String, category: FilterCategory, isCustom: Bool = false, isFavorite: Bool = false, intensity: Float = 1.0, parameters: FilterParameters = FilterParameters.defaultParameters) {
        self.id = id
        self.name = name
        self.category = category
        self.isCustom = isCustom
        self.isFavorite = isFavorite
        self.intensity = intensity
        self.parameters = parameters
    }
}

public struct FilterParameters: Codable, Equatable {
    public var exposure: Float // -2 to +2 EV
    public var brightness: Float // -1 to +1
    public var contrast: Float // 0.5 to 2.0
    public var saturation: Float // 0 to 2
    public var vibrance: Float // -1 to +1
    public var warmth: Float // -1 to +1 (color temperature shift)
    public var tint: Float // -1 to +1
    public var highlights: Float // -1 to +1
    public var shadows: Float // -1 to +1
    public var sharpness: Float // 0 to 2
    public var clarity: Float // 0 to 1
    public var fade: Float // 0 to 1
    public var grain: Float // 0 to 1
    public var vignette: Float // 0 to 1
    public var bloom: Float // 0 to 1
    public var blur: Float // 0 to 1
    public var colorCurveR: [CGPoint] // tone curve points for red channel
    public var colorCurveG: [CGPoint] // green channel
    public var colorCurveB: [CGPoint] // blue channel
    public var colorCurveLuma: [CGPoint] // luminance curve
    public var hueAdjustments: [HueAdjustment] // per-hue shift/saturation/luminance
    
    public static var defaultParameters: FilterParameters {
        return FilterParameters(
            exposure: 0, brightness: 0, contrast: 1.0, saturation: 1.0, vibrance: 0,
            warmth: 0, tint: 0, highlights: 0, shadows: 0, sharpness: 0, clarity: 0,
            fade: 0, grain: 0, vignette: 0, bloom: 0, blur: 0,
            colorCurveR: [], colorCurveG: [], colorCurveB: [], colorCurveLuma: [],
            hueAdjustments: []
        )
    }
}

public struct HueAdjustment: Codable, Equatable {
    public var hue: Float // 0-360
    public var hueShift: Float
    public var saturationAdjust: Float
    public var luminanceAdjust: Float
}

public enum FilterCategory: String, CaseIterable, Codable {
    case natural = "Natural"
    case portrait = "Portrait" 
    case cinematic = "Cinematic"
    case film = "Film"
    case vintage = "Vintage"
    case blackAndWhite = "B&W"
    case warm = "Warm"
    case cool = "Cool"
    case korean = "Korean"
    case japanese = "Japanese"
    case street = "Street"
    case dreamy = "Dreamy"
    case dramatic = "Dramatic"
    case custom = "Custom"
}

public enum FilterLibrary {
    public static let allFilters: [FilterPreset] = [
        FilterPreset(name: "Natural", category: .natural, parameters: .defaultParameters),
        
        FilterPreset(name: "Vivid", category: .natural, parameters: {
            var p = FilterParameters.defaultParameters
            p.saturation = 1.3; p.contrast = 1.15; p.vibrance = 0.2
            return p
        }()),
        
        FilterPreset(name: "Warm", category: .warm, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = 0.3; p.saturation = 1.1
            return p
        }()),
        
        FilterPreset(name: "Cool", category: .cool, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = -0.3; p.shadows = -0.1 // Simulated blue shift in engine
            return p
        }()),
        
        FilterPreset(name: "Golden Hour", category: .warm, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = 0.4; p.highlights = 0.2; p.shadows = 0.2
            return p
        }()),
        
        FilterPreset(name: "Film 01", category: .film, parameters: {
            var p = FilterParameters.defaultParameters
            p.fade = 0.08; p.contrast = 1.1; p.warmth = 0.1; p.grain = 0.05
            return p
        }()),
        
        FilterPreset(name: "Film 02", category: .film, parameters: {
            var p = FilterParameters.defaultParameters
            p.fade = 0.12; p.warmth = -0.1; p.shadows = 0.3; p.grain = 0.08
            return p
        }()),
        
        FilterPreset(name: "Vintage", category: .vintage, parameters: {
            var p = FilterParameters.defaultParameters
            p.fade = 0.2; p.warmth = 0.2; p.grain = 0.12; p.vignette = 0.3; p.saturation = 0.8
            return p
        }()),
        
        FilterPreset(name: "Retro", category: .vintage, parameters: {
            var p = FilterParameters.defaultParameters
            p.fade = 0.25; p.warmth = 0.3; p.grain = 0.2; p.vignette = 0.4
            return p
        }()),
        
        FilterPreset(name: "Cinema", category: .cinematic, parameters: {
            var p = FilterParameters.defaultParameters
            p.contrast = 1.2; p.saturation = 0.85
            return p
        }()),
        
        FilterPreset(name: "Cinematic Blue", category: .cinematic, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = -0.2; p.saturation = 0.7; p.contrast = 1.3
            return p
        }()),
        
        FilterPreset(name: "Cinematic Warm", category: .cinematic, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = 0.3; p.contrast = 1.25
            return p
        }()),
        
        FilterPreset(name: "Seoul", category: .korean, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = -0.15; p.shadows = 0.15; p.saturation = 0.9; p.tint = -0.1
            return p
        }()),
        
        FilterPreset(name: "Tokyo", category: .japanese, parameters: {
            var p = FilterParameters.defaultParameters
            p.contrast = 1.3; p.warmth = -0.2; p.saturation = 0.8; p.tint = -0.05
            return p
        }()),
        
        FilterPreset(name: "Street", category: .street, parameters: {
            var p = FilterParameters.defaultParameters
            p.contrast = 1.4; p.saturation = 0.8; p.shadows = -0.2
            return p
        }()),
        
        FilterPreset(name: "Moody", category: .dramatic, parameters: {
            var p = FilterParameters.defaultParameters
            p.saturation = 0.7; p.shadows = 0.2; p.vignette = 0.4; p.warmth = -0.1
            return p
        }()),
        
        FilterPreset(name: "Soft Portrait", category: .portrait, parameters: {
            var p = FilterParameters.defaultParameters
            p.contrast = 0.9; p.shadows = 0.1; p.warmth = 0.1; p.clarity = 0.2
            return p
        }()),
        
        FilterPreset(name: "Dream", category: .dreamy, parameters: {
            var p = FilterParameters.defaultParameters
            p.saturation = 0.8; p.bloom = 0.3; p.shadows = 0.2
            return p
        }()),
        
        FilterPreset(name: "Noir", category: .blackAndWhite, parameters: {
            var p = FilterParameters.defaultParameters
            p.saturation = 0.0; p.contrast = 1.5; p.vignette = 0.5; p.shadows = -0.3
            return p
        }()),
        
        FilterPreset(name: "Classic B&W", category: .blackAndWhite, parameters: {
            var p = FilterParameters.defaultParameters
            p.saturation = 0.0; p.contrast = 1.0
            return p
        }()),
        
        FilterPreset(name: "Faded B&W", category: .blackAndWhite, parameters: {
            var p = FilterParameters.defaultParameters
            p.saturation = 0.0; p.fade = 0.15; p.shadows = 0.2
            return p
        }()),
        
        FilterPreset(name: "Punch", category: .dramatic, parameters: {
            var p = FilterParameters.defaultParameters
            p.contrast = 1.4; p.saturation = 1.4
            return p
        }()),
        
        FilterPreset(name: "Fade", category: .film, parameters: {
            var p = FilterParameters.defaultParameters
            p.shadows = 0.4; p.contrast = 0.8; p.fade = 0.3
            return p
        }()),
        
        FilterPreset(name: "Matte", category: .film, parameters: {
            var p = FilterParameters.defaultParameters
            p.shadows = 0.3; p.fade = 0.1; p.saturation = 0.85
            return p
        }()),
        
        FilterPreset(name: "Pacific", category: .cool, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = -0.25; p.shadows = 0.15; p.tint = -0.1
            return p
        }()),
        
        FilterPreset(name: "Sahara", category: .warm, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = 0.5; p.tint = 0.1
            return p
        }()),
        
        FilterPreset(name: "Forest", category: .natural, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = -0.1; p.tint = -0.2; p.shadows = -0.1
            return p
        }()),
        
        FilterPreset(name: "Blush", category: .portrait, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = 0.1; p.tint = 0.15; p.fade = 0.05; p.vignette = 0.2
            return p
        }()),
        
        FilterPreset(name: "Midnight", category: .dramatic, parameters: {
            var p = FilterParameters.defaultParameters
            p.shadows = -0.4; p.warmth = -0.4; p.contrast = 1.3
            return p
        }()),
        
        FilterPreset(name: "Latte", category: .warm, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = 0.25; p.contrast = 0.9; p.shadows = 0.1
            return p
        }()),
        
        FilterPreset(name: "Chrome", category: .film, parameters: {
            var p = FilterParameters.defaultParameters
            p.contrast = 1.3; p.saturation = 0.6; p.highlights = 0.3
            return p
        }()),
        
        FilterPreset(name: "Polaroid", category: .vintage, parameters: {
            var p = FilterParameters.defaultParameters
            p.warmth = 0.2; p.fade = 0.15; p.vignette = 0.4; p.exposure = 0.2
            return p
        }()),
        
        FilterPreset(name: "Cross Process", category: .vintage, parameters: {
            var p = FilterParameters.defaultParameters
            p.saturation = 1.3; p.contrast = 1.2; p.tint = 0.2 // Shifted processing in engine
            return p
        }()),
        
        FilterPreset(name: "Fuji", category: .film, parameters: {
            var p = FilterParameters.defaultParameters
            p.tint = -0.1; p.highlights = 0.1; p.contrast = 0.9
            return p
        }()),
        
        FilterPreset(name: "Kodak", category: .film, parameters: {
            var p = FilterParameters.defaultParameters
            p.grain = 0.1; p.shadows = 0.15; p.highlights = 0.2; p.warmth = 0.15
            return p
        }()),
        
        FilterPreset(name: "Ilford", category: .blackAndWhite, parameters: {
            var p = FilterParameters.defaultParameters
            p.saturation = 0; p.grain = 0.15; p.contrast = 1.1
            return p
        }()),
        
        FilterPreset(name: "Agfa", category: .blackAndWhite, parameters: {
            var p = FilterParameters.defaultParameters
            p.saturation = 0; p.warmth = -0.1; p.contrast = 1.4; p.grain = 0.12
            return p
        }()),
        
        FilterPreset(name: "Haze", category: .dreamy, parameters: {
            var p = FilterParameters.defaultParameters
            p.contrast = 0.7; p.saturation = 0.8; p.fade = 0.2; p.warmth = -0.1
            return p
        }()),
        
        FilterPreset(name: "Bloom", category: .dreamy, parameters: {
            var p = FilterParameters.defaultParameters
            p.exposure = 0.1; p.bloom = 0.5; p.warmth = 0.1
            return p
        }()),
        
        FilterPreset(name: "Cyber", category: .dramatic, parameters: {
            var p = FilterParameters.defaultParameters
            p.contrast = 1.4; p.shadows = -0.3; p.tint = 0.3; p.warmth = -0.2
            return p
        }())
    ]
}
