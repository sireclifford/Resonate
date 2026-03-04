import SwiftUI

struct HighlightSlide: View {
    let hymn: HymnIndex
    let highlight: String

    var body: some View {
        ZStack {
            LinearGradient(colors: [.black, .black.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                Text("Hold onto this line")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))

                Text(highlight)
                    .font(.system(size: 46, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                    .padding(.horizontal, 18)

                Text("— \(hymn.title)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 6)

                Spacer()

                // Optional: share button (you can wire to your share sheet)
                Button {
                    // share highlight
                } label: {
                    Text("Share this line")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(.white)
                        .clipShape(Capsule())
                }

                Spacer()
            }
            .padding(.bottom, 40)
        }
    }
}
