import SwiftUI

struct DifficultyDots: View {
    let level: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { index in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(index <= level ? .accentColor : .gray.opacity(0.3))
            }
        }
    }
}
