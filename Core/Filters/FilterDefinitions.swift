import Foundation
import CoreGraphics
import SwiftUI

public struct CGPointCodable: Codable, Equatable {
    public var x: CGFloat
    public var y: CGFloat
    
    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    public init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }
    
    public var point: CGPoint {
        CGPoint(x: x, y: y)
    }
}

public struct HueAdjustment: Codable, Equatable {
    public var hue: Float
    public var saturation: Float
    public var luminance: Float
    
    public init(hue: Float = 0, saturation: Float = 0, luminance: Float = 0) {
        self.hue = hue
        self.saturation = saturation
        self.luminance = luminance
    }
}

public struct FilterParameters: Codable, Equatable {
    public var exposure: Float = 0
    public var brightness: Float = 0
    public var contrast: Float = 1.0
    public var saturation: Float = 1.0
    public var vibrance: Float = 0
    public var warmth: Float = 0
    public var tint: Float = 0
    public var highlights: Float = 0
    public var shadows: Float = 0
    public var sharpness: Float = 0
    public var clarity: Float = 0
    public var fade: Float = 0
    public var grain: Float = 0
    public var vignette: Float = 0
    public var bloom: Float = 0
    public var blur: Float = 0
    
    public var colorCurveR: [CGPointCodable] = []
    public var colorCurveG: [CGPointCodable] = []
    public var colorCurveB: [CGPointCodable] = []
    public var colorCurveLuma: [CGPointCodable] = []
    public var hueAdjustments: [HueAdjustment] = []
    
    public init() {}
}

public struct FilterPreset: Codable, Identifiable, Equatable {
    public var id: UUID = UUID()
    public var name: String
    public var parameters: FilterParameters
    
    public init(id: UUID = UUID(), name: String, parameters: FilterParameters = FilterParameters()) {
        self.id = id
        self.name = name
        self.parameters = parameters
    }
}
