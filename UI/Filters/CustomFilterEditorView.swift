import SwiftUI

struct CustomFilterEditorView: View {
    @StateObject var viewModel: EditorViewModel
    @State private var filterName: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") { dismiss() }
                    .foregroundColor(.white)
                Spacer()
                TextField("Filter Name", text: $filterName)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .background(Color.clear)
                Spacer()
                Button("Save") { dismiss() }
                    .foregroundColor(.yellow)
            }
            .padding()
            .background(Color.black)
            
            Image(uiImage: viewModel.editedImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                .background(Color.gray.opacity(0.2))
            
            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        Text("Basic").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity, alignment: .leading)
                        ParameterSlider(label: "Exposure", value: $viewModel.editorParameters.exposure, range: -2...2)
                        ParameterSlider(label: "Brightness", value: $viewModel.editorParameters.brightness, range: -1...1)
                        ParameterSlider(label: "Contrast", value: $viewModel.editorParameters.contrast, range: 0.5...2)
                    }
                    Group {
                        Text("Tone").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity, alignment: .leading)
                        ParameterSlider(label: "Highlights", value: $viewModel.editorParameters.highlights, range: -1...1)
                        ParameterSlider(label: "Shadows", value: $viewModel.editorParameters.shadows, range: -1...1)
                    }
                    Group {
                        Text("Color").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity, alignment: .leading)
                        ParameterSlider(label: "Saturation", value: $viewModel.editorParameters.saturation, range: 0...2)
                        ParameterSlider(label: "Vibrance", value: $viewModel.editorParameters.vibrance, range: -1...1)
                        ParameterSlider(label: "Temperature", value: $viewModel.editorParameters.temperature, range: 3000...8000)
                        ParameterSlider(label: "Tint", value: $viewModel.editorParameters.tint, range: -100...100)
                    }
                    Group {
                        Text("Detail").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity, alignment: .leading)
                        ParameterSlider(label: "Sharpness", value: $viewModel.editorParameters.sharpness, range: 0...2)
                        ParameterSlider(label: "Clarity", value: $viewModel.editorParameters.clarity, range: 0...1)
                    }
                    Group {
                        Text("Style").font(.headline).foregroundColor(.white).frame(maxWidth: .infinity, alignment: .leading)
                        ParameterSlider(label: "Fade", value: $viewModel.editorParameters.fade, range: 0...1)
                        ParameterSlider(label: "Grain", value: $viewModel.editorParameters.grain, range: 0...1)
                        ParameterSlider(label: "Vignette", value: $viewModel.editorParameters.vignette, range: 0...1)
                        ParameterSlider(label: "Bloom", value: $viewModel.editorParameters.bloom, range: 0...1)
                    }
                    
                    Button("Reset All") {
                        viewModel.resetAll()
                    }
                    .foregroundColor(.red)
                    .padding()
                }
                .padding()
            }
            .background(Color.black)
        }
        .ignoresSafeArea(.keyboard)
    }
}
