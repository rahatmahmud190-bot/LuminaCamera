import Foundation
import Photos
import SwiftUI

@MainActor
final class GalleryViewModel: ObservableObject {
    @Published var assets: [PHAsset] = []
    @Published var selectedSegment: GallerySegment = .all {
        didSet {
            Task { await loadPhotos() }
        }
    }
    @Published var isLoading: Bool = false
    @Published var selectedAsset: PHAsset?
    @Published var isInSelectionMode: Bool = false
    @Published var selectedAssets: Set<PHAsset> = []
    
    private let manager = GalleryManager()
    
    func loadPhotos() async {
        isLoading = true
        await manager.fetchPhotos(limit: 500)
        
        switch selectedSegment {
        case .all:
            self.assets = manager.recentPhotos
        case .portraits:
            self.assets = manager.portraits
        case .edited:
            self.assets = manager.recentPhotos // Mocked for edited
        case .favorites:
            self.assets = manager.favorites
        }
        isLoading = false
    }
    
    func toggleSelection(for asset: PHAsset) {
        if selectedAssets.contains(asset) {
            selectedAssets.remove(asset)
        } else {
            selectedAssets.insert(asset)
        }
    }
    
    func deleteSelected() async throws {
        for asset in selectedAssets {
            try await manager.deleteAsset(asset)
        }
        selectedAssets.removeAll()
        isInSelectionMode = false
        await loadPhotos()
    }
    
    func shareSelected() -> [Any] {
        // Normally you'd get the actual UIImages or URLs to share
        return []
    }
}
