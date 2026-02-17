import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var environment: AppEnvironment

    var body: some View {
        
        ScrollView {
            VStack(spacing: 24) {

                // MARK: Reader
                SettingsSectionCard(title: "Reader", icon: "textformat") {

                    VStack(spacing: 12) {

                        Picker("Font Size", selection: $environment.settingsService.fontSize) {
                            ForEach(ReaderFontSize.allCases, id: \.self) {
                                Text($0.rawValue.capitalized)
                            }
                        }

                        Toggle("Show Verse Numbers",
                               isOn: $environment.settingsService.showVerseNumbers)
                    }
                }

                // MARK: Audio
                SettingsSectionCard(title: "Audio", icon: "speaker.wave.2") {

                    VStack(spacing: 12) {

                        Toggle("Auto Download Audio",
                               isOn: $environment.settingsService.autoDownloadAudio)

                        Toggle("Allow Cellular Downloads",
                               isOn: $environment.settingsService.allowCellularDownload)
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

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Resonate")
                            .font(.headline)

                        Text("Version 1.0.0")
                            .foregroundColor(.secondary)
                    }
                }

            }
            .padding()
        }
        .navigationTitle("Settings")
    }
}
