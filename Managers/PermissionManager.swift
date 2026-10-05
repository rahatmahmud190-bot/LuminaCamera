import Foundation
import AVFoundation
import Photos
import UIKit

@MainActor
final class PermissionManager: ObservableObject {
    static let shared = PermissionManager()
    
    @Published var cameraPermissionGranted: Bool = false
    @Published var microphonePermissionGranted: Bool = false
    @Published var photoLibraryPermissionGranted: Bool = false
    
    @Published var cameraPermissionDenied: Bool = false
    @Published var microphonePermissionDenied: Bool = false
    @Published var photoLibraryPermissionDenied: Bool = false
    
    init() {
        checkCameraPermission()
        checkMicrophonePermission()
        checkPhotoLibraryPermission()
    }
    
    func requestCameraPermission() async {
        guard !cameraPermissionDenied, !cameraPermissionGranted else { return }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            self.cameraPermissionGranted = granted
            self.cameraPermissionDenied = !granted
        case .restricted, .denied:
            self.cameraPermissionDenied = true
            self.cameraPermissionGranted = false
        case .authorized:
            self.cameraPermissionGranted = true
            self.cameraPermissionDenied = false
        @unknown default:
            break
        }
    }
    
    func requestMicrophonePermission() async {
        guard !microphonePermissionDenied, !microphonePermissionGranted else { return }
        
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .audio)
            self.microphonePermissionGranted = granted
            self.microphonePermissionDenied = !granted
        case .restricted, .denied:
            self.microphonePermissionDenied = true
            self.microphonePermissionGranted = false
        case .authorized:
            self.microphonePermissionGranted = true
            self.microphonePermissionDenied = false
        @unknown default:
            break
        }
    }
    
    func requestPhotoLibraryPermission() async {
        guard !photoLibraryPermissionDenied, !photoLibraryPermissionGranted else { return }
        
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            let result = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            let granted = (result == .authorized || result == .limited)
            self.photoLibraryPermissionGranted = granted
            self.photoLibraryPermissionDenied = !granted
        case .restricted, .denied:
            self.photoLibraryPermissionDenied = true
            self.photoLibraryPermissionGranted = false
        case .authorized, .limited:
            self.photoLibraryPermissionGranted = true
            self.photoLibraryPermissionDenied = false
        @unknown default:
            break
        }
    }
    
    func requestAllPermissions() async {
        await requestCameraPermission()
        await requestMicrophonePermission()
        await requestPhotoLibraryPermission()
    }
    
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        cameraPermissionGranted = (status == .authorized)
        cameraPermissionDenied = (status == .restricted || status == .denied)
    }
    
    private func checkMicrophonePermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        microphonePermissionGranted = (status == .authorized)
        microphonePermissionDenied = (status == .restricted || status == .denied)
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        photoLibraryPermissionGranted = (status == .authorized || status == .limited)
        photoLibraryPermissionDenied = (status == .restricted || status == .denied)
    }
}
