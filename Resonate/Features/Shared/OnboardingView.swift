import SwiftUI
import UIKit

struct OnboardingView: View {
    @EnvironmentObject private var environment: AppEnvironment
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
            // Warm parchment background
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.96, blue: 0.91),
                    Color(red: 0.95, green: 0.92, blue: 0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .overlay(
                // Subtle vignette for depth
                RadialGradient(
                    colors: [
                        Color.black.opacity(0.06),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 120,
                    endRadius: 520
                )
                .ignoresSafeArea()
            )

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
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
                    .frame(width: 64, height: 64)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 2)

                    Text("Resonate")
                        .font(.title)
                        .fontDesign(.serif)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text("Every hymn carries a story.\nBegin each day in worship.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)
                }

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        analytics.log(.onboardingCompleted, parameters: [.source: "onboarding"])
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        onBeginWorship()
                    } label: {
                        Text("Begin Worship")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.accentColor)
                            )
                            .foregroundStyle(.white)
                    }

                    Button {
                        analytics.log(.onboardingNotificationCTATapped, parameters: [.source: "onboarding"])
                        showNotificationExplainer = true
                    } label: {
                        Text("Receive a Daily Hymn")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.primary.opacity(0.2))
                            )
                    }

                    Button {
                        analytics.log(.onboardingSkipped, parameters: [.source: "onboarding"])
                        onDismiss()
                    } label: {
                        Text("Not now")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 28)

                Spacer().frame(height: 24)
            }
            .opacity(hasAppeared ? 1 : 0)
            .scaleEffect(hasAppeared ? 1 : 0.98)
            .animation(.easeOut(duration: 0.35), value: hasAppeared)
        }
        .onAppear {
            analytics.log(
                .onboardingShown,
                parameters: [.source: "onboarding"]
            )
            hasAppeared = true
        }
        .sheet(isPresented: $showNotificationExplainer) {
            NotificationExplainerSheet(
                onEnable: {
                    analytics.log(.notificationPromptAccepted, parameters: [.source: "onboarding"])
                    
                    
                    // Reflect immediately in Settings
                    environment.settingsService.dailyReminderEnabled = true
                    environment.settingsService.skipTodayDailyReminder = true
                    // Request system permission (non-blocking)
                    environment.notificationService.requestPermission()

                    // Ask user to pick a time
                    shouldBeginWorshipAfterTimePicker = true
                    showNotificationExplainer = false
                    
                    showTimePicker = true
                },
                onSkip: {
                    analytics.log(
                        .notificationPromptDeclined,
                        parameters: [.source: "onboarding"]
                    )
               
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
