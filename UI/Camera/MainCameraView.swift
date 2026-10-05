import SwiftUI
import AVFoundation

@MainActor
public struct MainCameraView: View {

    @StateObject private var engine = CameraEngine()
    @StateObject private var viewModel: CameraViewModel

    @State private var flashMode: Int = 2          // 0=off,1=on,2=auto
    @State private var livePhotoEnabled: Bool = false
    @State private var isFrontCamera: Bool = false
    @State private var selectedMode: CameraMode = .photo
    @State private var currentZoom: CGFloat = 1.0

    @State private var focusPoint: CGPoint? = nil
    @State private var isFocusLocked: Bool = false
    @State private var exposureOffset: Float = 0.0

    @State private var showGallery: Bool = false
    @State private var showSettings: Bool = false
    @State private var showFilterDrawer: Bool = false
    @State private var showProMode: Bool = false

    public init() {
        let eng = CameraEngine()
        _engine = StateObject(wrappedValue: eng)
        _viewModel = StateObject(wrappedValue: CameraViewModel(engine: eng))
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // 1. Black background
                Color.black.ignoresSafeArea()

                // 2. Camera preview — full screen
                CameraPreviewView(session: engine.captureManager.session)
                    .ignoresSafeArea()

                // 3. Tap-to-focus gesture on preview
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { tap in
                                focusPoint = tap.location
                                isFocusLocked = false
                                viewModel.handleTapFocus(at: tap.location, in: geo.size)
                            }
                    )
                    .gesture(
                        MagnificationGesture()
                            .onChanged { scale in
                                viewModel.handlePinchZoom(scale: scale)
                                currentZoom = engine.currentZoom
                            }
                    )
                    .gesture(
                        LongPressGesture(minimumDuration: 0.6)
                            .onEnded { _ in
                                engine.lockAEAF()
                                isFocusLocked = true
                            }
                    )

                // 4. Focus indicator
                FocusIndicatorView(
                    focusPoint: $focusPoint,
                    isLocked: $isFocusLocked,
                    exposureOffset: $exposureOffset
                )

                // 5. Night mode countdown
                if engine.currentMode == .night && engine.isRecording {
                    NightModeCountdownView(seconds: 3, progress: 0.5)
                }

                // 6. Grid overlay
                GridOverlayView(gridType: .ruleOfThirds)

                // 7. Top controls
                VStack {
                    ControlsOverlayView(
                        flashMode: $flashMode,
                        livePhotoEnabled: $livePhotoEnabled,
                        timerState: $viewModel.timerSeconds,
                        isFrontCamera: $isFrontCamera,
                        onSettingsTapped: { showSettings = true }
                    )
                    Spacer()
                }

                // 8. Bottom controls (zoom + mode + toolbar)
                VStack(spacing: 0) {
                    Spacer()

                    ZoomSelector(currentZoom: $currentZoom) { zoom in
                        currentZoom = zoom
                        engine.setZoom(zoom)
                    }
                    .padding(.bottom, 12)

                    ModeSelector(selectedMode: $selectedMode)
                        .padding(.bottom, 16)
                        .onChange(of: selectedMode) { _, newMode in
                            engine.currentMode = newMode
                        }

                    HStack(spacing: 44) {
                        // Gallery button
                        GlassIconButton(icon: "photo.on.rectangle", size: 52) {
                            showGallery = true
                        }

                        // Shutter button
                        ShutterButton(mode: selectedMode, isRecording: engine.isRecording) {
                            if viewModel.timerSeconds > 0 {
                                viewModel.captureWithTimer()
                            } else {
                                switch selectedMode {
                                case .video, .cinematic, .slowMotion:
                                    if engine.isRecording { engine.stopRecording() }
                                    else { engine.startRecording() }
                                default:
                                    engine.capturePhoto()
                                }
                            }
                        }

                        // Flip camera button
                        GlassIconButton(icon: "arrow.triangle.2.circlepath.camera", size: 52) {
                            isFrontCamera.toggle()
                            engine.switchCamera()
                        }
                    }
                    .padding(.bottom, 36)
                }

                // 9. Timer countdown overlay
                if viewModel.isTimerActive {
                    AnimatedCounter(value: viewModel.countdownValue, fontSize: 96)
                }

                // 10. Recording indicator
                if engine.isRecording {
                    VStack {
                        HStack {
                            Spacer()
                            RecordingIndicatorView(duration: engine.recordingDuration)
                                .padding(.top, 56)
                                .padding(.trailing, 16)
                        }
                        Spacer()
                    }
                }
            }
            // Swipe left/right to change mode
            .gesture(
                DragGesture(minimumDistance: 40)
                    .onEnded { value in
                        let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                        if isHorizontal {
                            if value.translation.width < 0 {
                                viewModel.handleSwipe(direction: .left)
                            } else {
                                viewModel.handleSwipe(direction: .right)
                            }
                            selectedMode = engine.currentMode
                        } else {
                            viewModel.handleVerticalDrag(translation: value.translation.height)
                            exposureOffset = engine.exposureCompensation
                        }
                    }
            )
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .onAppear {
            engine.startSession()
        }
        .onDisappear {
            engine.stopSession()
        }
        .sheet(isPresented: $showGallery) {
            GalleryView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showFilterDrawer) {
            FilterDrawerView(selectedFilter: .constant(nil))
        }
        .sheet(isPresented: $showProMode) {
            ProModeView(cameraEngine: engine)
        }
    }
}
