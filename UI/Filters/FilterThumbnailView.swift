import SwiftUI

struct FilterThumbnailView: View {
    let image: UIImage
    let name: String
    let isSelected: Bool
    let isFavorite: Bool
    let action: () -> Void
    let longPressAction: () -> Void
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                    )
                
                if isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .padding(4)
                }
            }
            
            Text(name)
                .font(.caption)
                .foregroundColor(isSelected ? .white : .gray)
        }
        .onTapGesture(perform: action)
        .onLongPressGesture(perform: longPressAction)
    }
}
