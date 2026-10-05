import SwiftUI
import Photos

struct PhotoDetailView: View {
    let asset: PHAsset
    let allAssets: [PHAsset]
    
    @State private var image: UIImage?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var showControls = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { val in
                                let delta = val / lastScale
                                lastScale = val
                                scale = min(max(scale * delta, 1), 5)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                                if scale < 1 {
                                    withAnimation(.spring()) {
                                        scale = 1
                                    }
                                }
                            }
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.spring()) {
                            scale = scale > 1 ? 1 : 2
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            showControls.toggle()
                        }
                    }
            } else {
                ProgressView().tint(.white)
            }
            
            if showControls {
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        Spacer()
                        Button(action: { /* Show info */ }) {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    HStack(spacing: 40) {
                        Button(action: { /* Edit */ }) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: { /* Share */ }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            Task { try? await GalleryManager().toggleFavorite(asset) }
                        }) {
                            Image(systemName: asset.isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(asset.isFavorite ? .red : .white)
                        }
                        
                        Button(action: {
                            Task { try? await GalleryManager().deleteAsset(asset); dismiss() }
                        }) {
                            Image(systemName: "trash")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            image = await GalleryManager().loadFullImage(for: asset)
        }
    }
}
