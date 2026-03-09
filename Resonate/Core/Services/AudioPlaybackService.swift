import AVFoundation
import Combine

final class AudioPlaybackService: NSObject, ObservableObject {
    
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentHymnID: Int?
    private var player: AVAudioPlayer?
    
    private let settings: AppSettingsService
    private let analyticsService: AnalyticsService
    
    init(settings: AppSettingsService, analyticsService: AnalyticsService) {
        self.settings = settings
        self.analyticsService = analyticsService
    }
    
    func togglePlayback(for id: Int, tuneService: TuneService) {
        if currentHymnID == id {
            if isPlaying {
                pause()
            } else {
                resume()
            }
            return
        }

        play(for: id, tuneService: tuneService)
    }

    func play(for id: Int, tuneService: TuneService) {
        if currentHymnID == id, player != nil {
            if !isPlaying {
                player?.setVolume(0.18, fadeDuration: 1.2)
                player?.play()
                isPlaying = true
            }
            return
        }

        stop()

        guard let url = tuneService.tuneURL(for: id) else {
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback)
            try session.setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.numberOfLoops = -1
            player?.volume = 0.0
            player?.prepareToPlay()
            player?.play()
            player?.setVolume(0.18, fadeDuration: 1.8)

            currentHymnID = id
            isPlaying = true

            analyticsService.hymnAudioPlayed(id: id)

            if settings.enableHaptics {
                Haptics.light()
            }
        } catch {
        }
    }

    func fadeOutAndStop(duration: TimeInterval = 1.6) {
        guard let player else {
            stop()
            return
        }

        player.setVolume(0.0, fadeDuration: duration)
        isPlaying = false

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self else { return }
            self.stop()
        }
    }

    func pause() {
        guard let player else { return }
        player.setVolume(0.0, fadeDuration: 0.8)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            self.player?.pause()
            self.isPlaying = false
        }
    }

    func resume() {
        player?.play()
        player?.setVolume(0.18, fadeDuration: 1.2)
        isPlaying = true
    }
    
    func stop() {
        player?.stop()
        player = nil
        currentHymnID = nil
        isPlaying = false
    }
}

extension AudioPlaybackService: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
}
