import SwiftUI

struct FavouritesView: View {
    @Environment(\.colorScheme) private var colorScheme

    let environment: AppEnvironment
    @StateObject private var viewModel: FavouritesViewModel
    @ObservedObject private var audioService: AudioPlaybackService
    @State private var recentlyRemoved: HymnIndex?
    @State private var showUndoToast = false

    init(environment: AppEnvironment) {
        self.environment = environment
        _viewModel = StateObject(
            wrappedValue: FavouritesViewModel(
                hymnService: environment.hymnService,
                favouritesService: environment.favouritesService
            )
        )
        
        _audioService = ObservedObject(
               wrappedValue: environment.audioPlaybackService
           )
    }

    var body: some View {
        List {
            if viewModel.hymns.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                Section {
                    ForEach(viewModel.hymns) { hymn in
                        NavigationLink(value: hymn) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hymn \(hymn.id)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary.opacity(0.8))
                                
                                Text(hymn.title)
                                    .font(.system(size: 18, weight: .semibold))
                                
                                Text(hymn.category.title)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 6)
                            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                            .contentShape(Rectangle())
                        }
                        .listRowBackground(Color.clear)
                        .buttonStyle(.plain)
                        .buttonStyle(ScaleButtonStyle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    environment.favouritesService.toggle(id: hymn.id)
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                recentlyRemoved = hymn
                                showUndoToast = true
                            } label: {
                                Label("Remove", systemImage: "heart.slash")
                            }
                            .tint(Color.red.opacity(0.85))
                        }
                        .listRowSeparator(.visible)
                        .listRowSeparatorTint(Color("BrandAccent").opacity(0.35))
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let hymn = viewModel.hymns[index]
                            withAnimation(.easeInOut(duration: 0.25)) {
                                environment.favouritesService.toggle(id: hymn.id)
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            recentlyRemoved = hymn
                            showUndoToast = true
                        }
                    }
                }
                .listSectionSeparator(.hidden, edges: .top)
            }
        }
        .listStyle(.plain)
        .listRowSeparator(.visible)
        .listRowSeparatorTint(Color("BrandAccent").opacity(0.35))
        .scrollContentBackground(.hidden)
        .background(Color(.systemBackground))
        .navigationTitle("Your Library")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if !viewModel.hymns.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .font(.subheadline)
                }
            }
        }
        .tint(.secondary)
        .overlay(alignment: .bottom) {
            if showUndoToast, let removed = recentlyRemoved {
                HStack {
                    Text("Removed \(removed.title)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Undo") {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            environment.favouritesService.toggle(id: removed.id)
                        }
                        showUndoToast = false
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                }
                .padding()
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.75))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showUndoToast = false
                        }
                    }
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            if !viewModel.hymns.isEmpty {
                Text("\(viewModel.hymns.count) saved hymns")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart")
                .font(.system(size: 44))
                .foregroundColor(.secondary.opacity(0.6))
            
            Text("No Saved Hymns")
                .font(.headline)
            
            Text("Tap the heart icon on any hymn to add it to your personal library.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
