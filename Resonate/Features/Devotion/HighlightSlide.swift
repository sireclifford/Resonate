import SwiftUI

struct HighlightSlide: View {
    let hymn: HymnIndex
    let highlight: String

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .black.opacity(0.92), .gray.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 22) {
                Spacer(minLength: 60)

                Text("Hold onto this line")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))

                Text(highlight)
                    .font(.system(size: 46, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 24)

                Text("— \(hymn.title)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 4)

                Spacer()

                Button {
                    // share highlight
                } label: {
                    Text("Share this line")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.white)
                        .clipShape(Capsule())
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 40)
        }
    }
}
