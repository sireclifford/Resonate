import SwiftUI

struct SettingsSectionCard<Content: View>: View {

    let title: String
    let icon: String
    let content: Content

    init(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)

                Text(title)
                    .font(.headline)
            }

            Divider()

            content
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.thinMaterial)
        )
    }
}
