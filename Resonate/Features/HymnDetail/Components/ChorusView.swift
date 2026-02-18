import SwiftUI

struct ChorusView: View {
    let lines: [String]
    let fontFamily: ReaderFontFamily
    let fontSize: ReaderFontSize
    let lineSpacing: ReaderLineSpacing

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Chorus")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(lines.indices, id: \.self) { index in
                Text(lines[index])
                    .font(fontFamily.font(ofSize: fontSize.value))
                    .lineSpacing(lineSpacing.value)
            }
        }
        .padding(.vertical, 8)
        .italic()
    }
}
