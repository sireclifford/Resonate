import SwiftUI

struct SettingsView: View {

    let environment: AppEnvironment
    @State private var showSupportMail = false
    @State private var showBugReport = false
    @State private var showSuggestion = false
    @State private var showPrivacyPolicy = false
    @State private var showTerms = false
    @State private var showCredits = false
    @ObservedObject private var settings: AppSettingsService

    init(environment: AppEnvironment) {
        self.environment = environment
        _settings = ObservedObject(
            wrappedValue: environment.settingsService
        )
    }

    var body: some View {

        ScrollView {
            VStack(spacing: 24) {

                // MARK: Reader
                SettingsSectionCard(title: "Reader", icon: "textformat") {

                    VStack(spacing: 12) {

                        // Font Size
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
                                    .foregroundColor(.secondary)
                            }
                        }

                        Toggle(
                            "Show Verse Numbers",
                            isOn: $settings.showVerseNumbers
                        )
                    }
                }

                // MARK: Audio
                SettingsSectionCard(title: "Audio", icon: "speaker.wave.2") {

                    VStack(spacing: 12) {

                        Toggle(
                            "Auto Download Audio",
                            isOn: $settings.autoDownloadAudio
                        )

                        Toggle(
                            "Allow Cellular Downloads",
                            isOn: $settings.allowCellularDownload
                        )
                    }
                }

                // MARK: Library
                SettingsSectionCard(title: "Library", icon: "books.vertical") {

                    VStack(spacing: 12) {

                        Button("Clear Recently Viewed") {
                            environment.recentlyViewedService.clear()
                        }

                        Button(role: .destructive) {
                            environment.audioPlaybackService.stop()
                        } label: {
                            Text("Stop Playback")
                        }
                    }
                }

                // MARK: About
                SettingsSectionCard(title: "About", icon: "info.circle") {

                    VStack(alignment: .leading, spacing: 16) {

                        // MARK: App Identity
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Resonate")
                                .font(.headline)

                            Text("Seventh-day Adventist Hymnal")
                                .foregroundColor(.secondary)

                            Text(Bundle.main.appVersion)
                                .foregroundColor(.secondary)
                        }

                        Divider()

                        // MARK: Developer
                        VStack(alignment: .leading, spacing: 8) {

                            Text("Built by Clifford Owusu")
                                .foregroundColor(.secondary)

                            Text("House of Praise (Organization Placeholder)")
                                .foregroundColor(.secondary)

                            Button {
                                showSupportMail = true
                            } label: {
                                HStack {
                                    Text("Contact Support")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }

                            Button {
                                showBugReport = true
                            } label: {
                                HStack {
                                    Text("Report a Bug")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }

                            Button {
                                showSuggestion = true
                            } label: {
                                HStack {
                                    Text("Suggest a Hymn")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Divider()

                        // MARK: Legal
                        VStack(alignment: .leading, spacing: 8) {

                            Button {
                                showPrivacyPolicy = true
                            } label: {
                                HStack {
                                    Text("Privacy Policy")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }

                            Button {
                                showTerms = true
                            } label: {
                                HStack {
                                    Text("Terms of Use")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Divider()

                        // MARK: Credits
                        VStack(alignment: .leading, spacing: 8) {

                            Button {
                                showCredits = true
                            } label: {
                                HStack {
                                    Text("Credits")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
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
                    WebView(url: URL(string: "https://your-privacy-url.com")!)
                }

                .sheet(isPresented: $showTerms) {
                    WebView(url: URL(string: "https://your-terms-url.com")!)
                }

                .sheet(isPresented: $showCredits) {
                    NavigationStack {
                        CreditsView()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Settings")
    }
}
