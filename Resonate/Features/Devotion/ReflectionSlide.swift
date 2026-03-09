import SwiftUI

struct ReflectionSlide: View {
    @ObservedObject var viewModel: DevotionViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .black.opacity(0.92), .gray.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Spacer(minLength: 40)

                Text("Reflection")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))

                Text(viewModel.detail?.reflection ?? "Take a moment and let these words settle in your heart today.")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(10)

                if let scripture = viewModel.detail?.scriptureRef {
                    Text(scripture)
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.top, 4)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Prayer (optional)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.65))

                    Text("Lord, help me live what I just sang. Amen.")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundStyle(.white.opacity(0.9))
                        .lineSpacing(6)
                }

                if let story = viewModel.detail?.storyHint {
                    Text(story)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 40)
        }
    }
}
