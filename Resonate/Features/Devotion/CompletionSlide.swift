import SwiftUI

struct CompletionSlide: View {
    @ObservedObject var viewModel: DevotionViewModel
    let onNext: () -> Void
    let onOpenStory: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.white)

                Text("Worship Complete")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                Text("You spent a moment with\n“\(viewModel.title)” today.")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)

                Spacer()

                /*
                VStack(alignment: .leading, spacing: 10) {
                    Text("Up Next")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)

                    // Placeholder: your next content card
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.12))
                            .frame(width: 54, height: 54)
                            .overlay(Image(systemName: "play.fill").foregroundStyle(.white))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Guided Scripture")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.75))

                            Text("A 2–5 min devotion")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 18)
                */

                Button(action: onOpenStory) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Learn More")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)

                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.12))
                                .frame(width: 54, height: 54)
                                .overlay(
                                    Image(systemName: "book.pages")
                                        .foregroundStyle(.white)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Story Behind the Hymn")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(.white.opacity(0.75))

                                Text("Discover how \"\(viewModel.title)\" was written")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding(14)
                        .background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 18)
                }
                .buttonStyle(.plain)

                Button(action: onNext) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(.white)
                        .clipShape(Capsule())
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 18)
        }
    }
}
