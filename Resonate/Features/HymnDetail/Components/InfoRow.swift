import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(title)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .fontWeight(.medium)
            }
            Divider().opacity(0.3)
        }
    }
}
