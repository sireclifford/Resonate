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

            ForEach(lines.indices, id: \.self) { index in
                Text(lines[index])
                    .font(.josefin(size: fontSize.value))
                    .lineSpacing(6)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
