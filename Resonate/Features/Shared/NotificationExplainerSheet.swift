import SwiftUI
import UIKit

struct NotificationExplainerSheet: View {
    @State private var showTimePicker = false
    @Environment(\.colorScheme) private var colorScheme
    
    let onEnable: () -> Void
    let onSkip: () -> Void
    let onDone: () -> Void
    

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

                VStack(spacing: 18) {
                    Group {
                        if let uiImage = UIImage(named: "AppLogo") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Image(systemName: "bell.badge.fill")
                                .symbolRenderingMode(.hierarchical)
                                .scaledToFit()
                        }
                    }
                    .frame(width: 52, height: 52)
                    .foregroundStyle(.primary)
                    .padding(.top, 4)

                    VStack(spacing: 10) {
                        Text("Daily Hymn Reminder")
                            .font(.title2)
                            .fontDesign(.serif)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.primary)

                        Text("Receive one gentle reminder each day to begin with a hymn and reflection.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 22)
                    }
                }
                .padding(.top, 10)

                VStack(spacing: 12) {
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        onEnable()
                        onDone()
                    } label: {
                        Text("Enable Reminders")
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

                    Button {
                        onSkip()
                        onDone()
                    } label: {
                        Text("Maybe later")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.primary.opacity(colorScheme == .dark ? 0.18 : 0.14), lineWidth: 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(colorScheme == .dark ? Color.white.opacity(0.03) : Color.white.opacity(0.12))
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 22)
                .padding(.top, 6)

                Spacer(minLength: 10)
            }
            .padding(.horizontal, 22)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }
}
