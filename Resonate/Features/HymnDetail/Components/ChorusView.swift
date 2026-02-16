import SwiftUI

struct ChorusView: View {
    let lines: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Chorus")
                .font(.caption)
                .foregroundColor(.secondary)

            ForEach(lines, id: \.self) { line in
                Text(line)
            }
        }
        .padding(.vertical, 8)
        .italic()
    }
}
