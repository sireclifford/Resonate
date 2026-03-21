import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme

    let environment: AppEnvironment
    @State private var showSupportMail = false
    @State private var showBugReport = false
    @State private var showSuggestion = false
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    @State private var showCredits = false
    @State private var showClearSuccess = false
    @State private var showClearDownloadedAudioConfirmation = false
    @ObservedObject private var settings: AppSettingsService
    @ObservedObject private var accompanimentCacheService: AccompanimentCacheService
    
    init(environment: AppEnvironment) {
        self.environment = environment
        _settings = ObservedObject(
            wrappedValue: environment.settingsService
        )
        _accompanimentCacheService = ObservedObject(
            wrappedValue: environment.accompanimentCacheService
        )
    }
    
    var body: some View {
        ZStack {
            PremiumScreenBackground()

            ScrollView {
                VStack(spacing: 16) {
                    appearanceSection
                    readerSection
                    audioSection
                    notificationsSection
                    librarySection
                    aboutSection
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Settings")
        .miniPlayerInset(using: environment)
        .alert("Cleared", isPresented: $showClearSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Recently viewed hymns have been cleared.")
        }
        .sheet(isPresented: $showSupportMail) {
            SupportMailView(subject: "Resonate Support Request")
        }
        .sheet(isPresented: $showBugReport) {
            SupportMailView(subject: "Bug Report - Resonate")
        }
        .sheet(isPresented: $showSuggestion) {
            SupportMailView(subject: "Hymn Suggestion - Resonate")
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            NavigationStack {
                LegalDocumentView.privacyPolicy
            }
        }
        .sheet(isPresented: $showTerms) {
            NavigationStack {
                LegalDocumentView.termsOfUse
            }
        }
        .sheet(isPresented: $showCredits) {
            NavigationStack {
                CreditsView()
            }
        }
        .sheet(isPresented: $showClearDownloadedAudioConfirmation) {
            VStack(spacing: 0) {
                Capsule()
                    .fill(PremiumTheme.border(for: colorScheme))
                    .frame(width: 42, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 18)

                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.12))
                            .frame(width: 60, height: 60)

                        Image(systemName: "trash.fill")
                            .font(PremiumTheme.scaledSystem(size: 24, weight: .semibold))
                            .foregroundStyle(.red)
                    }

                    VStack(spacing: 8) {
                        Text("Clear Downloaded Audio?")
                            .font(PremiumTheme.sectionTitleFont())
                            .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                            .multilineTextAlignment(.center)

                        Text("This will remove all downloaded accompaniments from your device. You can download them again anytime.")
                            .font(PremiumTheme.bodyFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal, 24)

                HStack(spacing: 12) {
                    Button {
                        showClearDownloadedAudioConfirmation = false
                    } label: {
                        Text("Cancel")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.plain)
                    .background(PremiumTheme.subtleFill(for: colorScheme))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    Button {
                        let result = environment.accompanimentCacheService.clearAll()
                        showClearDownloadedAudioConfirmation = false

                        if result.deletedFileCount > 0 {
                            environment.toastCenter.show(
                                .success(
                                    "Downloaded audio cleared",
                                    subtitle: "Removed \(result.deletedFileCount) file\(result.deletedFileCount == 1 ? "" : "s") and freed \(formattedStorageSize(result.reclaimedBytes))."
                                ),
                                position: .top
                            )
                        } else {
                            environment.toastCenter.show(
                                .info(
                                    "No downloaded audio found",
                                    subtitle: "There were no offline accompaniments to remove."
                                ),
                                position: .top
                            )
                        }
                    } label: {
                        Text("Clear")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .buttonStyle(.plain)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 18)
            }
            .presentationDetents([.height(270)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(28)
            .presentationBackground(.regularMaterial)
        }
    }
    
    private var appearanceSection: some View {
        SettingsSectionCard(
            title: "Appearance",
            icon: "circle.lefthalf.filled",
            subtitle: "Refine the visual tone of the app"
        ) {
            VStack(spacing: 12) {
                Menu {
                    ForEach(AppTheme.allCases) { theme in
                        Button {
                            settings.theme = theme
                        } label: {
                            HStack {
                                Text(theme.label)
                                if theme == settings.theme {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    settingsValueRow(
                        title: "Theme",
                        subtitle: "Choose how Resonate appears throughout the day",
                        value: settings.theme.label
                    )
                }
                .buttonStyle(.plain)

                settingsHighlight(
                    title: "Current Look",
                    detail: settings.theme.label,
                    icon: "sparkles"
                )
            }
        }
    }
    
    private var readerSection: some View {
        SettingsSectionCard(
            title: "Reader",
            icon: "textformat",
            subtitle: "Shape the hymn-reading experience"
        ) {
            VStack(spacing: 12) {
                settingsHighlight(
                    title: "Reading Profile",
                    detail: "\(settings.fontSize.label) • \(settings.fontFamily.label) • \(settings.lineSpacing.label)",
                    icon: "text.book.closed"
                )

                Menu {
                    ForEach(ReaderFontSize.allCases) { size in
                        Button {
                            settings.fontSize = size
                        } label: {
                            HStack {
                                Text(size.label)
                                if size == settings.fontSize {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    settingsValueRow(
                        title: "Font Size",
                        subtitle: "Adjust the main reading scale",
                        value: settings.fontSize.label
                    )
                }
                .buttonStyle(.plain)
                Menu {
                    ForEach(ReaderFontFamily.allCases) { family in
                        Button {
                            settings.fontFamily = family
                        } label: {
                            HStack {
                                Text(family.label)
                                if family == settings.fontFamily {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    settingsValueRow(
                        title: "Font Style",
                        subtitle: "Pick the typeface used in hymn detail",
                        value: settings.fontFamily.label
                    )
                }
                .buttonStyle(.plain)
                
                Menu {
                    ForEach(ReaderLineSpacing.allCases) { spacing in
                        Button {
                            settings.lineSpacing = spacing
                        } label: {
                            HStack {
                                Text(spacing.label)
                                if spacing == settings.lineSpacing {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    settingsValueRow(
                        title: "Line Spacing",
                        subtitle: "Open up or tighten the reading rhythm",
                        value: settings.lineSpacing.label
                    )
                }
                .buttonStyle(.plain)
                
                Menu {
                    ForEach(ChorusLabelStyle.allCases) { style in
                        Button {
                            settings.chorusLabelStyle = style
                        } label: {
                            HStack {
                                Text(style.label)
                                if style == settings.chorusLabelStyle {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    settingsValueRow(
                        title: "Chorus Label",
                        subtitle: "Choose how refrain sections are presented",
                        value: settings.chorusLabelStyle.label
                    )
                }
                .buttonStyle(.plain)
                
                settingsToggleRow(
                    title: "Show Verse Numbers",
                    subtitle: "Keep each stanza anchored while you read",
                    isOn: $settings.showVerseNumbers
                )
            }
        }
    }
    
    private var audioSection: some View {
        SettingsSectionCard(
            title: "Audio",
            icon: "speaker.wave.2",
            subtitle: "Control playback, downloads, and tactile feedback"
        ) {
            VStack(spacing: 12) {
                settingsToggleRow(
                    title: "Auto Download Accompaniments",
                    subtitle: "Keep tunes ready for offline playback",
                    isOn: $settings.autoDownloadAudio
                )

                settingsToggleRow(
                    title: "Allow Cellular Downloads",
                    subtitle: "Use mobile data when Wi-Fi is unavailable",
                    isOn: $settings.allowCellularDownload
                )

                settingsToggleRow(
                    title: "Stop Playback When Leaving Hymn",
                    subtitle: "End accompaniment when you leave the detail view",
                    isOn: $settings.stopPlaybackOnExit
                )
                
                settingsToggleRow(
                    title: "Enable Haptic Feedback",
                    subtitle: "Add a subtle tactile response to key interactions",
                    isOn: $settings.enableHaptics
                )
            }
        }
    }
    
    private var notificationsSection: some View {
        SettingsSectionCard(
            title: "Notifications",
            icon: "bell.badge.waveform",
            subtitle: "Stay in step with daily worship reminders"
        ) {
            VStack(spacing: 12) {
                settingsHighlight(
                    title: "Daily Hymn Reminder",
                    detail: environment.reminderSettingsViewModel.hotdEnabled ? "Scheduled" : "Off",
                    icon: "bell.and.waves.left.and.right"
                )

                settingsToggleRow(
                    title: "Enable Daily Hymn Reminder",
                    subtitle: "Receive a daily prompt to return to the hymn of the day",
                    isOn: Binding(
                        get: { environment.reminderSettingsViewModel.hotdEnabled },
                        set: { newValue in
                            if newValue {
                                Task {
                                    await environment.reminderSettingsViewModel.requestPermissionAndEnableHOTD()
                                }
                            } else {
                                Task {
                                    await environment.reminderSettingsViewModel.disableHOTD()
                                }
                            }
                        }
                    )
                )

                if environment.reminderSettingsViewModel.hotdEnabled {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Reminder Time")
                            .font(PremiumTheme.scaledSystem(size: 18, weight: .semibold, design: .serif))
                            .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                        Text("Choose when Resonate should surface the hymn of the day.")
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))

                        DatePicker(
                            "Reminder Time",
                            selection: Binding(
                                get: { environment.reminderSettingsViewModel.hotdTime },
                                set: { newValue in
                                    environment.reminderSettingsViewModel.hotdTime = newValue
                                }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(PremiumTheme.subtleFill(for: colorScheme))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                    )
                }
                #if DEBUG
                settingsValueRow(
                    title: "Notification Permission",
                    subtitle: "Current iOS authorization state",
                    value: permissionLabel(environment.reminderSettingsViewModel.authorizationStatus)
                )

                if environment.reminderSettingsViewModel.isSyncing {
                    ProgressView()
                }
                #endif
            }
            
            #if DEBUG
            VStack(spacing: 12) {
                settingsToggleRow(
                    title: "Sabbath Reminder",
                    subtitle: "Debug-only scheduling for Sabbath notifications",
                    isOn: Binding(
                        get: { environment.reminderSettingsViewModel.sabbathEnabled },
                        set: { newValue in
                            if newValue {
                                Task {
                                    await environment.reminderSettingsViewModel.requestPermissionAndEnableSabbath()
                                }
                            } else {
                                Task {
                                    await environment.reminderSettingsViewModel.disableSabbath()
                                }
                            }
                        }
                    )
                )

                if environment.reminderSettingsViewModel.sabbathEnabled {
                    settingsValueRow(
                        title: "Sabbath Reminder Time",
                        subtitle: "Current debug schedule",
                        value: timeString(environment.reminderSettingsViewModel.sabbathTime)
                    )
                }
            }
            #endif
        }
        .task {
            await environment.reminderSettingsViewModel.load()
        }
    }
    
    private var librarySection: some View {
        SettingsSectionCard(
            title: "Library",
            icon: "books.vertical",
            subtitle: "Manage saved activity and downloaded media"
        ) {
            VStack(spacing: 12) {
                settingsHighlight(
                    title: "Downloaded Audio",
                    detail: formattedStorageSize(accompanimentCacheService.totalStorageBytes),
                    icon: "internaldrive"
                )

                Button {
                    environment.recentlyViewedService.clear()
                    showClearSuccess = true
                } label: {
                    settingsRow(
                        title: "Clear Recently Viewed",
                        subtitle: "Remove hymn history from this device",
                        icon: "clock.arrow.circlepath"
                    )
                }

                Button(role: .destructive) {
                    showClearDownloadedAudioConfirmation = true
                } label: {
                    settingsRow(
                        title: "Clear Downloaded Audio",
                        subtitle: "Remove all offline accompaniments",
                        icon: "trash"
                    )
                }
            }
        }
    }
    
    private var buildConfigurationLabel: String {
    #if DEBUG
        return "Debug"
    #else
        return "Release"
    #endif
    }
    
    private var aboutSection: some View {
        SettingsSectionCard(title: "About", icon: "info.circle") {
            VStack(spacing: 18) {
                aboutHero
                aboutGroup {
                    Button { showSupportMail = true } label: {
                        settingsRow(title: "Contact Support", subtitle: "Get help or ask a question", icon: "envelope")
                    }
                    .buttonStyle(.plain)
                    Button { showBugReport = true } label: {
                        settingsRow(title: "Report a Bug", subtitle: "Help improve reliability", icon: "ladybug")
                    }
                    .buttonStyle(.plain)
                    Button { showSuggestion = true } label: {
                        settingsRow(title: "Request a Hymn", subtitle: "Suggest a hymn to add", icon: "music.note.list")
                    }
                    .buttonStyle(.plain)
                }
                aboutGroup {
                    Button { showPrivacyPolicy = true } label: {
                        settingsRow(title: "Privacy Policy", subtitle: "How Resonate handles data", icon: "hand.raised")
                    }
                    .buttonStyle(.plain)
                    Button { showTerms = true } label: {
                        settingsRow(title: "Terms of Use", subtitle: "Conditions for using the app", icon: "doc.text")
                    }
                    .buttonStyle(.plain)
                    Button { showCredits = true } label: {
                        settingsRow(title: "Credits", subtitle: "Attribution and acknowledgments", icon: "checkmark.seal")
                    }
                    .buttonStyle(.plain)
                }
                aboutGroup {
                    Button {
                        let activity = UIActivityViewController(
                            activityItems: [AppLinks.shareMessage, AppLinks.shareURL],
                            applicationActivities: nil
                        )
                        if let scene = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .first(where: { $0.activationState == .foregroundActive }),
                           let window = scene.keyWindow,
                           let root = window.rootViewController {
                            root.present(activity, animated: true)
                        }
                    } label: {
                        settingsRow(title: "Share Resonate", subtitle: "Invite others to discover it", icon: "square.and.arrow.up")
                    }
                    .buttonStyle(.plain)

                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            AppStore.requestReview(in: scene)
                        }
                    } label: {
                        settingsRow(title: "Rate Resonate", subtitle: "Support the launch with a review", icon: "star")
                    }
                    .buttonStyle(.plain)
                    
#if DEBUG
                    NavigationLink {
                        NotificationDebugView()
                            .environmentObject(environment)
                    } label: {
                        settingsRow(title: "Notification Debug", subtitle: "Inspect local reminder state", icon: "bell.badge")
                    }
                    .buttonStyle(.plain)
#endif
                }
            }
        }
    }

    private var aboutHero: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [PremiumTheme.accent(for: colorScheme).opacity(0.18), Color.orange.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 74, height: 74)

                Image(systemName: "music.quarternote.3")
                    .font(PremiumTheme.scaledSystem(size: 28, weight: .semibold))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
            }

            Text("Resonate")
                .font(PremiumTheme.sectionTitleFont())
                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

            Text("A refined hymn companion for worship, reflection, and story.")
                .font(PremiumTheme.bodyFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)

            Text(Bundle.main.appVersion)
                .font(PremiumTheme.captionFont())
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))

#if DEBUG
            Text(buildConfigurationLabel)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.12))
                .clipShape(Capsule())
#endif
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .premiumPanel(colorScheme: colorScheme, cornerRadius: 24)
    }

    private func aboutGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(PremiumTheme.subtleFill(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
        )
    }
    private func permissionLabel(_ status: NotificationAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        }
    }

    private func formattedStorageSize(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    private func settingsHighlight(title: String, detail: String, icon: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(PremiumTheme.subtleFill(for: colorScheme))
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
                    )

                Image(systemName: icon)
                    .foregroundStyle(PremiumTheme.accent(for: colorScheme))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(PremiumTheme.scaledSystem(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                Text(detail)
                    .font(PremiumTheme.bodyFont())
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(PremiumTheme.subtleFill(for: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(PremiumTheme.border(for: colorScheme), lineWidth: 1)
        )
    }

    private func settingsValueRow(title: String, subtitle: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(PremiumTheme.scaledSystem(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                Text(subtitle)
                    .font(PremiumTheme.captionFont())
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
            }

            Spacer()

            HStack(spacing: 8) {
                Text(value)
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme).opacity(0.7))
            }
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }

    private func settingsToggleRow(title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(PremiumTheme.scaledSystem(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                Text(subtitle)
                    .font(PremiumTheme.captionFont())
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 6)
    }

    private func settingsRow(title: String, subtitle: String? = nil, icon: String? = nil) -> some View {
        HStack {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                    .frame(width: 22)
            }

            VStack(alignment: .leading, spacing: subtitle == nil ? 0 : 2) {
                Text(title)
                    .font(PremiumTheme.scaledSystem(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))
                if let subtitle {
                    Text(subtitle)
                        .font(PremiumTheme.captionFont())
                        .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 12)
    }
}

 
