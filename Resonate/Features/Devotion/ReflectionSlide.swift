import SwiftUI

struct ReflectionSlide: View {
    @ObservedObject var viewModel: DevotionViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Spacer()

                Text("Reflection")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))

                Text(viewModel.detail?.reflection ?? "Take a moment and let these words settle in your heart today.")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(10)

                Spacer()

                Text("Prayer (optional)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.65))

                Text("Lord, help me live what I just sang. Amen.")
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.9))
                    .lineSpacing(6)

                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 40)
        }
    }
}
