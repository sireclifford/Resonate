import SwiftUI

struct WorshipFlowContainer: View {
    let hymnID: Int
    let environment: AppEnvironment
    
    private var slides: [WorshipSlide] {
        let viewModel = DevotionViewModel(hymnID: hymnID, hymnService: environment.hymnService)
        
        let highlightText: String = viewModel.detail?.highlight
        ?? viewModel.detail?.chorus?.first
        ?? viewModel.detail?.verses.first?.first
        ?? viewModel.title
        
        var slides: [WorshipSlide] = [.intro]
        
        let hasChorus = !(viewModel.detail?.chorus?.isEmpty ?? true)
        
        for verseIndex in 0..<max(viewModel.verseCount, 1) {
            slides.append(.verse(verseIndex: verseIndex))
            
            if hasChorus {
                slides.append(.chorus)
            }
        }
        
        slides.append(.highlight(text: highlightText))
        slides.append(.reflection)
        slides.append(.complete)
        
        return slides
    }
    
    var body: some View {
        let viewModel = DevotionViewModel(hymnID: hymnID, hymnService: environment.hymnService)
        
        WorshipFlowView(
            viewModel: viewModel,
            slides: slides,
            analytics: environment.analyticsService,
            audioService: environment.accompanimentPlaybackService,
            environment: environment
        )
    }
}


struct WorshipFlowView: View {
    @ObservedObject var viewModel: DevotionViewModel
    let slides: [WorshipSlide]
    let analytics: AnalyticsService
    let audioService: AccompanimentPlaybackService
    let environment: AppEnvironment
    
    @Environment(\.dismiss) private var dismiss
    @State private var index: Int = 0
    @State private var isMuted: Bool = false
    @State private var isClosing: Bool = false
    @State private var showStory: Bool = false
    @State private var hasStartedAudio = false
    
    private var canControlAudio: Bool {
        audioService.currentHymnID == viewModel.hymnID && (
            audioService.state == .playing ||
            audioService.state == .paused
        )
    }
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.black, .black.opacity(0.92), .gray.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            TabView(selection: $index) {
                ForEach(slides.indices, id: \.self) { i in
                    slideView(for: slides[i])
                        .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: index)
            .onAppear {
                analytics.log(
                    .worshipFlowStarted,
                    parameters: [.hymnID: viewModel.index?.id ?? viewModel.hymnID])
                
                if let hotd = environment.hymnService.hymnOfTheDay(),
                   viewModel.hymnID == hotd.id {
                    environment.hymnOfTheDayEngagementService.markOpened(hymnID: viewModel.hymnID)
                }
                
               
                
                isMuted = false
                isClosing = false
                logSlideView()
                
                guard !hasStartedAudio else { return }
                hasStartedAudio = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    guard !isClosing else { return }
                    audioService.toggleWorshipFlowPlayback(for: viewModel.hymnID)
                }
            }
            .onChange(of: index) { oldValue, newValue in
                logSlideView()
            }
            
            // Top chrome (progress + close)
            VStack(spacing: 10) {
                StoryProgressBar(total: slides.count, current: index)
                
                HStack {
                    Button {
                        closeFlow()
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
                        toggleMute()
                    } label: {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(.white.opacity(0.12))
                            .clipShape(Circle())
                            .opacity(canControlAudio ? 1.0 : 0.45)
                    }
                    .disabled(!canControlAudio)
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.top, 10)
            .zIndex(2)
            
            // Narrow edge tap zones so center content remains fully interactive.
            HStack {
                Color.clear
                    .frame(width: 72)
                    .contentShape(Rectangle())
                    .onTapGesture { previous() }
                
                Spacer()
                
                Color.clear
                    .frame(width: 72)
                    .contentShape(Rectangle())
                    .onTapGesture { next() }
            }
            .ignoresSafeArea()
            .zIndex(0)
        }
        // Swipe down to dismiss (optional)
        .gesture(
            DragGesture(minimumDistance: 16)
                .onEnded { value in
                    if value.translation.height > 80 {
                        closeFlow()
                    }
                }
        )
        .sheet(isPresented: $showStory) {
            NavigationStack {
                if let story = environment.hymnStoryService.story(for: viewModel.hymnID) {
                    HymnStoryView(story: story)
                        .environmentObject(environment)
                } else {
                    StoryUnavailableView()
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onDisappear {
            if !isClosing {
                audioService.stop()
            }
            hasStartedAudio = false
        }
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
            closeFlow()
        }
    }
    
    private func closeFlow() {
        guard !isClosing else { return }
        isClosing = true
        hasStartedAudio = false
        
        let fadeDuration: TimeInterval = 1.0
        audioService.fadeOutAndStop(duration: fadeDuration)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDuration) {
            dismiss()
        }
    }
    
    private func toggleMute() {
        guard canControlAudio else { return }
        
        if isMuted {
            audioService.resume()
            isMuted = false
        } else {
            audioService.pause()
            isMuted = true
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
        case .chorus: return "chorus"
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
            
        case .chorus:
            ChorusSlide(viewModel: viewModel)
            
        case .highlight(let text):
            HighlightSlide(
                hymn: viewModel.index ?? HymnIndex(
                    id: viewModel.hymnID,
                    title: viewModel.title,
                    category: .uncategorized,
                    language: .english,
                    verseCount: viewModel.verseCount,
                    occasions: nil
                ),
                highlight: text
            )
            
        case .reflection:
            ReflectionSlide(viewModel: viewModel)
            
        case .complete:
            CompletionSlide(
                viewModel: viewModel,
                onNext: {
                    environment.hymnOfTheDayEngagementService.markOpened(hymnID: viewModel.hymnID)
                        Haptics.light()
                    
                    next()
                },
                onOpenStory: {
                    showStory = true
                }
            )
        }
    }
}


