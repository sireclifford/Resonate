import SwiftUI
struct IntroSlide: View {
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
                Spacer(minLength: 80)

                Text("Hymn of the Day")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))

                Text("#\(viewModel.index?.id ?? viewModel.hymnID)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))

                Text(viewModel.title)
                    .font(.system(size: 44, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(6)

                Spacer()

                Text("Take a moment to worship through this hymn.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 48)
        }
    }
}
