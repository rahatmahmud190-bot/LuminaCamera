import Foundation
import Photos
import UIKit

@MainActor
final class GalleryManager: ObservableObject {
    @Published var recentPhotos: [PHAsset] = []
    @Published var portraits: [PHAsset] = []
    @Published var favorites: [PHAsset] = []
    @Published var luminaAlbum: PHAssetCollection?
    
    private let albumName = "Lumina Camera"
    
    init() {
        Task {
            await fetchPhotos(limit: 100)
            await setupAlbum()
        }
    }
    
    private func setupAlbum() async {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let album = collection.firstObject {
            self.luminaAlbum = album
        } else {
            do {
                try await PHPhotoLibrary.shared().performChanges {
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: self.albumName)
                }
                let newCollection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
                self.luminaAlbum = newCollection.firstObject
            } catch {
                print("Failed to create album: \(error)")
            }
        }
    }
    
    func fetchPhotos(limit: Int) async {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = limit
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var newRecentPhotos: [PHAsset] = []
        allPhotos.enumerateObjects { asset, _, _ in
            newRecentPhotos.append(asset)
        }
        self.recentPhotos = newRecentPhotos
        
        // Note: For real filtering, checking metadata is required or utilizing smart albums for portraits/favorites
        self.favorites = newRecentPhotos.filter { $0.isFavorite }
        
        let smartOptions = PHFetchOptions()
        smartOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let portraitsFetch = PHAsset.fetchAssets(with: .image, options: smartOptions)
        // Simplification for portrait detection
        var newPortraits: [PHAsset] = []
        portraitsFetch.enumerateObjects { asset, _, _ in
            if asset.mediaSubtypes.contains(.photoDepthEffect) {
                newPortraits.append(asset)
            }
        }
        self.portraits = newPortraits
    }
    
    func savePhoto(_ image: UIImage, metadata: PhotoMetadata?) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
            // Ideally attach metadata as Exif
            
            if let album = self.luminaAlbum {
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                let placeholder = request.placeholderForCreatedAsset
                albumChangeRequest?.addAssets([placeholder!] as NSArray)
            }
        }
        await fetchPhotos(limit: 100)
    }
    
    func saveVideo(at url: URL) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            if let album = self.luminaAlbum, let placeholder = request?.placeholderForCreatedAsset {
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                albumChangeRequest?.addAssets([placeholder] as NSArray)
            }
        }
        await fetchPhotos(limit: 100)
    }
    
    func deleteAsset(_ asset: PHAsset) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }
        await fetchPhotos(limit: 100)
    }
    
    func toggleFavorite(_ asset: PHAsset) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest(for: asset)
            request.isFavorite = !asset.isFavorite
        }
        await fetchPhotos(limit: 100)
    }
    
    func loadThumbnail(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .opportunistic
            
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
    
    func loadFullImage(for asset: PHAsset) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .highQualityFormat
            
            PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}
