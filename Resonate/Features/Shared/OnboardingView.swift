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
            LinearGradient(
                colors: colorScheme == .dark
                    ? [
                        Color(red: 0.08, green: 0.08, blue: 0.09),
                        Color(red: 0.11, green: 0.10, blue: 0.12)
                    ]
                    : [
                        Color(red: 0.97, green: 0.95, blue: 0.90),
                        Color(red: 0.93, green: 0.90, blue: 0.84)
                    ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .overlay(
                RadialGradient(
                    colors: colorScheme == .dark
                        ? [Color.white.opacity(0.05), Color.clear]
                        : [Color.black.opacity(0.05), Color.clear],
                    center: .center,
                    startRadius: 120,
                    endRadius: 520
                )
                .ignoresSafeArea()
            )

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 14) {
                    Group {
                        if let uiImage = UIImage(named: "LaunchLogo") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: "book.closed.fill")
                                .symbolRenderingMode(.hierarchical)
                                .scaledToFit()
                        }
                    }
                    .frame(width: 70, height: 70)
                    .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.95) : .primary)
                    .padding(.bottom, 4)

                    Text("Resonate")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                        .multilineTextAlignment(.center)

                    Text("Every hymn carries a story.\nBegin each day in worship.")
                        .font(.system(size: 17, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.72) : Color.primary.opacity(0.55))
                        .lineSpacing(2)
                        .padding(.horizontal, 28)
                }

                Spacer(minLength: 40)

                VStack(spacing: 16) {
                    Button {
                        analytics.onboardingCompleted()
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        onBeginWorship()
                    } label: {
                        Text("Begin Worship")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.accentColor)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.26 : 0.12), radius: 12, y: 6)
                    }

                    Button {
                        analytics.onboardingNotificationCTATapped()
                        showNotificationExplainer = true
                    } label: {
                        Text("Receive a Daily Hymn")
                            .font(.system(size: 17, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(colorScheme == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.35))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(
                                        colorScheme == .dark ? Color.white.opacity(0.14) : Color.black.opacity(0.10),
                                        lineWidth: 1
                                    )
                            )
                            .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.92) : Color.accentColor)
                    }

                    Button {
                        analytics.onboardingSkipped()
                        onDismiss()
                    } label: {
                        Text("Not now")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.55) : Color.primary.opacity(0.38))
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, 26)

                Spacer().frame(height: 18)
            }
            .opacity(hasAppeared ? 1 : 0)
            .scaleEffect(hasAppeared ? 1 : 0.98)
            .animation(.easeOut(duration: 0.35), value: hasAppeared)
        }
        .onAppear {
            analytics.onboardingShown()
            hasAppeared = true
        }
        .sheet(isPresented: $showNotificationExplainer) {
            NotificationExplainerSheet(
                onEnable: {
                    analytics.notificationPromptAccepted()
                    // Reflect immediately in Settings
                    environment.reminderSettingsViewModel.hotdEnabled = true
                    // Request system permission (non-blocking)
                    Task {
                        _ = try? await environment.authorizationManager.requestAuthorization()
                    }
                    // Ask user to pick a time after the explainer sheet has dismissed.
                    shouldBeginWorshipAfterTimePicker = true
                    showNotificationExplainer = false

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showTimePicker = true
                    }
                },
                onSkip: {
                    analytics.notificationPromptDeclined()
               
                    // User chose not to enable reminders; proceed normally
                    shouldBeginWorshipAfterTimePicker = false
                    showNotificationExplainer = false
                    onBeginWorship()
                },
                onDone: {
                    // No-op: this view controls dismissal explicitly above.
                }
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
}

