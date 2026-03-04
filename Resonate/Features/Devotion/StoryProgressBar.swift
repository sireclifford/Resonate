import SwiftUI

struct StoryProgressBar: View {
    let total: Int
    let current: Int
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { idx in
                Capsule()
                    .fill(idx <= current ? .white: .white.opacity(0.25))
                    .frame(height: 3)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
