import SwiftUI

@available(iOS 17.0, *)
public struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat

    public func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.08),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

@available(iOS 17.0, *)
public extension View {
    func liquidGlass(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(LiquidGlassModifier(cornerRadius: cornerRadius))
    }
}

@available(iOS 17.0, *)
public struct GlassCard<Content: View>: View {
    var cornerRadius: CGFloat
    var padding: EdgeInsets
    var content: () -> Content
    
    public init(cornerRadius: CGFloat = 16, padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16), @ViewBuilder content: @escaping () -> Content) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content
    }
    
    public var body: some View {
        content()
            .padding(padding)
            .liquidGlass(cornerRadius: cornerRadius)
    }
}

@available(iOS 17.0, *)
public struct GlassPill: View {
    var label: String
    var isSelected: Bool
    var action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white : Color.clear)
                .clipShape(Capsule())
                .liquidGlass(cornerRadius: .infinity)
        }
    }
}

@available(iOS 17.0, *)
public struct GlassButton: View {
    var title: String
    var icon: String?
    var action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .liquidGlass(cornerRadius: 16)
        }
    }
}

@available(iOS 17.0, *)
public struct GlassIconButton: View {
    var icon: String
    var size: CGFloat
    var action: () -> Void
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .liquidGlass(cornerRadius: size / 2)
        }
    }
}
