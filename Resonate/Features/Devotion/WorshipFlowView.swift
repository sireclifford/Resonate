import SwiftUI

struct WorshipFlowContainer: View {
    let hymnID: Int
    let environment: AppEnvironment

    var body: some View {
        let viewModel = DevotionViewModel(hymnID: hymnID, hymnService: environment.hymnService)

        // Build slides using whatever is available synchronously from the view model.
        let highlightText: String = viewModel.detail?.chorus?.first
            ?? viewModel.detail?.verses.first?.first
            ?? viewModel.title

        let slides: [WorshipSlide] = [
            .intro,
            .verse(verseIndex: 0),
            .highlight(text: highlightText),
            .reflection,
            .complete
        ]

        WorshipFlowView(
            viewModel: viewModel,
            slides: slides,
            analytics: environment.analyticsService
        )
    }
}


struct WorshipFlowView: View {
    @ObservedObject var viewModel: DevotionViewModel
    let slides: [WorshipSlide]
    let analytics: AnalyticsService
    
    @Environment(\.dismiss) private var dismiss
    @State private var index: Int = 0

    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Content
            TabView(selection: $index) {
                ForEach(slides.indices, id: \.self) { i in
                    slideView(for: slides[i])
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onAppear {
                analytics.log(
                .worshipFlowStarted,
                parameters: [.hymnID: viewModel.index?.id ?? viewModel.hymnID])
                logSlideView()
            }
            .onChange(of: index) { oldValue, newValue in
                logSlideView()
            }
            
            // Top chrome (progress + close)
            VStack(spacing: 10) {
                StoryProgressBar(total: slides.count, current: index)
                
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button {
                        // optional: menu (share/report/etc)
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.top, 6)
            
            // Tap zones (left/right) like Stories
            HStack(spacing: 0) {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { previous() }
                
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { next() }
            }
            .ignoresSafeArea()
        }
        // Swipe down to dismiss (optional)
        .gesture(
            DragGesture(minimumDistance: 16)
                .onEnded { value in
                    if value.translation.height > 80 {
                        dismiss()
                    }
                }
        )
    }
    
    private func previous() {
        guard index > 0 else { return }
        index -= 1
    }
    
    private func next() {
        if index < slides.count - 1 {
            index += 1
        } else {
            // completed
            analytics.log(
            .worshipFlowCompleted,
            parameters: [.hymnID: viewModel.index?.id ?? viewModel.hymnID])
            dismiss()
        }
    }
    
    private func logSlideView() {
        let slide = slides[index]
        analytics.log(.worshipSlideViewed, parameters: [
            .hymnID: viewModel.index?.id ?? viewModel.hymnID,
            .index: index,
            .slide: slideName(slide)
        ])
    }
    
    private func slideName(_ slide: WorshipSlide) -> String {
        switch slide {
        case .intro: return "intro"
        case .verse(let v): return "verse_\(v)"
        case .highlight: return "highlight"
        case .reflection: return "reflection"
        case .complete: return "complete"
        }
    }
    
    @ViewBuilder
    private func slideView(for slide: WorshipSlide) -> some View {
        switch slide {
        case .intro:
            IntroSlide(viewModel: viewModel)

        case .verse(let verseIndex):
            VerseSlide(viewModel: viewModel, verseIndex: verseIndex)

        case .highlight(let text):
            HighlightSlide(hymn: viewModel.index ?? HymnIndex(id: viewModel.hymnID, title: viewModel.title, category: .uncategorized, language: .english, verseCount: viewModel.verseCount), highlight: text)

        case .reflection:
            ReflectionSlide(viewModel: viewModel)

        case .complete:
            CompletionSlide(viewModel: viewModel, onNext: {
                next()
            })
        }
    }
}
