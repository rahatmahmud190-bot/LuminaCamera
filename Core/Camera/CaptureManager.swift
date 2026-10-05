import Foundation
import AVFoundation

public final class CaptureManager: NSObject {
    public let session = AVCaptureSession()
    public let previewLayer: AVCaptureVideoPreviewLayer
    
    public var videoDeviceInput: AVCaptureDeviceInput?
    public let photoOutput = AVCapturePhotoOutput()
    public let videoDataOutput = AVCaptureVideoDataOutput()
    public let movieFileOutput = AVCaptureMovieFileOutput()
    
    private let sessionQueue = DispatchQueue(label: "com.luminacamera.sessionQueue")
    
    public override init() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        super.init()
        self.previewLayer.videoGravity = .resizeAspectFill
        configureSession()
    }
    
    private func configureSession() {
        sessionQueue.async {
            self.session.beginConfiguration()
            
            if self.session.canSetSessionPreset(.photo) {
                self.session.sessionPreset = .photo
            }
            
            self.setupVideoInput(position: .back)
            
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true
                self.photoOutput.maxPhotoQualityPrioritization = .quality
            }
            
            if self.session.canAddOutput(self.videoDataOutput) {
                self.session.addOutput(self.videoDataOutput)
                self.videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            }
            
            if self.session.canAddOutput(self.movieFileOutput) {
                self.session.addOutput(self.movieFileOutput)
            }
            
            self.session.commitConfiguration()
        }
    }
    
    private func setupVideoInput(position: AVCaptureDevice.Position) {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) ?? AVCaptureDevice.default(for: .video) else {
            print("No video device found")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if let currentInput = self.videoDeviceInput {
                self.session.removeInput(currentInput)
            }
            
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.videoDeviceInput = input
            }
        } catch {
            print("Error creating video device input: \(error)")
        }
    }
    
    public func startSession() async {
        if !session.isRunning {
            sessionQueue.async {
                self.session.startRunning()
            }
        }
    }
    
    public func stopSession() {
        if session.isRunning {
            sessionQueue.async {
                self.session.stopRunning()
            }
        }
    }
    
    public func switchCamera() {
        sessionQueue.async {
            guard let currentInput = self.videoDeviceInput else { return }
            let newPosition: AVCaptureDevice.Position = currentInput.device.position == .back ? .front : .back
            
            self.session.beginConfiguration()
            self.setupVideoInput(position: newPosition)
            self.session.commitConfiguration()
        }
    }
    
    public func capturePhoto(flashMode: AVCaptureDevice.FlashMode) {
        sessionQueue.async {
            let settings = AVCapturePhotoSettings()
            if self.photoOutput.supportedFlashModes.contains(flashMode) {
                settings.flashMode = flashMode
            }
            settings.isHighResolutionPhotoEnabled = true
            settings.photoQualityPrioritization = .quality
            
            if let hevcType = self.photoOutput.availablePhotoCodecTypes.first(where: { $0 == .hevc }) {
                let heicSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: hevcType])
                heicSettings.flashMode = settings.flashMode
                heicSettings.isHighResolutionPhotoEnabled = true
                heicSettings.photoQualityPrioritization = .quality
                self.photoOutput.capturePhoto(with: heicSettings, delegate: self)
            } else {
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }
    
    public func startRecording() {
        sessionQueue.async {
            guard !self.movieFileOutput.isRecording else { return }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
            self.movieFileOutput.startRecording(to: url, recordingDelegate: self)
        }
    }
    
    public func stopRecording() {
        sessionQueue.async {
            guard self.movieFileOutput.isRecording else { return }
            self.movieFileOutput.stopRecording()
        }
    }
}

extension CaptureManager: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            HapticManager.shared.error()
            return
        }
        HapticManager.shared.success()
        // Save to photos...
    }
}

extension CaptureManager: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording movie: \(error)")
            HapticManager.shared.error()
            return
        }
        HapticManager.shared.success()
        // Save to photos...
    }
}
