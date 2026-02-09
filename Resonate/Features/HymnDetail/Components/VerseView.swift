import SwiftUI

struct VerseView: View {

    let title: String
    let lines: [String]
    let fontSize: ReaderFontSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(title)
                .font(.josefin(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.josefin(size: fontSize.value))
                    .lineSpacing(6)
            }
        }
    }
}
