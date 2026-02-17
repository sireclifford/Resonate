import SwiftUI

struct SettingsView: View {

    let environment: AppEnvironment
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
