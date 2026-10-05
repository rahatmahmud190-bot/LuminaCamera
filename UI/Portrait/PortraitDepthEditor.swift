import SwiftUI

struct PortraitDepthEditor: View {
    let image: UIImage
    @State private var fStop: Float = 2.8
    @State private var bgBlur: Float = 0.5
    @State private var fgBlur: Float = 0.2
    @State private var edgeRefinement: Bool = true
    @State private var showDepthMap: Bool = false
    @State private var isProcessing: Bool = false
    
    let fStops: [Float] = [1.4, 1.8, 2.2, 2.8, 4, 5.6, 8]
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {}
                    .foregroundColor(.white)
                Spacer()
                Text("Portrait")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {}
                    .foregroundColor(.yellow)
            }
            .padding()
            .background(Color.black)
            
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .onTapGesture { _ in
                        processDepth()
                    }
                
                if showDepthMap {
                    Color.red.opacity(0.3)
                        .blendMode(.multiply)
                }
                
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { showDepthMap.toggle() }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(showDepthMap ? .yellow : .white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            
            VStack(spacing: 20) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(fStops, id: \.self) { stop in
                            Button(action: {
                                fStop = stop
                                processDepth()
                            }) {
                                Text("f/\(String(format: "%.1f", stop))")
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(fStop == stop ? Color.yellow : Color.gray.opacity(0.3))
                                    .foregroundColor(fStop == stop ? .black : .white)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                VStack(spacing: 10) {
                    HStack {
                        Text("BG Blur").foregroundColor(.white).font(.caption)
                        Slider(value: $bgBlur, in: 0...1)
                    }
                    HStack {
                        Text("FG Blur").foregroundColor(.white).font(.caption)
                        Slider(value: $fgBlur, in: 0...1)
                    }
                    Toggle("Edge Refinement", isOn: $edgeRefinement)
                        .foregroundColor(.white)
                        .tint(.yellow)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color.black)
        }
    }
    
    private func processDepth() {
        isProcessing = true
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            isProcessing = false
        }
    }
}
