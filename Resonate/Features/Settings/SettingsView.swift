import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    
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
    
    init(environment: AppEnvironment) {
        self.environment = environment
        _settings = ObservedObject(
            wrappedValue: environment.settingsService
        )
    }
    
    var body: some View {
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
        .background(
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("Settings")
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
            WebView(url: URL(string: "https://sireclifford.github.io/Resonate/")!)
        }
        .sheet(isPresented: $showTerms) {
            WebView(url: URL(string: "https://sireclifford.github.io/Resonate/")!)
        }
        .sheet(isPresented: $showCredits) {
            NavigationStack {
                CreditsView()
            }
        }
        .sheet(isPresented: $showClearDownloadedAudioConfirmation) {
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color.secondary.opacity(0.22))
                    .frame(width: 42, height: 5)
                    .padding(.top, 10)
                    .padding(.bottom, 18)

                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.12))
                            .frame(width: 60, height: 60)

                        Image(systemName: "trash.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.red)
                    }

                    VStack(spacing: 8) {
                        Text("Clear Downloaded Audio?")
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)

                        Text("This will remove all downloaded accompaniments from your device. You can download them again anytime.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    Button {
                        environment.accompanimentCacheService.clearAll()
                        showClearDownloadedAudioConfirmation = false
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
        SettingsSectionCard(title: "Appearance", icon: "circle.lefthalf.filled") {
            Text("Customize the app look and feel")
                .font(.caption)
                .foregroundColor(.secondary)
            
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
                    HStack {
                        Text("Theme")
                        Spacer()
                        Text(settings.theme.label)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
            }
        }
    }
    
    private var readerSection: some View {
        SettingsSectionCard(title: "Reader", icon: "textformat") {
            VStack(spacing: 12) {
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
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text(settings.fontSize.label)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
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
                    HStack {
                        Text("Font Style")
                        Spacer()
                        Text(settings.fontFamily.label)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
                
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
                    HStack {
                        Text("Line Spacing")
                        Spacer()
                        Text(settings.lineSpacing.label)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
                
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
                    HStack {
                        Text("Chorus Label")
                        Spacer()
                        Text(settings.chorusLabelStyle.label)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
                
                Toggle("Show Verse Numbers",
                       isOn: $settings.showVerseNumbers)
            }
        }
    }
    
    private var audioSection: some View {
        SettingsSectionCard(title: "Audio", icon: "speaker.wave.2") {
            VStack(spacing: 8) {
                Toggle(
                    "Auto Download Accompaniments",
                    isOn: $settings.autoDownloadAudio
                )

                Toggle(
                    "Allow Cellular Downloads",
                    isOn: $settings.allowCellularDownload
                )

                Toggle(
                    "Stop Playback When Leaving Hymn",
                    isOn: $settings.stopPlaybackOnExit
                )
                
                Toggle(
                    "Enable Haptic Feedback",
                    isOn: $settings.enableHaptics
                )
            }
        }
    }
    
    private var notificationsSection: some View {
        SettingsSectionCard(title: "Notifications", icon: "bell.badge.waveform") {
            VStack(spacing: 12) {
                Toggle("Daily Hymn Reminder", isOn: Binding(
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
                ))

                if environment.reminderSettingsViewModel.hotdEnabled {
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
                }
                #if DEBUG
                HStack {
                    Text("Notification Permission")
                    Spacer()
                    Text(permissionLabel(environment.reminderSettingsViewModel.authorizationStatus))
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }

                if environment.reminderSettingsViewModel.isSyncing {
                    ProgressView()
                }
                #endif
            }
            VStack(spacing: 12) {
                Toggle("Sabbath Reminder", isOn: Binding(
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
                ))

                if environment.reminderSettingsViewModel.sabbathEnabled {
                    DatePicker(
                        "Sabbath Reminder Time",
                        selection: Binding(
                            get: { environment.reminderSettingsViewModel.sabbathTime },
                            set: { newValue in
                                environment.reminderSettingsViewModel.sabbathTime = newValue
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
            }
        }
        .task {
            await environment.reminderSettingsViewModel.load()
        }
    }
    
    private var librarySection: some View {
        SettingsSectionCard(title: "Library", icon: "books.vertical") {
            VStack(spacing: 12) {
                HStack {
                    Text("Downloaded Audio")
                    Spacer()
                    Text(formattedStorageSize(environment.accompanimentCacheService.totalStorageSize()))
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }

                Button("Clear Recently Viewed") {
                    environment.recentlyViewedService.clear()
                    showClearSuccess = true
                }

                Divider()

                Button(role: .destructive) {
                    showClearDownloadedAudioConfirmation = true
                } label: {
                    Text("Clear Downloaded Audio")
                }

                Divider()
            }
        }
    }
    
    private var aboutSection: some View {
        SettingsSectionCard(title: "About", icon: "info.circle") {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Resonate")
                        .font(.headline)
                    
                    Text("Resonate – Digital Hymnal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("A digital house of worship through hymns, reflection, and story.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.appVersion)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
                
                Divider()
                
                VStack(spacing: 12) {
                    Button { showSupportMail = true } label: {
                        settingsRow(title: "Contact Support")
                    }
                    
                    Button { showBugReport = true } label: {
                        settingsRow(title: "Report a Bug")
                    }
                    
                    Button { showSuggestion = true } label: {
                        settingsRow(title: "Request a Hymn")
                    }
                }
                
                Divider()
                
                VStack(spacing: 12) {
                    Button { showPrivacyPolicy = true } label: {
                        settingsRow(title: "Privacy Policy")
                    }
                    
                    Button { showTerms = true } label: {
                        settingsRow(title: "Terms of Use")
                    }
                    
                    Button { showCredits = true } label: {
                        settingsRow(title: "Credits")
                    }

                    Divider()

                    Button {
                        let url = URL(string: "https://apps.apple.com")!
                        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        if let scene = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .first(where: { $0.activationState == .foregroundActive }),
                           let window = scene.keyWindow,
                           let root = window.rootViewController {
                            root.present(activity, animated: true)
                        }
                    } label: {
                        settingsRow(title: "Share Resonate")
                    }

                    Button {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            AppStore.requestReview(in: scene)
                        }
                    } label: {
                        settingsRow(title: "Rate Resonate")
                    }
                    
#if DEBUG
                    NavigationLink {
                        NotificationDebugView()
                            .environmentObject(environment)
                    } label: {
                        settingsRow(title: "Notification Debug")
                    }
#endif
                }
            }
        }
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

    private func settingsRow(title: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
    }
}

 
