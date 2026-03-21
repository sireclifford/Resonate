import SwiftUI

struct VerseSlide: View {
    @ObservedObject var viewModel: DevotionViewModel
    let verseIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 110)

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("Verse \(verseIndex + 1)")
                        .font(DevotionTheme.eyebrowFont())
                        .textCase(.uppercase)
                        .tracking(1.2)
                        .foregroundStyle(DevotionTheme.accent)

                    Spacer()

                    Text("\(max(viewModel.verseCount, 1)) total")
                        .font(DevotionTheme.badgeFont())
                        .foregroundStyle(DevotionTheme.secondaryText)
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(Array(viewModel.lines(for: verseIndex).enumerated()), id: \.offset) { _, line in
                            Text(line)
                                .font(DevotionTheme.verseFont())
                                .foregroundStyle(DevotionTheme.primaryText)
                                .lineSpacing(10)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(26)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .devotionPanel(cornerRadius: 32)

            Spacer(minLength: 32)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(DevotionTheme.badgeFont())
            .foregroundStyle(.white.opacity(0.85))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.white.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct ChorusSlide: View {
    @ObservedObject var viewModel: DevotionViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Spacer(minLength: 110)

            VStack(alignment: .leading, spacing: 18) {
                Text("Chorus")
                    .font(DevotionTheme.eyebrowFont())
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .foregroundStyle(DevotionTheme.accent)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array((viewModel.detail?.chorus ?? []).enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(DevotionTheme.chorusFont())
                            .foregroundStyle(DevotionTheme.primaryText)
                            .lineSpacing(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 10) {
                    Text("Sing the refrain")
                        .font(DevotionTheme.badgeFont())
                        .foregroundStyle(DevotionTheme.secondaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(DevotionTheme.chromeFill)
                        .overlay(
                            Capsule()
                                .stroke(DevotionTheme.chromeBorder, lineWidth: 1)
                        )
                        .clipShape(Capsule())
                }
            }
            .padding(26)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .devotionPanel(cornerRadius: 32)

            Spacer(minLength: 32)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
    }
}
