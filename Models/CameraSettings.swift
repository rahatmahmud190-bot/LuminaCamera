import Foundation
import SwiftUI

public enum PhotoFormat: String, CaseIterable, Identifiable {
    case heif = "HEIF"
    case jpeg = "JPEG"
    case raw = "RAW"
    public var id: String { rawValue }
}

public enum VideoResolution: String, CaseIterable, Identifiable {
    case hd720 = "720p"
    case hd1080 = "1080p"
    case k4 = "4K"
    public var id: String { rawValue }
}

public enum VideoFPS: Int, CaseIterable, Identifiable {
    case fps24 = 24
    case fps30 = 30
    case fps60 = 60
    case fps120 = 120
    case fps240 = 240
    public var id: Int { rawValue }
}

public enum GridType: String, CaseIterable, Identifiable {
    case off = "Off"
    case ruleOfThirds = "3x3"
    case goldenRatio = "Golden Ratio"
    case square = "Square"
    public var id: String { rawValue }
}

public final class SettingsManager: ObservableObject {
    @AppStorage("photoFormat") public var photoFormat: PhotoFormat = .heif
    @AppStorage("videoResolution") public var videoResolution: VideoResolution = .hd1080
    @AppStorage("videoFPS") public var videoFPS: VideoFPS = .fps30
    @AppStorage("hdrModeEnabled") public var isHDREnabled: Bool = true
    @AppStorage("stabilizationEnabled") public var isStabilizationEnabled: Bool = true
    @AppStorage("gridType") public var gridType: GridType = .off
    @AppStorage("soundEnabled") public var isSoundEnabled: Bool = true
    @AppStorage("hapticsEnabled") public var isHapticsEnabled: Bool = true
    @AppStorage("nightModeAuto") public var isNightModeAuto: Bool = true
    @AppStorage("smartCaptureEnabled") public var isSmartCaptureEnabled: Bool = true
    @AppStorage("mirrorFrontCamera") public var mirrorFrontCamera: Bool = false
    @AppStorage("preserveSettings") public var preserveSettings: Bool = true
    @AppStorage("timerDuration") public var timerDuration: Int = 0
    
    public init() {}
}
