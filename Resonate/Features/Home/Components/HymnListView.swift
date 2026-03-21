import SwiftUI

struct HymnListView: View {

    let title: String
    let hymns: [HymnIndex]
    let environment: AppEnvironment
    @Environment(\.colorScheme) private var colorScheme

    private var subtitle: String {
        switch title {
        case "Most Loved Hymns":
            return "Beloved hymns the church returns to for worship, comfort, and steady devotion."
        case "Editor’s Picks", "Editor's Picks":
            return "A gentle place to begin your worship journey."
        default:
            return "A curated collection for worship and reflection."
        }
    }

    private var eyebrow: String {
        switch title {
        case "Most Loved Hymns":
            return "Community Treasure"
        case "Editor’s Picks", "Editor's Picks":
            return "Curated Collection"
        default:
            return "Collection"
        }
    }

    private var heroIcon: String {
        switch title {
        case "Most Loved Hymns":
            return "heart.fill"
        case "Editor’s Picks", "Editor's Picks":
            return "sparkles"
        default:
            return "music.note.list"
        }
    }

    private var heroAccent: Color {
        switch title {
        case "Most Loved Hymns":
            return colorScheme == .dark
                ? Color(red: 0.74, green: 0.56, blue: 0.36)
                : Color(red: 0.71, green: 0.53, blue: 0.31)
        case "Editor’s Picks", "Editor's Picks":
            return colorScheme == .dark
                ? Color(red: 0.63, green: 0.66, blue: 0.77)
                : Color(red: 0.67, green: 0.69, blue: 0.80)
        default:
            return PremiumTheme.accent(for: colorScheme)
        }
    }

    var body: some View {
        ZStack {
            PremiumScreenBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    LazyVStack(spacing: 14) {
                        ForEach(hymns, id: \.id) { hymn in
                            HymnRowCard(
                                hymn: hymn,
                                environment: environment
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(eyebrow)
                        .font(PremiumTheme.eyebrowFont())
                        .textCase(.uppercase)
                        .tracking(1.0)
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.72) : PremiumTheme.accent(for: colorScheme))

                    Text(title)
                        .font(PremiumTheme.titleFont(size: 32))
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                    Text(subtitle)
                        .font(PremiumTheme.bodyFont())
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                ZStack {
                    Circle()
                        .fill(heroAccent.opacity(colorScheme == .dark ? 0.22 : 0.18))
                        .frame(width: 58, height: 58)
                        .overlay(
                            Circle()
                                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                        )

                    Image(systemName: heroIcon)
                        .font(PremiumTheme.scaledSystem(size: 22, weight: .semibold))
                        .foregroundStyle(colorScheme == .dark ? .white : heroAccent)
                }
            }

            HStack(spacing: 10) {
                heroPill(title: "Hymns", value: "\(hymns.count)", icon: "music.note")
                if title == "Most Loved Hymns" {
                    heroPill(title: "Tone", value: "Beloved", icon: "heart.fill")
                }
            }
        }
        .padding(22)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(PremiumTheme.panelFill(for: colorScheme))
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(heroAccent.opacity(colorScheme == .dark ? 0.20 : 0.14))
                        .frame(width: 180, height: 180)
                        .blur(radius: 12)
                        .offset(x: 36, y: -42)
                }
                .overlay(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    heroAccent.opacity(colorScheme == .dark ? 0.12 : 0.10),
                                    .clear
                                ],
                                startPoint: .bottomLeading,
                                endPoint: .center
                            )
                        )
                }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
        )
        .shadow(color: PremiumTheme.shadow(for: colorScheme), radius: 18, y: 10)
    }

    private func heroPill(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(colorScheme == .dark ? .white : PremiumTheme.primaryText(for: colorScheme))
            Text(title)
                .font(.subheadline)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.72) : PremiumTheme.secondaryText(for: colorScheme))
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(colorScheme == .dark ? .white : PremiumTheme.primaryText(for: colorScheme))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(PremiumTheme.searchFieldFill(for: colorScheme))
        )
        .overlay(
            Capsule()
                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
        )
    }
}

struct HymnRowCard: View {
    let hymn: HymnIndex
    let environment: AppEnvironment
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationLink {
            HymnDetailView(
                index: hymn,
                environment: environment,
                source: "hymn_list"
            )
        } label: {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(PremiumTheme.searchFieldFill(for: colorScheme))
                        .frame(width: 58, height: 58)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                        )

                    VStack(spacing: 2) {
                        Text("Hymn")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                        Text("\(hymn.id)")
                            .font(PremiumTheme.scaledSystem(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(hymn.title)
                        .font(PremiumTheme.scaledSystem(size: 20, weight: .semibold, design: .serif))
                        .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 10) {
                        Image(systemName: "tag.fill")
                            .font(PremiumTheme.scaledSystem(size: 11, weight: .semibold))
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                        Text(hymn.category.title)
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Text("•")
                            .font(.caption)
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme).opacity(0.6))

                        Image(systemName: "text.justify.left")
                            .font(PremiumTheme.scaledSystem(size: 11, weight: .semibold))
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                        Text("\(hymn.verseCount) verses")
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(PremiumTheme.scaledSystem(size: 14, weight: .semibold))
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    .padding(10)
                    .background(
                        Circle().fill(PremiumTheme.searchFieldFill(for: colorScheme))
                    )
                    .overlay(
                        Circle().stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                    )
            }
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(PremiumTheme.panelFill(for: colorScheme))
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(PremiumTheme.accent(for: colorScheme).opacity(colorScheme == .dark ? 0.08 : 0.06))
                            .frame(width: 110, height: 110)
                            .blur(radius: 10)
                            .offset(x: 20, y: -26)
                    }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
            )
            .shadow(color: PremiumTheme.shadow(for: colorScheme), radius: 14, y: 8)
        }
        .buttonStyle(.plain)
    }
}
