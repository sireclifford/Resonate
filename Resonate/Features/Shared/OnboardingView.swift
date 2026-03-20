import SwiftUI
import UIKit

struct OnboardingView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.colorScheme) private var colorScheme

    private let analytics: AnalyticsService
    var onBeginWorship: () -> Void
    var onDismiss: () -> Void

    @State private var showNotificationExplainer = false
    @State private var showTimePicker = false
    @State private var shouldBeginWorshipAfterTimePicker = false
    @State private var hasAppeared = false

    init(
        analytics: AnalyticsService,
        onBeginWorship: @escaping () -> Void = {},
        onDismiss: @escaping () -> Void = {}
    ) {
        self.analytics = analytics
        self.onBeginWorship = onBeginWorship
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack {
            backgroundLayer

            ScrollView(showsIndicators: false) {
                VStack(spacing: 26) {
                    topBrandBar
                    heroCard
                    actionPanel
                }
                .frame(maxWidth: 540)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 12)
            .animation(.easeOut(duration: 0.4), value: hasAppeared)
        }
        .onAppear {
            analytics.onboardingShown()
            hasAppeared = true
        }
        .sheet(isPresented: $showNotificationExplainer) {
            NotificationExplainerSheet(
                onEnable: {
                    analytics.notificationPromptAccepted()
                    environment.reminderSettingsViewModel.hotdEnabled = true

                    Task {
                        _ = try? await environment.authorizationManager.requestAuthorization()
                    }

                    shouldBeginWorshipAfterTimePicker = true
                    showNotificationExplainer = false

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showTimePicker = true
                    }
                },
                onSkip: {
                    analytics.notificationPromptDeclined()
                    shouldBeginWorshipAfterTimePicker = false
                    showNotificationExplainer = false
                    onBeginWorship()
                },
                onDone: {}
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showTimePicker, onDismiss: {
            if shouldBeginWorshipAfterTimePicker {
                shouldBeginWorshipAfterTimePicker = false
                onBeginWorship()
            }
        }) {
            ReminderTimePickerView()
                .environmentObject(environment)
        }
    }

    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark
                    ? [
                        Color(red: 0.08, green: 0.07, blue: 0.09),
                        Color(red: 0.12, green: 0.10, blue: 0.12),
                        Color(red: 0.09, green: 0.08, blue: 0.10)
                    ]
                    : [
                        Color(red: 0.98, green: 0.95, blue: 0.90),
                        Color(red: 0.95, green: 0.90, blue: 0.82),
                        Color(red: 0.97, green: 0.93, blue: 0.87)
                    ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    accentTint.opacity(colorScheme == .dark ? 0.16 : 0.14),
                    .clear
                ],
                center: .top,
                startRadius: 10,
                endRadius: 260
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color.white.opacity(colorScheme == .dark ? 0.05 : 0.18),
                    .clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 360
            )
            .ignoresSafeArea()
        }
    }

    private var topBrandBar: some View {
        HStack(spacing: 12) {
            Group {
                if let uiImage = UIImage(named: "LaunchLogo") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                } else {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .symbolRenderingMode(.hierarchical)
                }
            }
            .frame(width: 46, height: 46)
            .foregroundStyle(primaryText)
            .background(
                Circle()
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.56))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(colorScheme == .dark ? 0.12 : 0.68), lineWidth: 1)
                    )
            )

            VStack(alignment: .leading, spacing: 2) {
                Text("Resonate")
                    .font(.josefin(size: 24, weight: .semibold))
                    .foregroundStyle(primaryText)

                Text("Daily worship, beautifully held")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(secondaryText)
            }

            Spacer()
        }
    }

    private var heroCard: some View {
        VStack(spacing: 22) {
            HStack {
                label(text: "CURATED DAILY")

                Spacer()

                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(accentTint)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.58))
                    )
            }

            VStack(spacing: 12) {
                Text("A quieter, richer way to begin each day.")
                    .font(.system(size: 38, weight: .bold, design: .serif))
                    .foregroundStyle(primaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Text("Open a hymn, follow its story, and return to a rhythm of worship that feels intentional instead of rushed.")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            quotePanel

            HStack(spacing: 10) {
                featureChip(icon: "music.note.house.fill", text: "Daily hymn")
                featureChip(icon: "book.pages.fill", text: "Stories")
                featureChip(icon: "bell.badge.fill", text: "Reminders")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(cardBackground)
        .overlay(cardBorder)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.20 : 0.08), radius: 24, y: 14)
    }

    private var quotePanel: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(accentTint)

                Text("Today's atmosphere")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(secondaryText)
            }

            Text("“Every hymn carries a memory, a prayer, and a place to begin again.”")
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundStyle(primaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Text("Built for quiet mornings, small pauses, and the moments that deserve more than noise.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.05 : 0.45))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.54), lineWidth: 1)
                )
        )
    }

    private var actionPanel: some View {
        VStack(spacing: 16) {
            beginWorshipButton
            reminderButton
            dismissButton
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.05 : 0.24))
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.48), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.18 : 0.06), radius: 18, y: 10)
    }

    private var beginWorshipButton: some View {
        Button {
            analytics.onboardingCompleted()
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            onBeginWorship()
        } label: {
            HStack {
                Text("Begin Worship")
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 15, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [accentTint, accentTint.opacity(0.82)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: accentTint.opacity(0.24), radius: 16, y: 8)
        }
    }

    private var reminderButton: some View {
        Button {
            analytics.onboardingNotificationCTATapped()
            showNotificationExplainer = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.70))
                        .frame(width: 38, height: 38)

                    Image(systemName: "bell.badge")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(accentTint)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Set a daily hymn reminder")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(primaryText)

                    Text("Choose a time and return with intention.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(secondaryText)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.05 : 0.38))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.55), lineWidth: 1)
            )
        }
    }

    private var dismissButton: some View {
        Button {
            analytics.onboardingSkipped()
            onDismiss()
        } label: {
            Text("Not now")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(secondaryText)
                .padding(.top, 4)
        }
    }

    private func featureChip(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))

            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
        }
        .foregroundStyle(primaryText.opacity(0.92))
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            Capsule()
                .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.45))
        )
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.55), lineWidth: 1)
        )
    }

    private func label(text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(1.6)
            .foregroundStyle(accentTint)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(accentTint.opacity(colorScheme == .dark ? 0.14 : 0.12))
            )
    }

    private var accentTint: Color {
        colorScheme == .dark
            ? Color(red: 0.90, green: 0.72, blue: 0.44)
            : Color(red: 0.60, green: 0.38, blue: 0.16)
    }

    private var primaryText: Color {
        colorScheme == .dark ? .white : Color(red: 0.17, green: 0.12, blue: 0.10)
    }

    private var secondaryText: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.70)
            : Color(red: 0.28, green: 0.22, blue: 0.18).opacity(0.72)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .fill(
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [Color.white.opacity(0.08), Color.white.opacity(0.03)]
                        : [Color.white.opacity(0.78), Color.white.opacity(0.46)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 34, style: .continuous)
            .stroke(Color.white.opacity(colorScheme == .dark ? 0.10 : 0.62), lineWidth: 1)
    }
}
