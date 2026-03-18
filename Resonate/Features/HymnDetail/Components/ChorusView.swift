import SwiftUI

struct ChorusView: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let lines: [String]
    let fontFamily: ReaderFontFamily
    let fontSize: ReaderFontSize
    let lineSpacing: ReaderLineSpacing

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .tracking(0.7)
                .foregroundColor(.secondary)

            Text(lines.joined(separator: "\n"))
                .font(fontFamily.font(ofSize: fontSize.value))
                .lineSpacing(lineSpacing.value)
                .foregroundStyle(.primary)
                .italic()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.06), lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.accentColor.opacity(0.45))
                .frame(width: 4)
                .padding(.vertical, 14)
                .padding(.leading, 10)
        }
        .padding(.vertical, 4)
    }
}
