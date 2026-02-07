import SwiftUI

struct VerseView: View {

    let title: String
    let lines: [String]
    let fontSize: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(title)
                .font(.josefin(size: 15, weight: .semibold))
                .foregroundColor(.secondary)

            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.josefin(size: fontSize))
                    .lineSpacing(6)
            }
        }
    }
}
