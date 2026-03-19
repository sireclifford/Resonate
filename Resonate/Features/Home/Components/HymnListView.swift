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

    private var heroGradient: [Color] {
        switch title {
        case "Most Loved Hymns":
            return colorScheme == .dark
                ? [Color(red: 0.24, green: 0.18, blue: 0.19), Color(red: 0.15, green: 0.12, blue: 0.13)]
                : [Color(red: 0.84, green: 0.72, blue: 0.48), Color(red: 0.65, green: 0.52, blue: 0.31)]
        case "Editor’s Picks", "Editor's Picks":
            return colorScheme == .dark
                ? [Color(red: 0.19, green: 0.18, blue: 0.22), Color(red: 0.12, green: 0.12, blue: 0.15)]
                : [Color(red: 0.91, green: 0.92, blue: 0.96), Color(red: 0.82, green: 0.84, blue: 0.91)]
        default:
            return colorScheme == .dark
                ? [Color(red: 0.19, green: 0.18, blue: 0.20), Color(red: 0.12, green: 0.12, blue: 0.14)]
                : [Color(red: 0.94, green: 0.93, blue: 0.89), Color(red: 0.88, green: 0.87, blue: 0.82)]
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

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
            }
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(eyebrow)
                        .font(.caption.weight(.semibold))
                        .textCase(.uppercase)
                        .tracking(0.8)
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.72) : .secondary)

                    Text(title)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(colorScheme == .dark ? .white : .primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(colorScheme == .dark ? .white.opacity(0.78) : .primary.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.26))
                        .frame(width: 58, height: 58)

                    Image(systemName: heroIcon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(colorScheme == .dark ? .white : .primary)
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
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: heroGradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.06), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.24 : 0.08), radius: 18, y: 10)
    }

    private func heroPill(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(colorScheme == .dark ? .white : .primary)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(colorScheme == .dark ? .white.opacity(0.72) : .secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(colorScheme == .dark ? .white : .primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.24))
        )
        .overlay(
            Capsule()
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.10 : 0.05), lineWidth: 1)
        )
    }
}

struct HymnRowCard: View {
    let hymn: HymnIndex
    let environment: AppEnvironment
    @Environment(\.colorScheme) private var colorScheme

    private var palette: (Color, Color) {
        switch abs(hymn.id) % 5 {
        case 0:
            return (Color(red: 0.35, green: 0.50, blue: 0.88), Color(red: 0.20, green: 0.30, blue: 0.60)) // blue
        case 1:
            return (Color(red: 0.15, green: 0.62, blue: 0.46), Color(red: 0.10, green: 0.40, blue: 0.30)) // green
        case 2:
            return (Color(red: 0.78, green: 0.52, blue: 0.22), Color(red: 0.45, green: 0.28, blue: 0.10)) // gold
        case 3:
            return (Color(red: 0.55, green: 0.38, blue: 0.70), Color(red: 0.28, green: 0.18, blue: 0.42)) // purple
        default:
            return (Color(red: 0.28, green: 0.30, blue: 0.34), Color(red: 0.14, green: 0.15, blue: 0.18)) // graphite
        }
    }

    private var strokeGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(colorScheme == .dark ? 0.22 : 0.16),
                Color.white.opacity(0.00)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        NavigationLink {
            HymnDetailView(
                index: hymn,
                environment: environment,
                source: "hymn_list"
            )
        } label: {
            let cardShape = RoundedRectangle(cornerRadius: 24, style: .continuous)

            ZStack(alignment: .topTrailing) {
                // Base gradient with soft shadows
                cardShape
                    .fill(
                        LinearGradient(
                            colors: [
                                palette.0.opacity(colorScheme == .dark ? 0.40 : 0.55),
                                palette.1.opacity(colorScheme == .dark ? 0.30 : 0.35)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.35 : 0.10), radius: 16, y: 8)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.18 : 0.06), radius: 6, y: 3)

                // Glass veil
                cardShape
                    .fill(.ultraThinMaterial)
                    .opacity(colorScheme == .dark ? 0.20 : 0.22)

                // Top highlight
                cardShape
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(colorScheme == .dark ? 0.10 : 0.18), .clear],
                            center: .topLeading,
                            startRadius: 10,
                            endRadius: 220
                        )
                    )
                    .blendMode(.overlay)
                    .allowsHitTesting(false)

                // Stroke
                cardShape
                    .stroke(strokeGradient, lineWidth: 1)
                    .allowsHitTesting(false)

                // Watermark
                Image(systemName: "music.note.list")
                    .font(.system(size: 64, weight: .regular))
                    .foregroundStyle(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.12))
                    .padding(12)

                // Content
                HStack(alignment: .center, spacing: 14) {
                    // Left emblem
                    ZStack {
                        Circle()
                            .fill(.thinMaterial)
                        Circle()
                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.18 : 0.12), lineWidth: 1)

                        VStack(spacing: 2) {
                            Text("Hymn")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text("\(hymn.id)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                    }
                    .frame(width: 58, height: 58)
                    .shadow(color: Color.black.opacity(0.10), radius: 8, y: 5)

                    // Title and meta
                    VStack(alignment: .leading, spacing: 8) {
                        Text(hymn.title)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        HStack(spacing: 10) {
                            Image(systemName: "tag.fill")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Text(hymn.category.title)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)

                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.tertiary)

                            Image(systemName: "text.justify.left")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.secondary)
                            Text("\(hymn.verseCount) verses")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer(minLength: 8)

                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .background(
                            Circle().fill(.thinMaterial)
                        )
                        .overlay(
                            Circle().stroke(Color.primary.opacity(colorScheme == .dark ? 0.18 : 0.10), lineWidth: 1)
                        )
                }
                .padding(18)
            }
        }
        .buttonStyle(.plain)
    }
}
