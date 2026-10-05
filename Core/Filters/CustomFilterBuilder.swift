import Foundation
import UIKit
import Combine

@MainActor
public final class CustomFilterBuilder: ObservableObject {
    @Published public var currentParameters: FilterParameters
    @Published public var previewImage: UIImage?
    @Published public var presets: [FilterPreset]
    
    private let engine = FilterEngine.shared
    
    public init() {
        self.currentParameters = .defaultParameters
        self.presets = []
        loadPresets()
    }
    
    public func updateParameter<T>(_ keyPath: WritableKeyPath<FilterParameters, T>, value: T) {
        currentParameters[keyPath: keyPath] = value
    }
    
    public func generatePreview(from image: UIImage) async -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let ciImage = CIImage(cgImage: cgImage)
        
        // Create temporary preset for preview
        let tempPreset = FilterPreset(name: "Preview", category: .custom, parameters: currentParameters)
        let filtered = engine.apply(tempPreset, to: ciImage)
        
        if let outputCG = engine.ciContext.createCGImage(filtered, from: filtered.extent) {
            let result = UIImage(cgImage: outputCG, scale: image.scale, orientation: image.imageOrientation)
            self.previewImage = result
            return result
        }
        return image
    }
    
    public func savePreset(name: String) -> FilterPreset {
        let newPreset = FilterPreset(
            id: UUID(),
            name: name,
            category: .custom,
            isCustom: true,
            isFavorite: false,
            intensity: 1.0,
            parameters: currentParameters
        )
        presets.append(newPreset)
        persistPresets()
        return newPreset
    }
    
    public func renamePreset(_ preset: FilterPreset, newName: String) {
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index].name = newName
            persistPresets()
        }
    }
    
    public func duplicatePreset(_ preset: FilterPreset) -> FilterPreset {
        var newPreset = preset
        newPreset.id = UUID()
        newPreset.name = "\(preset.name) Copy"
        newPreset.isCustom = true
        presets.append(newPreset)
        persistPresets()
        return newPreset
    }
    
    public func deletePreset(_ preset: FilterPreset) {
        presets.removeAll { $0.id == preset.id }
        persistPresets()
    }
    
    public func resetToDefault() {
        currentParameters = .defaultParameters
    }
    
    public func exportPreset(_ preset: FilterPreset) -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(preset)
    }
    
    public func importPreset(from data: Data) throws -> FilterPreset {
        let decoder = JSONDecoder()
        var preset = try decoder.decode(FilterPreset.self, from: data)
        preset.id = UUID() // Generate new ID to avoid collisions
        preset.isCustom = true
        presets.append(preset)
        persistPresets()
        return preset
    }
    
    private func loadPresets() {
        if let data = UserDefaults.standard.data(forKey: "LuminaCustomPresets"),
           let saved = try? JSONDecoder().decode([FilterPreset].self, from: data) {
            self.presets = saved
        }
    }
    
    private func persistPresets() {
        if let data = try? JSONEncoder().encode(presets) {
            UserDefaults.standard.set(data, forKey: "LuminaCustomPresets")
        }
    }
}
