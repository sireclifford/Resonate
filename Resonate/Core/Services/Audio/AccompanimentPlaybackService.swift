import AVFoundation
import Foundation
import Combine
import MediaPlayer
import Network

final class AccompanimentPlaybackService: NSObject, ObservableObject {

    enum FileState: Equatable {
        case remoteOnly
        case downloading
        case downloaded
        case unavailable
        case failed(message: String)
    }

    enum PlaybackState: Equatable {
        case idle
        case loading
        case playing
        case paused
        case failed(message: String)
    }

    @Published private(set) var state: PlaybackState = .idle
    @Published private(set) var currentHymnID: Int?
    @Published private(set) var downloadingHymnID: Int?
    @Published private(set) var failedHymnID: Int?
    @Published private(set) var lastFileErrorMessage: String?
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    var isPlaying: Bool {
        state == .playing
    }

    var isLoading: Bool {
        state == .loading
    }

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    func isDownloaded(for hymnID: Int) -> Bool {
        cacheService.isDownloaded(for: hymnID)
    }

    func fileState(for hymnID: Int) -> FileState {
        if cacheService.isDownloaded(for: hymnID) {
            return .downloaded
        }

        if downloadingHymnID == hymnID {
            return .downloading
        }

        if let cachedAvailability = storageService.cachedAvailability(for: hymnID), cachedAvailability == false {
            return .failed(message: "Accompaniment unavailable. Try again later.")
        }

        if failedHymnID == hymnID, let lastFileErrorMessage {
            return .failed(message: lastFileErrorMessage)
        }

        return .remoteOnly
    }

    private var player: AVAudioPlayer?
    private var progressTimer: Timer?

    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "AccompanimentPlaybackService.PathMonitor")
    private var currentNetworkPath: NWPath?

    private let storageService: AccompanimentStorageService
    private let cacheService: AccompanimentCacheService
    private let settings: AppSettingsService
    private let analyticsService: AnalyticsService
    private let hymnTitleProvider: (Int) -> String

    init(
        storageService: AccompanimentStorageService,
        cacheService: AccompanimentCacheService,
        settings: AppSettingsService,
        analyticsService: AnalyticsService,
        hymnTitleProvider: @escaping (Int) -> String
    ) {
        self.storageService = storageService
        self.cacheService = cacheService
        self.settings = settings
        self.analyticsService = analyticsService
        self.hymnTitleProvider = hymnTitleProvider
        super.init()
        configureRemoteCommands()
        startNetworkMonitoring()
    }

    func togglePlayback(for hymnID: Int) {
        if currentHymnID == hymnID {
            switch state {
            case .playing:
                pause()
            case .paused:
                resume()
            case .loading:
                return
            case .idle, .failed:
                Task {
                    await play(for: hymnID)
                }
            }
            return
        }

        Task {
            await play(for: hymnID)
        }
    }

    func toggleWorshipFlowPlayback(for hymnID: Int) {
        if currentHymnID == hymnID {
            switch state {
            case .playing:
                pause()
            case .paused:
                resume()
            case .loading:
                return
            case .idle, .failed:
                Task {
                    await playForWorshipFlow(for: hymnID)
                }
            }
            return
        }

        Task {
            await playForWorshipFlow(for: hymnID)
        }
    }

    @MainActor
    func playForWorshipFlow(for hymnID: Int) async {
        await play(for: hymnID, allowAutomaticDownload: true)

        if state == .playing, currentHymnID == hymnID {
            analyticsService.log(.worshipAudioStarted, parameters: [
                .hymnID: hymnID
            ])
        }
    }

    @MainActor
    func play(for hymnID: Int) async {
        await play(for: hymnID, allowAutomaticDownload: settings.autoDownloadAudio)
    }

    @MainActor
    private func play(for hymnID: Int, allowAutomaticDownload: Bool) async {
        stop()
        currentHymnID = hymnID
        state = .loading
        downloadingHymnID = nil
        failedHymnID = nil
        lastFileErrorMessage = nil

        do {
            let localURL: URL

            if cacheService.isDownloaded(for: hymnID) {
                localURL = cacheService.localURL(for: hymnID)
            } else {
                guard allowAutomaticDownload else {
                    throw NSError(
                        domain: "AccompanimentPlaybackService",
                        code: 1000,
                        userInfo: [NSLocalizedDescriptionKey: "Auto-download is turned off in Settings. Download this accompaniment first to play it."]
                    )
                }

                guard canUseNetworkForAudioDownload else {
                    throw NSError(
                        domain: "AccompanimentPlaybackService",
                        code: 1001,
                        userInfo: [NSLocalizedDescriptionKey: "Cellular downloads are disabled in Settings."]
                    )
                }

                downloadingHymnID = hymnID
                analyticsService.log(.accompanimentDownloadStarted, parameters: [
                    .hymnID: hymnID
                ])

                let remoteURL = try await storageService.fetchDownloadURL(for: hymnID)
                let (data, _) = try await URLSession.shared.data(from: remoteURL)
                localURL = try cacheService.save(data: data, for: hymnID)

                analyticsService.log(.accompanimentDownloadCompleted, parameters: [
                    .hymnID: hymnID
                ])
                downloadingHymnID = nil
            }

            try configureAudioSession()

            let player = try AVAudioPlayer(contentsOf: localURL)
            player.delegate = self
            player.numberOfLoops = -1
            player.volume = 0.0
            player.prepareToPlay()
            player.play()
            player.setVolume(0.18, fadeDuration: 1.8)

            self.player = player
            duration = player.duration
            currentTime = player.currentTime
            startProgressTimer()
            state = .playing
            updateNowPlayingInfo(for: hymnID, isPlaying: true)

            analyticsService.hymnAudioPlayed(id: hymnID)

                Haptics.light()
            
        } catch {
            stopProgressTimer()
            currentTime = 0
            duration = 0

            if downloadingHymnID == hymnID {
                analyticsService.log(.accompanimentDownloadFailed, parameters: [
                    .hymnID: hymnID
                ])
            }

            downloadingHymnID = nil
            failedHymnID = hymnID

            if let cachedAvailability = storageService.cachedAvailability(for: hymnID), cachedAvailability == false {
                let message = "Accompaniment unavailable. Try again later."
                lastFileErrorMessage = message
                state = .failed(message: message)
            } else {
                lastFileErrorMessage = error.localizedDescription
                state = .failed(message: error.localizedDescription)
            }

            currentHymnID = nil
        }
    }

    @MainActor
    func download(for hymnID: Int) async {
        guard !cacheService.isDownloaded(for: hymnID) else { return }

        downloadingHymnID = hymnID
        failedHymnID = nil
        lastFileErrorMessage = nil

        guard canUseNetworkForAudioDownload else {
            downloadingHymnID = nil
            failedHymnID = hymnID
            lastFileErrorMessage = "Cellular downloads are disabled in Settings."
            return
        }

        do {
            analyticsService.log(.accompanimentDownloadStarted, parameters: [
                .hymnID: hymnID
            ])

            let remoteURL = try await storageService.fetchDownloadURL(for: hymnID)
            let (data, _) = try await URLSession.shared.data(from: remoteURL)
            _ = try cacheService.save(data: data, for: hymnID)

            analyticsService.log(.accompanimentDownloadCompleted, parameters: [
                .hymnID: hymnID
            ])
            downloadingHymnID = nil
        } catch {
            analyticsService.log(.accompanimentDownloadFailed, parameters: [
                .hymnID: hymnID
            ])
            downloadingHymnID = nil
            failedHymnID = hymnID

            if let cachedAvailability = storageService.cachedAvailability(for: hymnID), cachedAvailability == false {
                lastFileErrorMessage = "Accompaniment unavailable. Try again later."
            } else {
                lastFileErrorMessage = error.localizedDescription
            }
        }
    }

    func deleteDownload(for hymnID: Int) {
        if currentHymnID == hymnID {
            stop()
        }

        cacheService.delete(for: hymnID)

        if failedHymnID == hymnID {
            failedHymnID = nil
            lastFileErrorMessage = nil
        }
    }


    deinit {
        pathMonitor.cancel()
    }

    func fadeOutAndStop(duration: TimeInterval = 1.6) {
        guard let player else {
            stop()
            return
        }

        stopProgressTimer()
        player.setVolume(0.0, fadeDuration: duration)
        state = .idle

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.stop()
        }
    }

    func pause() {
        guard let player else { return }
        player.setVolume(0.0, fadeDuration: 0.8)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self else { return }
            self.player?.pause()
            self.stopProgressTimer()
            self.state = .paused
            if let hymnID = self.currentHymnID {
                self.analyticsService.log(.hymnAudioPaused, parameters: [
                    .hymnID: hymnID
                ])
                self.updateNowPlayingInfo(for: hymnID, isPlaying: false)
            }
        }
    }

    func resume() {
        player?.play()
        player?.setVolume(0.18, fadeDuration: 1.2)
        startProgressTimer()
        state = .playing
        if let hymnID = currentHymnID {
            updateNowPlayingInfo(for: hymnID, isPlaying: true)
        }
    }

    func stop() {
        let stoppedHymnID = currentHymnID

        player?.stop()
        stopProgressTimer()
        currentTime = 0
        duration = 0
        player = nil
        downloadingHymnID = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        currentHymnID = nil
        state = .idle

        if let stoppedHymnID {
            analyticsService.log(.hymnAudioStopped, parameters: [
                .hymnID: stoppedHymnID
            ])
        }
    }

    private var canUseNetworkForAudioDownload: Bool {
        guard let path = currentNetworkPath else {
            return settings.allowCellularDownload
        }

        if path.usesInterfaceType(.cellular) {
            return settings.allowCellularDownload
        }

        return true
    }

    private func startNetworkMonitoring() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            self?.currentNetworkPath = path
        }
        pathMonitor.start(queue: monitorQueue)
    }

    private func startProgressTimer() {
        stopProgressTimer()

        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self, let player else { return }

            DispatchQueue.main.async {
                self.currentTime = player.currentTime
                self.duration = player.duration

                if let hymnID = self.currentHymnID {
                    self.updateNowPlayingInfo(for: hymnID, isPlaying: self.state == .playing)
                }
            }
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true

        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
    }

    private func updateNowPlayingInfo(for hymnID: Int, isPlaying: Bool) {
        let title = hymnTitleProvider(hymnID)

        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: "Resonate",
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback)
        try session.setActive(true)
    }
}

extension AccompanimentPlaybackService: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            let completedHymnID = self.currentHymnID

            self.stopProgressTimer()
            self.currentTime = 0
            self.duration = 0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            self.state = .idle
            self.currentHymnID = nil

            if let completedHymnID {
                self.analyticsService.log(.hymnAudioCompleted, parameters: [
                    .hymnID: completedHymnID
                ])
            }
        }
    }
}
