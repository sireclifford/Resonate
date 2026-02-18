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
                
                //MARK: Appearance
                SettingsSectionCard(title: "Appearance", icon: "circle.lefthalf.filled") {

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
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // MARK: Reader
                SettingsSectionCard(title: "Reader", icon: "textformat") {
                    
                    VStack(spacing: 12) {
                        //Font Style
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
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        //Line Spacing
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
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        //Chorus/Refrain/Hidden
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
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        //Show verse numbers
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
