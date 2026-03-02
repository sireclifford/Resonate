import SwiftUI

struct ReminderTimePickerView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss

    // Local copy for smooth interaction; commit back to settings on Done.
    @State private var selectedTime: Date = Date()

    var body: some View {
        ZStack {
            // Warm parchment background to match onboarding
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

            VStack(spacing: 18) {
                // Header
                VStack(spacing: 8) {
                    Text("Choose a time")
                        .font(.title2)
                        .fontDesign(.serif)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text("We’ll send one gentle reminder each day.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 22)
                }
                .padding(.top, 10)

                // Time picker card
                VStack(spacing: 12) {
                    DatePicker(
                        "Reminder time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()

                    Text("You can change this anytime in Settings.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.primary.opacity(0.10))
                )
                .padding(.horizontal, 18)

                Spacer()

                Button {
                    // Persist selection
                    environment.settingsService.dailyReminderTime = selectedTime

                    dismiss()
                } label: {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.accentColor)
                        )
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
            }
        }
        .onAppear {
            // Start from current settings value
            selectedTime = environment.settingsService.dailyReminderTime
        }
    }
}
