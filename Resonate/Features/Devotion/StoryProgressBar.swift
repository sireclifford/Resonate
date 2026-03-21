import SwiftUI

struct StoryProgressBar: View {
    let total: Int
    let current: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { idx in
                Capsule()
                    .fill(idx <= current ? DevotionTheme.accent : Color.white.opacity(0.16))
                    .frame(height: idx == current ? 5 : 3)
                    .animation(.easeInOut(duration: 0.2), value: current)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(DevotionTheme.chromeFill)
        .overlay(
            Capsule()
                .stroke(DevotionTheme.chromeBorder, lineWidth: 1)
        )
        .clipShape(Capsule())
        .padding(.horizontal, 16)
    }
}
