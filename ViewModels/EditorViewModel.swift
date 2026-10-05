import SwiftUI
import CoreImage
import Combine
import Photos

enum CropRatio: String, CaseIterable, Identifiable {
    case original = "Original"
    case oneOne = "1:1"
    case fourFive = "4:5"
    case sixteenNine = "16:9"
    case nineSixteen = "9:16"
    case freeform = "Freeform"
    var id: String { self.rawValue }
}

struct FilterParameters: Equatable {
    var exposure: Float = 0
    var brightness: Float = 0
    var contrast: Float = 1
    var highlights: Float = 0
    var shadows: Float = 0
    var whites: Float = 0
    var blacks: Float = 0
    
    var saturation: Float = 1
    var vibrance: Float = 0
    var temperature: Float = 5500
    var tint: Float = 0
    
    var sharpness: Float = 0
    var clarity: Float = 0
    var noiseReduction: Float = 0
    
    var vignette: Float = 0
    var grain: Float = 0
    var fade: Float = 0
    var bloom: Float = 0
}

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var originalImage: UIImage
    @Published var editedImage: UIImage
    @Published var editorParameters = FilterParameters() {
        didSet {
            debounceUpdate()
        }
    }
    @Published var isProcessing: Bool = false
    @Published var showBeforeAfter: Bool = false
    @Published var cropRect: CGRect = .zero
    @Published var cropRatio: CropRatio = .original
    @Published var rotation: Angle = .zero
    @Published var undoStack: [FilterParameters] = []
    @Published var redoStack: [FilterParameters] = []
    
    private var updateTask: Task<Void, Never>?
    
    init(image: UIImage) {
        self.originalImage = image
        self.editedImage = image
    }
    
    func applyParameter<T>(_ keyPath: WritableKeyPath<FilterParameters, T>, value: T) async {
        undoStack.append(editorParameters)
        redoStack.removeAll()
        editorParameters[keyPath: keyPath] = value
    }
    
    private func debounceUpdate() {
        updateTask?.cancel()
        updateTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            if !Task.isCancelled {
                await processImage()
            }
        }
    }
    
    private func processImage() async {
        isProcessing = true
        // Mock processing delay and result
        try? await Task.sleep(nanoseconds: 50_000_000)
        self.editedImage = self.originalImage
        isProcessing = false
    }
    
    func undo() {
        guard let prev = undoStack.popLast() else { return }
        redoStack.append(editorParameters)
        editorParameters = prev
    }
    
    func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(editorParameters)
        editorParameters = next
    }
    
    func resetAll() {
        undoStack.append(editorParameters)
        redoStack.removeAll()
        editorParameters = FilterParameters()
    }
    
    func exportFinalImage() async throws -> UIImage {
        return editedImage
    }
    
    func saveToPhotos() async throws {
        let image = try await exportFinalImage()
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
}
