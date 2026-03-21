import SwiftUI
import Combine

struct ToastView: View {
    @State private var scale: CGFloat = 0.92
    let toast: ToastMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(PremiumTheme.scaledSystem(size: 16, weight: .semibold))
                .foregroundStyle(iconColor)
                .padding(.top, toast.subtitle == nil ? 1 : 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(toast.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                if let subtitle = toast.subtitle {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                scale = 1.0
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.systemBackground).opacity(0.35))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.black.opacity(0.14), radius: 14, y: 8)
        .gesture(
            DragGesture()
                .onEnded{ value in
                    if abs(value.translation.height) > 40 {
                        NotificationCenter.default.post(name: .dismissToast, object: nil)
                    }
                }
        )
    }

    private var iconName: String {
        switch toast.style {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.octagon.fill"
        case .info: return "bell.badge.fill"
        }
    }

    private var iconColor: Color {
        switch toast.style {
        case .success: return .green
        case .error: return .red
        case .info: return .accentColor
        }
    }

    private var borderColor: Color {
        switch toast.style {
        case .success: return .green.opacity(0.20)
        case .error: return .red.opacity(0.20)
        case .info: return Color.primary.opacity(0.08)
        }
    }
}
