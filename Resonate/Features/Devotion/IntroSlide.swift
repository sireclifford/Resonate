import SwiftUI
struct IntroSlide: View {
    @ObservedObject var viewModel: DevotionViewModel
    
    var body: some View {
        ZStack {
            // Replace with your hymn image background
            LinearGradient(colors: [.gray.opacity(0.35), .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Spacer()

                Text("Hymn of the Day")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))

                Text("#\(viewModel.index?.id ?? viewModel.hymnID)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white.opacity(0.85))

                Text(viewModel.title)
                    .font(.system(size: 44, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .lineSpacing(6)

                Spacer()
                Spacer()
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 48)
        }
    }
}
