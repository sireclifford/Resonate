import SwiftUI

struct LegalDocumentView: View {
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let lastUpdated: String
    let sections: [LegalSection]

    var body: some View {
        ZStack {
            PremiumScreenBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(title)
                            .font(PremiumTheme.titleFont(size: 30))
                            .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                        Text("Last updated \(lastUpdated)")
                            .font(PremiumTheme.captionFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))

                        Text(introText)
                            .font(PremiumTheme.bodyFont())
                            .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(22)
                    .premiumPanel(colorScheme: colorScheme, cornerRadius: 24)

                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(section.title)
                                .font(PremiumTheme.scaledSystem(size: 24, weight: .semibold, design: .serif))
                                .foregroundStyle(PremiumTheme.primaryText(for: colorScheme))

                            Text(section.body)
                                .font(PremiumTheme.bodyFont())
                                .foregroundStyle(PremiumTheme.secondaryText(for: colorScheme))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .premiumPanel(colorScheme: colorScheme, cornerRadius: 20)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var introText: String {
        "These terms explain how Resonate handles your information and how the app may be used."
    }
}

struct LegalSection: Identifiable {
    let id = UUID()
    let title: String
    let body: String
}

extension LegalDocumentView {
    static let privacyPolicy = LegalDocumentView(
        title: "Privacy Policy",
        lastUpdated: "March 2026",
        sections: [
            LegalSection(
                title: "Overview",
                body: "Resonate is designed to provide hymn reading, reflection, and companion features with minimal data collection. We aim to collect only what is necessary to operate and improve the app."
            ),
            LegalSection(
                title: "Information Stored On Device",
                body: "Your settings, favourites, recent activity, reminder preferences, and downloaded audio are stored locally on your device so the app can remember your preferences and provide offline functionality."
            ),
            LegalSection(
                title: "Analytics",
                body: "Resonate may collect limited usage analytics, such as feature interactions, screen visits, and general engagement events, to help improve reliability and usability. We do not use analytics to sell personal data."
            ),
            LegalSection(
                title: "Third-Party Services",
                body: "Some features may rely on third-party services such as YouVersion for Bible content, Apple services for in-app ratings and notifications, and other platform services required for app functionality. Those services operate under their own terms and privacy policies."
            ),
            LegalSection(
                title: "Contact",
                body: "If you have questions about privacy or data handling in Resonate, use the support options provided in the Settings screen."
            )
        ]
    )

    static let termsOfUse = LegalDocumentView(
        title: "Terms of Use",
        lastUpdated: "March 2026",
        sections: [
            LegalSection(
                title: "Use of the App",
                body: "Resonate is provided as a digital hymn companion for worship, reading, and reflection. You may use the app for personal, non-commercial purposes in accordance with applicable laws and platform policies."
            ),
            LegalSection(
                title: "Content and Attribution",
                body: "Hymn texts, tune information, historical references, and related materials remain the property of their respective copyright holders where applicable. Resonate presents content with attribution and does not claim ownership over third-party materials."
            ),
            LegalSection(
                title: "Availability",
                body: "We may update, refine, or remove features over time to improve the app. We do not guarantee uninterrupted availability of every service, integration, or linked resource."
            ),
            LegalSection(
                title: "Disclaimer",
                body: "Resonate is an independent project and is not officially affiliated with the General Conference of Seventh-day Adventists. The app is provided in good faith, but without warranties of any kind regarding completeness, accuracy, or uninterrupted operation."
            ),
            LegalSection(
                title: "Contact",
                body: "Questions, bug reports, and hymn requests can be submitted through the support actions provided in Settings."
            )
        ]
    )
}
