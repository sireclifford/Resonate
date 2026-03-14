import SwiftUI

struct ReminderTimePickerView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    // Local copy for smooth interaction; commit back to settings on Done.
    @State private var selectedTime: Date = Date()

    var body: some View {
        ZStack {
            Group {
                if colorScheme == .dark {
                    LinearGradient(
                        colors: [
                            Color(red: 0.08, green: 0.08, blue: 0.10),
                            Color(red: 0.04, green: 0.04, blue: 0.06)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    LinearGradient(
                        colors: [
                            Color(red: 0.98, green: 0.96, blue: 0.91),
                            Color(red: 0.95, green: 0.92, blue: 0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .ignoresSafeArea()
            .overlay(
                RadialGradient(
                    colors: [
                        Color.black.opacity(colorScheme == .dark ? 0.22 : 0.06),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 120,
                    endRadius: 520
                )
                .ignoresSafeArea()
            )

            VStack(spacing: 18) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.primary.opacity(colorScheme == .dark ? 0.28 : 0.18))
                    .frame(width: 44, height: 5)
                    .padding(.top, 8)

                VStack(spacing: 10) {
                    Text("Choose a time")
                        .font(.title2)
                        .fontDesign(.serif)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.primary)

                    Text("We’ll send one gentle reminder each day.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 22)
                }
                .padding(.top, 10)

                VStack(spacing: 10) {
                    DatePicker(
                        "Reminder time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .colorMultiply(colorScheme == .dark ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 6)

                    Text("You can change this anytime in Settings.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 6)
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.34))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.08), lineWidth: 1)
                )
                .padding(.horizontal, 18)

                Spacer()

                Button {
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.hour, .minute], from: selectedTime)
                    let normalizedTime = calendar.date(from: components) ?? selectedTime

                    environment.reminderSettingsViewModel.hotdTime = normalizedTime
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.accentColor)
                        )
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 18)
                .padding(.bottom, 14)
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .onAppear {
            // Start from the reminder view model source of truth and normalize to hour/minute only.
            let calendar = Calendar.current
            let currentTime = environment.reminderSettingsViewModel.hotdTime
            let components = calendar.dateComponents([.hour, .minute], from: currentTime)
            selectedTime = calendar.date(from: components) ?? currentTime
        }
    }
}
