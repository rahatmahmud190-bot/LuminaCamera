import SwiftUI

struct PermissionView: View {
    @EnvironmentObject var permissionManager: PermissionManager
    
    var body: some View {
        ZStack {
            RadialGradient(gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.black]), center: .center, startRadius: 20, endRadius: 500)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "camera.aperture")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                
                VStack(spacing: 12) {
                    Text("Lumina Camera")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("To use Lumina Camera, we need access to your camera, microphone, and photo library.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    PermissionRow(
                        icon: "camera",
                        title: "Camera",
                        description: "Capture photos and videos",
                        isGranted: permissionManager.cameraPermissionGranted,
                        action: { Task { await permissionManager.requestCameraPermission() } }
                    )
                    
                    PermissionRow(
                        icon: "mic",
                        title: "Microphone",
                        description: "Record audio for videos",
                        isGranted: permissionManager.microphonePermissionGranted,
                        action: { Task { await permissionManager.requestMicrophonePermission() } }
                    )
                    
                    PermissionRow(
                        icon: "photo.on.rectangle",
                        title: "Photo Library",
                        description: "Save and view your captured moments",
                        isGranted: permissionManager.photoLibraryPermissionGranted,
                        action: { Task { await permissionManager.requestPhotoLibraryPermission() } }
                    )
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                if permissionManager.cameraPermissionDenied || permissionManager.microphonePermissionDenied || permissionManager.photoLibraryPermissionDenied {
                    Button(action: {
                        permissionManager.openAppSettings()
                    }) {
                        Text("Open Settings")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else {
                Button(action: action) {
                    Text("Grant")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}
