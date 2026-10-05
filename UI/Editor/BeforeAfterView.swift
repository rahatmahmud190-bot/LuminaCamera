import SwiftUI

struct BeforeAfterView: View {
    let original: UIImage
    let edited: UIImage
    @State private var offset: CGFloat = 0
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            let dividerX = geo.size.width / 2 + offset + dragOffset
            
            ZStack {
                Image(uiImage: original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                
                Image(uiImage: edited)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipShape(RightHalfClipShape(dividerX: dividerX))
                
                VStack {
                    Spacer()
                    HStack {
                        Text("Before")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(4)
                        Spacer()
                        Text("After")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(4)
                    }
                    .padding()
                }
                
                // Divider
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2)
                    
                    Capsule()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 8, height: 40)
                }
                .position(x: dividerX, y: geo.size.height / 2)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                offset += value.translation.width
                                let maxOffset = geo.size.width / 2 - 20
                                offset = min(max(offset, -maxOffset), maxOffset)
                            }
                        }
                )
            }
        }
        .ignoresSafeArea()
    }
}

struct RightHalfClipShape: Shape {
    var dividerX: CGFloat
    
    var animatableData: CGFloat {
        get { dividerX }
        set { dividerX = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRect(CGRect(x: dividerX, y: 0, width: rect.width - dividerX, height: rect.height))
        return path
    }
}
