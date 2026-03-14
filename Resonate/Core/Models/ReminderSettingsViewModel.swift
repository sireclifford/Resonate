import Foundation
import Combine

@MainActor
final class ReminderSettingsViewModel: ObservableObject {
    @Published var hotdEnabled: Bool
    @Published var hotdTime: Date
    @Published private(set) var authorizationStatus: NotificationAuthorizationStatus = .notDetermined
    @Published private(set) var isSyncing = false
    @Published var sabbathEnabled: Bool
    @Published var sabbathTime: Date

    private let settings: AppSettingsService
    private let hymnService: HymnService
    private let engagementService: HymnOfTheDayEngagementService
    private let authorizationManager: NotificationAuthorizationManaging
    private let scheduler: ReminderScheduling
    private let dateProvider: DateProviding

    private var cancellables = Set<AnyCancellable>()

    init(
        settings: AppSettingsService,
        hymnService: HymnService,
        engagementService: HymnOfTheDayEngagementService,
        authorizationManager: NotificationAuthorizationManaging,
        scheduler: ReminderScheduling,
        dateProvider: DateProviding
    ) {
        self.settings = settings
        self.hymnService = hymnService
        self.engagementService = engagementService
        self.authorizationManager = authorizationManager
        self.scheduler = scheduler
        self.dateProvider = dateProvider

        self.hotdEnabled = settings.dailyReminderEnabled
        self.hotdTime = settings.dailyReminderTime
        
        self.sabbathEnabled = settings.sabbathReminderEnabled
        self.sabbathTime = settings.sabbathReminderTime

        bind()
    }

    private func bind() {
        $hotdEnabled
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] enabled in
                guard let self else { return }
                self.settings.dailyReminderEnabled = enabled
                Task { await self.syncHOTD() }
            }
            .store(in: &cancellables)

        $hotdTime
            .dropFirst()
            .sink { [weak self] time in
                guard let self else { return }
                self.settings.dailyReminderTime = time
                Task { await self.syncHOTD() }
            }
            .store(in: &cancellables)

        hymnService.$currentHymnOfTheDay
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.syncHOTD() }
            }
            .store(in: &cancellables)
        
        $sabbathEnabled
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] enabled in
                guard let self else { return }
                self.settings.sabbathReminderEnabled = enabled
                Task { await self.syncSabbath() }
            }
            .store(in: &cancellables)

        $sabbathTime
            .dropFirst()
            .sink { [weak self] time in
                guard let self else { return }
                self.settings.sabbathReminderTime = time
                Task { await self.syncSabbath() }
            }
            .store(in: &cancellables)
    }

    func load() async {
        authorizationStatus = await authorizationManager.currentStatus()
        await syncHOTD()
        await syncSabbath()
    }

    func requestPermissionAndEnableHOTD() async {
        do {
            let status = try await authorizationManager.requestAuthorization()
            authorizationStatus = status

            if status.isAllowedToSchedule {
                hotdEnabled = true
                await syncHOTD()
            } else {
                hotdEnabled = false
            }
        } catch {
            hotdEnabled = false
        }
    }
    
    func requestPermissionAndEnableSabbath() async {
        do {
            let status = try await authorizationManager.requestAuthorization()
            authorizationStatus = status

            if status.isAllowedToSchedule {
                sabbathEnabled = true
                await syncSabbath()
            } else {
                sabbathEnabled = false
            }
        } catch {
            sabbathEnabled = false
        }
    }

    func disableSabbath() async {
        sabbathEnabled = false
        await scheduler.cancel(identifier: .sabbathPrimary())
    }

    private func syncSabbath() async {
        authorizationStatus = await authorizationManager.currentStatus()

        let context = ReminderContext(
            now: dateProvider.now,
            hotdEnabled: settings.dailyReminderEnabled,
            hotdTime: settings.dailyReminderTime,
            hotdHymnID: nil,
            hotdTitle: nil,
            hotdOpenedToday: false,
            sabbathEnabled: settings.sabbathReminderEnabled,
            sabbathTime: settings.sabbathReminderTime,
            authorizationGranted: authorizationStatus.isAllowedToSchedule
        )

        await scheduler.syncSabbath(context: context)
    }

    func disableHOTD() async {
        hotdEnabled = false
        await scheduler.cancel(identifier: .hotdPrimary)
    }

    func onAppBecameActive() async {
        authorizationStatus = await authorizationManager.currentStatus()
        await syncHOTD()
        await syncSabbath()
    }

    private func syncHOTD() async {
        isSyncing = true
        defer { isSyncing = false }

        authorizationStatus = await authorizationManager.currentStatus()

        // Use current HOTD if already loaded, otherwise ask the service for today's hymn
        let hymn = hymnService.currentHymnOfTheDay ?? hymnService.hymnOfTheDay()
        
        let openedToday: Bool
        if let hymn {
            openedToday = engagementService.hasOpenedToday(hymnID: hymn.id)
        } else {
            openedToday = false
        }
        
        let context = ReminderContext(
            now: dateProvider.now,
            hotdEnabled: settings.dailyReminderEnabled,
            hotdTime: settings.dailyReminderTime,
            hotdHymnID: hymn?.id,
            hotdTitle: hymn?.title,
            hotdOpenedToday: openedToday,
            sabbathEnabled: false,
            sabbathTime: nil,
            authorizationGranted: authorizationStatus.isAllowedToSchedule
        )
        await scheduler.syncHOTD(context: context)
    }
}
