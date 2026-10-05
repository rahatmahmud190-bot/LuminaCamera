import SwiftUI

struct ParameterSlider: View {
    let label: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    var unitLabel: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text(label).font(.caption).foregroundColor(.white)
                Spacer()
                Text(String(format: "%.1f%@", value, unitLabel)).font(.caption.bold()).foregroundColor(.white)
            }
            Slider(value: $value, in: range)
                .accentColor(.white)
        }
        .padding(.horizontal)
        .frame(width: 200)
    }
}

enum EditorTab: String, CaseIterable, Identifiable {
    case light = "Light"
    case color = "Color"
    case detail = "Detail"
    case effects = "Effects"
    case crop = "Crop"
    var id: String { self.rawValue }
}

struct EditorTabBar: View {
    @Binding var selectedTab: EditorTab
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(EditorTab.allCases) { tab in
                    Button(action: { selectedTab = tab }) {
                        Text(tab.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .bold : .regular)
                            .foregroundColor(selectedTab == tab ? .white : .gray)
                            .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(Color.black.opacity(0.8))
    }
}

struct CropHandleView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .stroke(Color.white, lineWidth: 2)
            // Corners
            VStack {
                HStack {
                    corner
                    Spacer()
                    corner.rotationEffect(.degrees(90))
                }
                Spacer()
                HStack {
                    corner.rotationEffect(.degrees(-90))
                    Spacer()
                    corner.rotationEffect(.degrees(180))
                }
            }
        }
    }
    
    var corner: some View {
        Path { path in
            path.move(to: CGPoint(x: 20, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: 20))
        }
        .stroke(Color.white, lineWidth: 4)
        .frame(width: 20, height: 20)
    }
}
