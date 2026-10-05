import SwiftUI
import Photos

enum GallerySegment: String, CaseIterable {
    case all = "All"
    case portraits = "Portraits"
    case edited = "Edited"
    case favorites = "Favorites"
}

struct GalleryView: View {
    @StateObject private var viewModel = GalleryViewModel()
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Picker("Segment", selection: $viewModel.selectedSegment) {
                        ForEach(GallerySegment.allCases, id: \.self) { segment in
                            Text(segment.rawValue).tag(segment)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .background(Color.black)
                    
                    if viewModel.isLoading {
                        ProgressView().tint(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.assets.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 48))
                                .foregroundColor(.gray)
                            Text("No Photos Found")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(viewModel.assets, id: \.localIdentifier) { asset in
                                    NavigationLink(value: asset) {
                                        GalleryCell(asset: asset, isSelected: viewModel.selectedAssets.contains(asset), isSelectionMode: viewModel.isInSelectionMode)
                                    }
                                    .simultaneousGesture(LongPressGesture().onEnded { _ in
                                        if !viewModel.isInSelectionMode {
                                            viewModel.isInSelectionMode = true
                                        }
                                        viewModel.toggleSelection(for: asset)
                                    })
                                }
                            }
                        }
                        .refreshable {
                            await viewModel.loadPhotos()
                        }
                    }
                }
            }
            .navigationTitle("Lumina")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            viewModel.isInSelectionMode.toggle()
                            if !viewModel.isInSelectionMode {
                                viewModel.selectedAssets.removeAll()
                            }
                        }
                    }) {
                        Text(viewModel.isInSelectionMode ? "Cancel" : "Select")
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationDestination(for: PHAsset.self) { asset in
                PhotoDetailView(asset: asset, allAssets: viewModel.assets)
            }
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                Task {
                    await viewModel.loadPhotos()
                }
            }
        }
    }
}

struct GalleryCell: View {
    let asset: PHAsset
    let isSelected: Bool
    let isSelectionMode: Bool
    @State private var thumbnail: UIImage?
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
                if let image = thumbnail {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                } else {
                    Color.gray.opacity(0.3)
                }
                
                if asset.mediaSubtypes.contains(.photoDepthEffect) {
                    Image(systemName: "f.cursive.circle.fill")
                        .foregroundColor(.yellow)
                        .padding(4)
                }
                
                if isSelectionMode {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.black.opacity(0.5))
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        .overlay(
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.caption)
                                .opacity(isSelected ? 1 : 0)
                        )
                        .frame(width: 24, height: 24)
                        .padding(4)
                }
            }
            .task {
                thumbnail = await GalleryManager().loadThumbnail(for: asset, targetSize: CGSize(width: geo.size.width * 2, height: geo.size.height * 2))
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
