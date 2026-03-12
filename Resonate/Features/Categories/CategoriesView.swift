import SwiftUI

enum BrowseSegment: String, CaseIterable, Identifiable {
    case themes = "Themes"
    case all = "All Hymns"
    var id: String { rawValue }
}

struct CategoriesView: View {
    
    let environment: AppEnvironment
    @StateObject private var viewModel: CategoryViewModel
    
    @State private var segment: BrowseSegment = .themes
    @State private var isGrid: Bool = false
    @State private var searchText: String = ""
    @State private var selectedCategory: HymnCategory? = nil
    @State private var lastSearchText: String = ""
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(
            wrappedValue: CategoryViewModel(
                hymnService: environment.hymnService
            )
        )
    }
    
    private var allHymns: [HymnIndex] {
        environment.hymnService.index
    }
    
    private var filteredHymns: [HymnIndex] {
        let base = selectedCategory != nil
        ? allHymns.filter { $0.category == selectedCategory }
        : allHymns
        
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return base
        } else {
            let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let queryLower = trimmed.lowercased()
            return base.filter { hymn in
                // Text matches: title or category
                let textMatch = hymn.title.lowercased().contains(queryLower)
                || hymn.category.rawValue.lowercased().contains(queryLower)
                // Numeric matches: exact or partial id match
                let idString = String(hymn.id)
                let numericMatch = idString.contains(trimmed)
                return textMatch || numericMatch
            }
        }
    }
    
    // Adaptive grid for premium layout
    private let adaptiveColumns = [
        GridItem(.adaptive(minimum: 160), spacing: 16, alignment: .top)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented top bar
            Picker("", selection: $segment) {
                ForEach(BrowseSegment.allCases) { seg in
                    Text(seg.rawValue).tag(seg)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .onChange(of: segment) { _, newValue in
                environment.analyticsService.log(.tabSwitched, parameters: [.destination: newValue == .themes ? "browse_themes" : "browse_all", .source: "categories"])
            }
            
            Divider().opacity(0.5)
            
            if segment == .themes {
                // THEMES GRID
                ScrollView {
                    LazyVGrid(columns: adaptiveColumns, spacing: 16) {
                        ForEach(viewModel.categories) { category in
                            NavigationLink(value: category) {
                                premiumCategoryCard(
                                    title: category.title,
                                    count: environment.categoryViewModel.hymns(for: category).count,
                                    symbolName: symbol(for: category)
                                )
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(
                                TapGesture().onEnded {
                                    environment.analyticsService.log(
                                        .categoryOpened,
                                        parameters: [
                                            .category: category.title,
                                            .source: "categories"
                                        ]
                                    )
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .scrollIndicators(.hidden)
                .navigationTitle("Themes")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                // ALL HYMNS — FILTERABLE LIST/GRID
                VStack(spacing: 12) {
                    let trimmedPreviousQuery = lastSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    // Search
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField(selectedCategory == nil ? "Search hymns" : "Search in \(selectedCategory!.title)", text: $searchText)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .onChange(of: searchText) { oldValue, newValue in
                                lastSearchText = oldValue
                            }
                        
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                                environment.analyticsService.log(
                                    .searchCleared,
                                    parameters: [
                                        .previousQuery: trimmedPreviousQuery,
                                        .source: "categories"
                                    ]
                                )
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .onSubmit {
                        environment.analyticsService.log(
                            .searchPerformed,
                            parameters: [
                                .resultCount: filteredHymns.count,
                                .searchQuery: searchText,
                                .source: "categories"
                            ]
                        )
                    }
                    
                    // Category chips (single-select for simplicity)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ChipView(title: "All", selected: selectedCategory == nil) {
                                selectedCategory = nil
                                environment.analyticsService.log(
                                    .categoryOpened,
                                    parameters: [
                                        .category: "All",
                                        .source: "categories"
                                    ]
                                )
                            }
                            ForEach(viewModel.categories) { category in
                                ChipView(title: category.title, selected: selectedCategory == category) {
                                    selectedCategory = category
                                    environment.analyticsService.log(
                                        .categoryOpened,
                                        parameters: [
                                            .category: category.title,
                                            .source: "categories"
                                        ]
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // List/Grid toggle
                    HStack {
                        Text("\(selectedCategory?.title ?? "All Hymns") (\(filteredHymns.count))")
                            .font(.headline)
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isGrid.toggle()
                            }
                            environment.analyticsService.log(
                                .resultLayoutChanged,
                                parameters: [
                                    .layout: isGrid ? "grid" : "list",
                                    .source: "categories"
                                ]
                            )
                        } label: {
                            Image(systemName: isGrid ? "list.bullet" : "square.grid.2x2")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    
                    // Results
                    Group {
                        if isGrid {
                            ScrollView {
                                LazyVGrid(columns: adaptiveColumns, spacing: 14) {
                                    ForEach(filteredHymns) { hymn in
                                        NavigationLink(value: hymn) {
                                            HymnTileView(hymn: hymn)
                                        }
                                        .buttonStyle(.plain)
                                        .simultaneousGesture(
                                            TapGesture().onEnded {
                                                environment.analyticsService.log(
                                                    .hymnOpened,
                                                    parameters: [
                                                        .hymnID: String(hymn.id),
                                                        .hymnTitle: hymn.title,
                                                        .source: "categories"
                                                    ]
                                                )
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 24)
                            }
                            .scrollIndicators(.hidden)
                        } else {
                            List {
                                ForEach(filteredHymns) { hymn in
                                    NavigationLink {
                                        HymnDetailView(
                                            index: hymn,
                                            environment: environment,
                                            source: "categories"
                                        )
                                        .onAppear {
                                            environment.analyticsService.log(
                                                .hymnOpened,
                                                parameters: [
                                                    .hymnID: String(hymn.id),
                                                    .hymnTitle: hymn.title,
                                                    .source: "categories"
                                                ]
                                            )
                                        }
                                    } label: {
                                        HymnRowView(hymn: hymn)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                }
                            }
                            .listStyle(.plain)
                        }
                    }
                }
                .navigationTitle("Browse")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    
    // MARK: - Premium Category Card
    
    private func premiumCategoryCard(title: String, count: Int, symbolName: String) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.0), Color.white.opacity(0.06)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.primary.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 8)
            
            Image(systemName: symbolName)
                .font(.system(size: 88, weight: .regular))
                .foregroundStyle(Color.primary.opacity(0.10))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(10)
                .allowsHitTesting(false)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text("\(count) hymns")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(18)
        }
        .frame(height: 140)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    // MARK: - Support Views
    
    private func symbol(for category: HymnCategory) -> String {
        let title = category.title.lowercased()
        
        if title.contains("praise") || title.contains("adoration") {
            return "hands.clap"
        }
        else if title.contains("trinity") {
            return "bird.fill"
        } else if title.contains("worship") || title.contains("devotion") {
            return "sparkles"
        } else if title.contains("baptism") {
            return "drop.fill"
        } else if title.contains("birth") || title.contains("nativity") {
            return "star.fill"
        } else if title.contains("communion") || title.contains("eucharist") || title.contains("lord's supper") {
            return "cup.and.saucer.fill"
        } else if title.contains("warfare") || title.contains("battle") || title.contains("armor") {
            return "shield.lefthalf.filled"
        } else if title.contains("dedication") || title.contains("consecration") || title.contains("commitment") {
            return "flame.fill"
        } else if title.contains("confession") || title.contains("repentance") {
            return "drop.triangle.fill"
        } else if title.contains("thanksgiving") || title.contains("gratitude") {
            return "sun.max.fill"
        } else if title.contains("comfort") || title.contains("hope") || title.contains("encouragement") {
            return "heart.text.square.fill"
        } else if title.contains("forgiveness") || title.contains("mercy") || title.contains("grace") {
            return "hands.sparkles.fill"
        } else if title.contains("community") || title.contains("fellowship") || title.contains("unity") {
            return "person.2.fill"
        } else if title.contains("guidance") || title.contains("wisdom") {
            return "lightbulb.fill"
        } else if title.contains("healing") || title.contains("restoration") {
            return "cross.vial" // or stethoscope if preferred: "stethoscope"
        } else if title.contains("mission") || title.contains("evangelism") || title.contains("sending") {
            return "paperplane.fill"
        } else if title.contains("morning") || title.contains("dawn") {
            return "sunrise.fill"
        } else if title.contains("evening") || title.contains("night") {
            return "moon.stars.fill"
        } else if title.contains("faith") || title.contains("trust") {
            return "hands.and.sparkles.fill"
        } else if title.contains("joy") || title.contains("rejoice") {
            return "face.smiling.fill"
        } else if title.contains("peace") || title.contains("rest") {
            return "dove.fill" // if not available, fallback to "leaf.fill"
        } else if title.contains("cross") || title.contains("calvary") || title.contains("passion") {
            return "cross.fill"
        } else {
            return "book.pages" // a more refined neutral symbol than book.closed
        }
    }
}

private struct ChipView: View {
    let title: String
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    Capsule()
                        .fill(selected ? Color.accentColor.opacity(0.15) : Color(.secondarySystemBackground))
                )
                .overlay(
                    Capsule()
                        .stroke(selected ? Color.accentColor.opacity(0.5) : Color.primary.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct HymnRowView: View {
    let hymn: HymnIndex
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Circular hymn number badge
            ZStack {
                if colorScheme == .dark {
                    Circle()
                        .fill(.thinMaterial)
                    Circle()
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    Text("\(hymn.id)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.92))
                } else {
                    Circle()
                        .fill(Color(.secondarySystemBackground))
                    Circle()
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                    Text("\(hymn.id)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
            }
            .frame(width: 34, height: 34)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(hymn.title)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(hymn.category.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }
}

private struct HymnTileView: View {
    let hymn: HymnIndex
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accentColor.opacity(0.15))
                .frame(height: 80)
                .overlay(
                    Image(systemName: "music.note.list")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.accentColor.opacity(0.8))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(hymn.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(hymn.category.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(height: 44, alignment: .top) // Fix text block height so all cards match
        }
        .padding(12)
        .frame(height: 168, alignment: .top) // Fix overall tile height
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }
}
