import SwiftUI
import UIKit

struct NotificationExplainerSheet: View {
    @State private var showTimePicker = false
    
    let onEnable: () -> Void
    let onSkip: () -> Void
    let onDone: () -> Void
    

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
                // Handle
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.primary.opacity(0.18))
                    .frame(width: 44, height: 5)
                    .padding(.top, 8)

                VStack(spacing: 14) {
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

                    Text("Daily Hymn Reminder")
                        .font(.title2)
                        .fontDesign(.serif)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)

                    Text("Receive one gentle reminder each day to begin with a hymn and reflection.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 22)
                }
                .padding(.top, 6)

                VStack(spacing: 12) {
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        onEnable()
                        onDone()
                    } label: {
                        Text("Enable Reminders")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.accentColor)
                            )
                            .foregroundStyle(.white)
                    }

                    Button {
                        onSkip()
                        onDone()
                    } label: {
                        Text("Maybe later")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.primary.opacity(0.18))
                            )
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 10)

                Spacer(minLength: 10)
            }
            .padding(.bottom, 12)
        }
    }
}
