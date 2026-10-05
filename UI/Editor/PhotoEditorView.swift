import SwiftUI

struct PhotoEditorView: View {
    @StateObject var viewModel: EditorViewModel
    @State private var selectedTab: EditorTab = .light
    
    var body: some View {
        VStack(spacing: 0) {
            topBar
            
            ZStack {
                if viewModel.showBeforeAfter {
                    BeforeAfterView(original: viewModel.originalImage, edited: viewModel.editedImage)
                } else {
                    Image(uiImage: viewModel.editedImage)
                        .resizable()
                        .scaledToFit()
                    
                    if selectedTab == .crop {
                        CropHandleView()
                            .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            
            VStack {
                controlsForSelectedTab
                    .frame(height: 100)
                EditorTabBar(selectedTab: $selectedTab)
            }
            .background(Color.black)
        }
    }
    
    private var topBar: some View {
        HStack {
            Button("Cancel") {}
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 16) {
                Button(action: { viewModel.undo() }) { Image(systemName: "arrow.uturn.backward") }
                Button(action: { viewModel.redo() }) { Image(systemName: "arrow.uturn.forward") }
                Button(action: { viewModel.showBeforeAfter.toggle() }) { Image(systemName: "square.split.2x1") }
            }
            .foregroundColor(.white)
            Spacer()
            Button("Done") {}
                .foregroundColor(.yellow)
        }
        .padding()
        .background(Color.black)
    }
    
    @ViewBuilder
    private var controlsForSelectedTab: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                switch selectedTab {
                case .light:
                    ParameterSlider(label: "Exposure", value: $viewModel.editorParameters.exposure, range: -2...2)
                    ParameterSlider(label: "Brightness", value: $viewModel.editorParameters.brightness, range: -1...1)
                    ParameterSlider(label: "Contrast", value: $viewModel.editorParameters.contrast, range: 0.5...2)
                    ParameterSlider(label: "Highlights", value: $viewModel.editorParameters.highlights, range: -1...1)
                    ParameterSlider(label: "Shadows", value: $viewModel.editorParameters.shadows, range: -1...1)
                    ParameterSlider(label: "Whites", value: $viewModel.editorParameters.whites, range: -1...1)
                    ParameterSlider(label: "Blacks", value: $viewModel.editorParameters.blacks, range: -1...1)
                case .color:
                    ParameterSlider(label: "Saturation", value: $viewModel.editorParameters.saturation, range: 0...2)
                    ParameterSlider(label: "Vibrance", value: $viewModel.editorParameters.vibrance, range: -1...1)
                    ParameterSlider(label: "Temperature", value: $viewModel.editorParameters.temperature, range: 3000...8000)
                    ParameterSlider(label: "Tint", value: $viewModel.editorParameters.tint, range: -100...100)
                case .detail:
                    ParameterSlider(label: "Sharpness", value: $viewModel.editorParameters.sharpness, range: 0...2)
                    ParameterSlider(label: "Clarity", value: $viewModel.editorParameters.clarity, range: 0...1)
                    ParameterSlider(label: "Noise Reduction", value: $viewModel.editorParameters.noiseReduction, range: 0...1)
                case .effects:
                    ParameterSlider(label: "Vignette", value: $viewModel.editorParameters.vignette, range: 0...1)
                    ParameterSlider(label: "Grain", value: $viewModel.editorParameters.grain, range: 0...1)
                    ParameterSlider(label: "Fade", value: $viewModel.editorParameters.fade, range: 0...1)
                    ParameterSlider(label: "Bloom", value: $viewModel.editorParameters.bloom, range: 0...1)
                case .crop:
                    cropControls
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var cropControls: some View {
        HStack {
            ForEach(CropRatio.allCases) { ratio in
                Button(action: { viewModel.cropRatio = ratio }) {
                    Text(ratio.rawValue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(viewModel.cropRatio == ratio ? Color.white : Color.clear)
                        .foregroundColor(viewModel.cropRatio == ratio ? .black : .white)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: 1))
                }
            }
        }
    }
}
