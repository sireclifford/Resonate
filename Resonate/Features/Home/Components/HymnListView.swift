import SwiftUI

struct HymnListView: View {

    let title: String
    let hymns: [HymnIndex]
    let environment: AppEnvironment

    private var subtitle: String {
        switch title {
        case "Most Loved Hymns":
            return "Beloved hymns to return to again and again."
        case "Editor’s Picks", "Editor's Picks":
            return "A gentle place to begin your worship journey."
        default:
            return "A curated collection for worship and reflection."
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.system(size: 34, weight: .bold, design: .rounded))

                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
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

