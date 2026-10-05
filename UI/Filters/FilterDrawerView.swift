import SwiftUI

struct FilterDrawerView: View {
    @Binding var isPresented: Bool
    @State private var selectedCategory: String = "Natural"
    @State private var intensity: Float = 100
    @State private var selectedFilter: String? = nil
    
    let categories = ["Natural", "Portrait", "Cinematic", "Film", "Vintage", "B&W", "Korean", "Japanese", "Street", "Dreamy", "Dramatic", "Custom"]
    
    var body: some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(categories, id: \.self) { cat in
                        Button(action: { selectedCategory = cat }) {
                            Text(cat)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedCategory == cat ? Color.white : Color.clear)
                                .foregroundColor(selectedCategory == cat ? .black : .white)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<10, id: \.self) { i in
                        let name = "Filter \(i)"
                        FilterThumbnailView(
                            image: UIImage(systemName: "photo") ?? UIImage(),
                            name: name,
                            isSelected: selectedFilter == name,
                            isFavorite: i % 3 == 0,
                            action: { selectedFilter = name },
                            longPressAction: {}
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            VStack {
                Text("Intensity: \(Int(intensity))%")
                    .font(.caption)
                    .foregroundColor(.gray)
                Slider(value: $intensity, in: 0...100)
                    .accentColor(.white)
                    .padding(.horizontal)
            }
            
            Button("New Custom Filter") {
                // Open custom filter editor
            }
            .foregroundColor(.yellow)
            .padding(.bottom)
        }
        .background(Color.black.opacity(0.9))
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
