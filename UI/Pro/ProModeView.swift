import SwiftUI
import CoreImage

struct HistogramView: View {
    let image: CIImage?
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(Text("Histogram").foregroundColor(.white).font(.caption))
            .frame(width: 80, height: 60)
            .cornerRadius(8)
    }
}

struct ProModeView: View {
    @State private var iso: String = "Auto"
    @State private var shutter: String = "Auto"
    @State private var wb: String = "Auto"
    @State private var focus: Float = -1 // -1 is Auto
    @State private var ev: Float = 0
    @State private var focusPeaking: Bool = false
    @State private var gridType: String = "None"
    
    let isos = ["Auto", "50", "100", "200", "400", "800", "1600", "3200"]
    let shutters = ["Auto", "1/4000", "1/2000", "1/1000", "1/500", "1/250", "1/125", "1/60", "1/30", "1/15", "1/8", "1/4", "1/2", "1s"]
    let wbs = ["Auto", "Tungsten", "Fluorescent", "Daylight", "Cloudy"]
    let grids = ["None", "Thirds", "Square", "Golden"]
    
    var body: some View {
        ZStack(alignment: .trailing) {
            VStack {
                Spacer()
                
                VStack(spacing: 12) {
                    HStack {
                        HistogramView(image: nil)
                        Spacer()
                        Toggle("Peaking", isOn: $focusPeaking)
                            .foregroundColor(.white)
                            .labelsHidden()
                            .overlay(Text("PEAK").font(.caption2).foregroundColor(.white).offset(y: 20))
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            proControlMenu(title: "ISO", selection: $iso, options: isos)
                            proControlMenu(title: "Shutter", selection: $shutter, options: shutters)
                            proControlMenu(title: "WB", selection: $wb, options: wbs)
                            proControlMenu(title: "Grid", selection: $gridType, options: grids)
                            
                            VStack {
                                Text("Focus").font(.caption2).foregroundColor(.gray)
                                Slider(value: $focus, in: -1...1)
                                    .frame(width: 100)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .cornerRadius(20, corners: [.topLeft, .topRight])
            }
            
            // EV Slider
            VStack {
                Text(String(format: "%+.1f", ev))
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(4)
                Slider(value: $ev, in: -3...3, step: 0.3)
                    .rotationEffect(.degrees(-90))
                    .frame(width: 20, height: 200)
            }
            .padding(.trailing, 16)
        }
    }
    
    private func proControlMenu(title: String, selection: Binding<String>, options: [String]) -> some View {
        Menu {
            ForEach(options, id: \.self) { opt in
                Button(opt) { selection.wrappedValue = opt }
            }
        } label: {
            VStack {
                Text(title).font(.caption2).foregroundColor(.gray)
                Text(selection.wrappedValue).font(.subheadline).foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.6))
            .clipShape(Capsule())
        }
    }
}
