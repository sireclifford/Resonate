import SwiftUI

struct SettingsView: View {
    
    let environment: AppEnvironment
    @State private var showSupportMail = false
    @State private var showBugReport = false
    @State private var showSuggestion = false
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    @State private var showCredits = false
    @State private var showClearSuccess = false
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
            VStack(spacing: 8) {
                Toggle("Daily Hymn Reminder",
                       isOn: $settings.dailyReminderEnabled)
                
                DatePicker(
                    "Reminder Time",
                    selection: $settings.dailyReminderTime,
                    displayedComponents: .hourAndMinute
                )
                .disabled(!settings.dailyReminderEnabled)
            }
        }
        .onChange(of: settings.dailyReminderEnabled) { _, enabled in
            if enabled {
                environment.notificationService.requestPermission()
                
                if let hymn = environment.hymnService.hymnOfTheDay() {
                    environment.notificationService.scheduleSmartDailyReminder(
                        reminderTime: settings.dailyReminderTime,
                        hymn: hymn,
                        engagementService: environment.hymnOfTheDayEngagementService
                    )
                }
            } else {
                environment.notificationService.cancelReminder()
            }
        }
        .onChange(of: settings.dailyReminderTime) { _, newTime in
            guard settings.dailyReminderEnabled,
                  let hymn = environment.hymnService.hymnOfTheDay() else { return }
            environment.notificationService.scheduleSmartDailyReminder(
                reminderTime: newTime,
                hymn: hymn,
                engagementService: environment.hymnOfTheDayEngagementService
                )
        }
    }
    
    private var librarySection: some View {
        SettingsSectionCard(title: "Library", icon: "books.vertical") {
            VStack(spacing: 12) {
                Button("Clear Recently Viewed") {
                    environment.recentlyViewedService.clear()
                    showClearSuccess = true
                }
                
                Divider()
                
                Button(role: .destructive) {
                    environment.audioPlaybackService.stop()
                } label: {
                    Text("Stop Playback")
                }
            }
        }
    }
    
    private var aboutSection: some View {
        SettingsSectionCard(title: "About", icon: "info.circle") {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Resonate")
                        .font(.headline)
                    
                    Text("Seventh-day Adventist Hymnal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
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
                        settingsRow(title: "Suggest a Hymn")
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
                }
            }
        }
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
