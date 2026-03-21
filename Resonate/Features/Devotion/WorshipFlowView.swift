import SwiftUI
import UIKit

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

    private var currentSlideTitle: String {
        switch slides[index] {
        case .intro:
            return "Prepare"
        case .verse(let verseIndex):
            return "Verse \(verseIndex + 1)"
        case .chorus:
            return "Chorus"
        case .highlight:
            return "Hold This Line"
        case .reflection:
            return "Reflection"
        case .complete:
            return "Completion"
        }
    }
    
    private var canControlAudio: Bool {
        audioService.currentHymnID == viewModel.hymnID && (
            audioService.state == .playing ||
            audioService.state == .paused
        )
    }
    
    
    var body: some View {
        ZStack {
            DevotionBackdrop()
            
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
            
            VStack(spacing: 10) {
                HStack {
                    Button {
                        closeFlow()
                    } label: {
                        Image(systemName: "xmark")
                            .font(DevotionTheme.actionFont())
                            .foregroundStyle(DevotionTheme.primaryText)
                            .frame(width: 40, height: 40)
                            .background(DevotionTheme.chromeFill)
                            .overlay(
                                Circle()
                                    .stroke(DevotionTheme.chromeBorder, lineWidth: 1)
                            )
                            .clipShape(Circle())
                    }
                    
                    Spacer()

                    VStack(spacing: 4) {
                        Text(currentSlideTitle)
                            .font(DevotionTheme.eyebrowFont())
                            .textCase(.uppercase)
                            .tracking(1.2)
                            .foregroundStyle(DevotionTheme.secondaryText)

                        Text(viewModel.title)
                            .font(DevotionTheme.chromeTitleFont())
                            .foregroundStyle(DevotionTheme.primaryText)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(DevotionTheme.chromeFill)
                    .overlay(
                        Capsule()
                            .stroke(DevotionTheme.chromeBorder, lineWidth: 1)
                    )
                    .clipShape(Capsule())
                    
                    Spacer()

                    Button {
                        toggleMute()
                    } label: {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(DevotionTheme.actionFont())
                            .foregroundStyle(DevotionTheme.primaryText)
                            .frame(width: 40, height: 40)
                            .background(DevotionTheme.chromeFill)
                            .overlay(
                                Circle()
                                    .stroke(DevotionTheme.chromeBorder, lineWidth: 1)
                            )
                            .clipShape(Circle())
                            .opacity(canControlAudio ? 1.0 : 0.45)
                    }
                    .disabled(!canControlAudio)
                }
                .padding(.horizontal, 16)

                StoryProgressBar(total: slides.count, current: index)
                
                Spacer()
            }
            .padding(.top, 10)
            .zIndex(2)
            
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
            Haptics.medium()
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
                    next()
                },
                onOpenStory: {
                    showStory = true
                }
            )
        }
    }
}

enum DevotionTheme {
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.72)
    static let mutedText = Color.white.opacity(0.58)
    static let accent = Color(red: 0.86, green: 0.70, blue: 0.45)
    static let panelTop = Color(red: 0.16, green: 0.14, blue: 0.15).opacity(0.94)
    static let panelBottom = Color(red: 0.10, green: 0.09, blue: 0.10).opacity(0.96)
    static let panelBorder = Color.white.opacity(0.10)
    static let chromeFill = Color.white.opacity(0.08)
    static let chromeBorder = Color.white.opacity(0.12)

    private static func scaledFont(
        size: CGFloat,
        weight: UIFont.Weight = .regular,
        design: UIFontDescriptor.SystemDesign = .default,
        relativeTo textStyle: UIFont.TextStyle
    ) -> Font {
        let baseDescriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
        let descriptor = baseDescriptor.withDesign(design) ?? baseDescriptor
        let baseFont = UIFont(descriptor: descriptor, size: size)
        let scaledFont = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: baseFont)
        return Font(scaledFont)
    }

    static func eyebrowFont() -> Font {
        scaledFont(size: 12, weight: .bold, relativeTo: .caption2)
    }

    static func badgeFont() -> Font {
        scaledFont(size: 13, weight: .semibold, relativeTo: .caption1)
    }

    static func chromeTitleFont() -> Font {
        scaledFont(size: 16, weight: .semibold, design: .serif, relativeTo: .headline)
    }

    static func panelTitleFont() -> Font {
        scaledFont(size: 30, weight: .semibold, design: .serif, relativeTo: .title1)
    }

    static func heroTitleFont() -> Font {
        scaledFont(size: 42, weight: .bold, design: .serif, relativeTo: .largeTitle)
    }

    static func highlightFont() -> Font {
        scaledFont(size: 44, weight: .bold, design: .serif, relativeTo: .largeTitle)
    }

    static func verseFont() -> Font {
        scaledFont(size: 29, weight: .semibold, design: .serif, relativeTo: .title1)
    }

    static func chorusFont() -> Font {
        scaledFont(size: 31, weight: .bold, design: .serif, relativeTo: .title1)
    }

    static func bodyFont() -> Font {
        scaledFont(size: 18, weight: .medium, relativeTo: .body)
    }

    static func secondarySerifFont() -> Font {
        scaledFont(size: 16, weight: .semibold, design: .serif, relativeTo: .headline)
    }

    static func prayerFont() -> Font {
        scaledFont(size: 20, weight: .regular, design: .serif, relativeTo: .title3)
    }

    static func actionFont() -> Font {
        scaledFont(size: 16, weight: .bold, relativeTo: .headline)
    }
}

struct DevotionBackdrop: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.05, blue: 0.06),
                    Color(red: 0.11, green: 0.09, blue: 0.10),
                    Color(red: 0.08, green: 0.07, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [DevotionTheme.accent.opacity(0.20), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 260
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color.white.opacity(0.08), .clear],
                center: .bottomLeading,
                startRadius: 20,
                endRadius: 320
            )
            .ignoresSafeArea()
        }
    }
}

struct DevotionPanelModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [DevotionTheme.panelTop, DevotionTheme.panelBottom],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(DevotionTheme.panelBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 24, y: 14)
    }
}

extension View {
    func devotionPanel(cornerRadius: CGFloat = 30) -> some View {
        modifier(DevotionPanelModifier(cornerRadius: cornerRadius))
    }
}
