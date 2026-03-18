import SwiftUI

struct VerseView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    let title: String
    let lines: [String]
    let fontSize: ReaderFontSize
    let fontFamily: ReaderFontFamily
    let lineSpacing: ReaderLineSpacing
    let showVerseNumbers: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if showVerseNumbers {
                HStack(spacing: 10) {
                    Text(title)
                        .font(fontFamily.font(ofSize: 14))
                        .foregroundColor(.secondary)

                    Rectangle()
                        .fill(Color.primary.opacity(colorScheme == .dark ? 0.14 : 0.08))
                        .frame(height: 1)
                }
            }
            
            Text(lines.joined(separator: "\n"))
                .font(fontFamily.font(ofSize: fontSize.value))
                .lineSpacing(lineSpacing.value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
