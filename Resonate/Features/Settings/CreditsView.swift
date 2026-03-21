import SwiftUI

struct CreditsView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            PremiumScreenBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    hero

                    section(
                        title: "Development",
                        icon: "hammer.fill",
                        content: """
                        Resonate was designed and developed by Clifford Owusu.

                        The app brings together hymn reading, tune playback, scripture access, and historical companion material in a calm, focused interface built for worship and study.
                        """
                    )

                    richSection(title: "Content & Attribution", icon: "doc.text.magnifyingglass") {
                        Text("""
                        Historical commentary and companion material are sourced from Hymns for Worship - SDA Hymnal Companion and related attribution-friendly references.
                        """)
                        .font(PremiumTheme.bodyFont())
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))

                        linkPill(icon: "globe", title: "Hymns for Worship Website", urlString: "https://hymnsforworship.org", color: .blue)
                        linkPill(icon: "f.circle.fill", title: "Facebook", urlString: "https://www.facebook.com/hymnsforworship", color: Color(red: 59/255, green: 89/255, blue: 152/255))
                        linkPill(icon: "camera.circle.fill", title: "Instagram", urlString: "https://www.instagram.com/hymns4worship/", color: .pink)
                        linkPill(icon: "play.circle.fill", title: "YouTube", urlString: "https://www.youtube.com/@HymnsForWorship", color: .red)

                        Text("Content used with attribution as permitted by the publisher.")
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    }

                    section(
                        title: "Music & Tune Data",
                        icon: "music.note",
                        content: """
                        Tune names, composers, metrical structures, and selected historical metadata are informed by public hymnological archives and denominational hymn records.
                        """
                    )

                    richSection(title: "Bible & Scripture", icon: "book.fill") {
                        Text("""
                        Scripture references follow standard Protestant canon notation using USFM identifiers for internal indexing.

                        Bible API powered by YouVersion.
                        """)
                        .font(PremiumTheme.bodyFont())
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))

                        linkPill(icon: "globe", title: "YouVersion Website", urlString: "https://www.youversion.com", color: .blue)
                        linkPill(icon: "camera.circle", title: "Instagram", urlString: "https://www.instagram.com/youversion/", color: .pink)
                        linkPill(icon: "f.circle", title: "Facebook", urlString: "https://www.facebook.com/YouVersion", color: Color(red: 59/255, green: 89/255, blue: 152/255))
                        linkPill(icon: "play.circle", title: "YouTube", urlString: "https://www.youtube.com/@youversion", color: .red)
                        linkPill(icon: "music.note", title: "TikTok", urlString: "https://www.tiktok.com/@youversion?lang=en", color: .black)

                        Text("Biblical text display depends on selected translation within the app.")
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    }

                    section(
                        title: "Legal & Disclaimer",
                        icon: "shield.lefthalf.filled",
                        content: """
                        Resonate is an independent project and is not officially affiliated with the General Conference of Seventh-day Adventists.

                        Hymn texts, tune names, and referenced materials remain the property of their respective copyright holders. Where applicable, attribution is acknowledged within the app and its supporting metadata.
                        """
                    )

                    section(
                        title: "Acknowledgments",
                        icon: "heart.fill",
                        content: """
                        Special thanks to early testers, worship leaders, and contributors whose technical, theological, and usability feedback helped shape the app.
                        """
                    )
                }
                .padding()
            }
        }
        .navigationTitle("Credits")
    }

    private var hero: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [PremiumTheme.accent(for: colorScheme).opacity(0.18), Color.orange.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 84, height: 84)

                Image(systemName: "checkmark.seal.text.page")
                    .font(PremiumTheme.scaledSystem(size: 34, weight: .semibold))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
            }

            Text("Resonate")
                .font(PremiumTheme.sectionTitleFont())
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

            Text("A digital hymnal companion shaped for worship, reflection, and hymn study.")
                .font(PremiumTheme.bodyFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)

            Text(Bundle.main.appVersion)
                .font(PremiumTheme.captionFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 24)
    }


    private func section(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(PremiumTheme.accent(for: colorScheme))

                Text(title)
                    .font(PremiumTheme.scaledSystem(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
            }

            Text(content)
                .font(PremiumTheme.bodyFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 22)
    }

    private func richSection<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(PremiumTheme.accent(for: colorScheme))

                Text(title)
                    .font(PremiumTheme.scaledSystem(size: 24, weight: .semibold, design: .serif))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
            }

            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 22)
    }
    
    
    private func linkPill(icon: String, title: String, urlString: String, color: Color) -> some View {
        if let url = URL(string: urlString) {
            return AnyView(
                Link(destination: url) {
                    HStack(spacing: 10) {
                        Image(systemName: icon)
                            .foregroundStyle(color)
                        
                        Text(title)
                            .foregroundStyle(color)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(
                        Capsule()
                            .fill(color.opacity(0.15))
                    )
                    .overlay(
                        Capsule()
                            .stroke(color.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
}
