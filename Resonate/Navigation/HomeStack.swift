import SwiftUI

struct HomeStack: View {
    let environment: AppEnvironment
    @Binding var selectedTab: Int
    @State private var path = NavigationPath()
    @State private var selectedWorshipHymnID: Int?
    @ObservedObject private var audioService: AccompanimentPlaybackService

    init(environment: AppEnvironment, selectedTab: Binding<Int>) {
        self.environment = environment
        self._selectedTab = selectedTab
        _audioService = ObservedObject(wrappedValue: environment.accompanimentPlaybackService)
    }
    
    var body: some View {
        ZStack {
            PremiumScreenBackground()

            NavigationStack(path: $path) {
                HomeView(
                    environment: environment,
                    onSelectHymn: { hymn in
                        environment.analyticsService.log(
                            .tabSwitched,
                            parameters: [
                                .source: "home",
                                .destination: "worship_detail_from_home_selection",
                                .hymnID: hymn.id
                            ]
                        )
                        path.append(hymn)
                    },
                    onSeeAll: {
                        selectedTab = 2
                    },
                    onRoute: { route in
                        path.append(route)
                    }
                )
                .navigationDestination(for: HymnIndex.self) { index in
                    HymnDetailView(
                        index: index,
                        environment: environment,
                        source: "home"
                    )
                }
                .navigationDestination(for: HymnCategory.self) { category in
                    CategoryDetailView(
                        category: category,
                        hymns: environment.categoryViewModel.hymns(for: category),
                        environment: environment,
                        favouritesService: environment.favouritesService
                    )
                }
                .navigationDestination(for: HomeRoute.self) { route in
                    switch route {
                    case .allCategories:
                        CategoriesView(environment: environment)
                        
                    case .mostLoved:
                        MostLovedHymnsView(environment: environment)
                        
                    case .editorsPicks:
                        EditorsPicksView(environment: environment)
                    }
                }
                .fullScreenCover(
                    isPresented: Binding(
                        get: { selectedWorshipHymnID != nil },
                        set: { isPresented in
                            if !isPresented {
                                selectedWorshipHymnID = nil
                            }
                        }
                    )
                ) {
                    if let hymnID = selectedWorshipHymnID {
                        WorshipFlowContainer(
                            hymnID: hymnID,
                            environment: environment
                        )
                    }
                }
                
                .onReceive(environment.navigationService.$requestedHymn) { request in
                    handleNavigationRequest(request)
                }
                .onAppear { handlePendingNavigationRequest() }
            }
        }
    }
    
    private func handlePendingNavigationRequest() {
        handleNavigationRequest(environment.navigationService.requestedHymn)
    }

    private func handleNavigationRequest(_ request: HymnNavigationRequest?) {
        guard let request else { return }
        guard let hymn = environment.hymnService.index.first(where: { $0.id == request.id }) else {
            environment.navigationService.consumeHymnRequest()
            return
        }

        // Ensure we are on Home tab
        selectedTab = 0

        // Reset navigation so the requested hymn opens cleanly
        path = NavigationPath()

        // Consume immediately so the same request is not handled twice.
        environment.navigationService.consumeHymnRequest()

        // Defer routing slightly to ensure the Home tab/stack is active first.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            environment.analyticsService.log(
                .tabSwitched,
                parameters: [
                    .source: request.source,
                    .destination: request.source == "notification" ? "worship_flow_from_notification" : "requested_hymn",
                    .hymnID: hymn.id
                ]
            )

            if request.source == "notification" {
                environment.analyticsService.reminderHymnOpened(hymnID: hymn.id)

                // Reset and present on the active Home stack.
                selectedWorshipHymnID = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    selectedWorshipHymnID = hymn.id
                }
            } else {
                path.append(hymn)
            }
        }
    }
    
}

enum HomeRoute: Hashable {
    case allCategories
    case mostLoved
    case editorsPicks
}
