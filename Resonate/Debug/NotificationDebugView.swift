import SwiftUI
import UserNotifications

struct NotificationDebugView: View {
    @EnvironmentObject var environment: AppEnvironment

    @State private var pendingRequests: [String] = []
    @State private var deliveredRequests: [String] = []
    @State private var hotdDebugDetails: HOTDDebugDetails?
    @State private var authorizationStatus: NotificationAuthorizationStatus = .notDetermined

    var body: some View {
        List {
            Section("Authorization") {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(statusText(authorizationStatus))
                        .foregroundStyle(.secondary)
                }

                Button("Request Permission") {
                    Task {
                        do {
                            _ = try await environment.authorizationManager.requestAuthorization()
                            await refresh()
                        } catch {
//                            print("Permission request failed:", error)
                        }
                    }
                }

                Button("Send Test Notification (30s)") {
                    Task {
                        await scheduleTestNotification()
                        await refresh()
                    }
                }
            }

            Section("HOTD Reminder") {
                Toggle("Enabled", isOn: Binding(
                    get: { environment.reminderSettingsViewModel.hotdEnabled },
                    set: { newValue in
                        if newValue {
                            Task {
                                await environment.reminderSettingsViewModel.requestPermissionAndEnableHOTD()
                                await refresh()
                            }
                        } else {
                            Task {
                                await environment.reminderSettingsViewModel.disableHOTD()
                                await refresh()
                            }
                        }
                    }
                ))

                DatePicker(
                    "Reminder Time",
                    selection: Binding(
                        get: { environment.reminderSettingsViewModel.hotdTime },
                        set: { newValue in
                            environment.reminderSettingsViewModel.hotdTime = newValue
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )

                Button("Force Sync") {
                    Task {
                        await environment.reminderSettingsViewModel.onAppBecameActive()
                        await refresh()
                    }
                }

                if let hotdDebugDetails {
                    LabeledContent("Identifier", value: hotdDebugDetails.identifier)
                    LabeledContent("Title", value: hotdDebugDetails.title)
                    LabeledContent("Body", value: hotdDebugDetails.body)
                    LabeledContent("Hymn ID", value: hotdDebugDetails.hymnID ?? "Missing")
                    LabeledContent("Current HOTD Opened", value: hotdDebugDetails.currentHOTDHasOpenedTodayText)
                    LabeledContent("Scheduled HOTD Opened", value: hotdDebugDetails.scheduledHOTDHasOpenedTodayText)
                    LabeledContent("Next Fire", value: hotdDebugDetails.nextFireDateText ?? "Unknown")
                } else {
                    Text("No pending HOTD request")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Sabbath Reminder") {
                Toggle("Enabled", isOn: Binding(
                    get: { environment.reminderSettingsViewModel.sabbathEnabled },
                    set: { newValue in
                        if newValue {
                            Task {
                                await environment.reminderSettingsViewModel.requestPermissionAndEnableSabbath()
                                await refresh()
                            }
                        } else {
                            Task {
                                await environment.reminderSettingsViewModel.disableSabbath()
                                await refresh()
                            }
                        }
                    }
                ))

                DatePicker(
                    "Reminder Time",
                    selection: Binding(
                        get: { environment.reminderSettingsViewModel.sabbathTime },
                        set: { newValue in
                            environment.reminderSettingsViewModel.sabbathTime = newValue
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )

                Button("Force Sabbath Sync") {
                    Task {
                        await environment.reminderSettingsViewModel.onAppBecameActive()
                        await refresh()
                    }
                }
            }

            Section("Pending Notifications") {
                if pendingRequests.isEmpty {
                    Text("None")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(pendingRequests, id: \.self) { id in
                        Text(id)
                            .font(.footnote)
                    }
                }

                Button("Refresh Pending") {
                    Task { await refresh() }
                }
            }

            Section("Delivered Notifications") {
                if deliveredRequests.isEmpty {
                    Text("None")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(deliveredRequests, id: \.self) { id in
                        Text(id)
                            .font(.footnote)
                    }
                }

                Button("Refresh Delivered") {
                    Task { await refresh() }
                }
            }
        }
        .navigationTitle("Notification Debug")
        .task {
            await refresh()
        }
    }

    private func refresh() async {
        authorizationStatus = await environment.authorizationManager.currentStatus()

        let requests = await environment.notificationClient.pendingRequests()
        let delivered = await environment.notificationClient.deliveredNotifications()

        var results: [String] = []
        var deliveredResults: [String] = []
        var hotdDetails: HOTDDebugDetails?

        for request in requests {
            var description = request.identifier

            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
               let nextDate = trigger.nextTriggerDate() {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                description += " — " + formatter.string(from: nextDate)
            } else if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                description += " — in \(Int(trigger.timeInterval))s"
            }

            results.append(description)

            if request.identifier.hasPrefix(ReminderIdentifier.hotdPrimary.rawValue) {
                let candidate = HOTDDebugDetails(
                    identifier: request.identifier,
                    title: request.content.title,
                    body: request.content.body,
                    hymnID: request.content.userInfo["hymnID"] as? String,
                    currentHOTDHasOpenedTodayText: currentHOTDHasOpenedTodayText(),
                    scheduledHOTDHasOpenedTodayText: scheduledHOTDHasOpenedTodayText(for: request.content.userInfo["hymnID"] as? String),
                    nextFireDateText: notificationDateDescription(for: request.trigger),
                    nextFireDate: calendarTriggerDate(for: request.trigger)
                )

                if hotdDetails == nil || (candidate.nextFireDate ?? .distantFuture) < (hotdDetails?.nextFireDate ?? .distantFuture) {
                    hotdDetails = candidate
                }
            }
        }

        for notification in delivered {
            let request = notification.request
            let deliveredDate = notification.date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short

            deliveredResults.append("\(request.identifier) — \(formatter.string(from: deliveredDate))")
        }

        hotdDebugDetails = hotdDetails
        pendingRequests = results.sorted()
        deliveredRequests = deliveredResults.sorted()
    }

    private func scheduleTestNotification() async {
        let status = await environment.authorizationManager.currentStatus()

        guard status.isAllowedToSchedule else {
            do {
                let requested = try await environment.authorizationManager.requestAuthorization()
                guard requested.isAllowedToSchedule else { return }
            } catch {
//                print("Test notification permission request failed:", error)
                return
            }
            return await scheduleTestNotification()
        }

        let content = UNMutableNotificationContent()
        content.title = "Resonate Test"
        content.subtitle = "Debug Notification"
        content.body = "This notification was scheduled from Notification Debug."
        content.sound = .default
        content.userInfo = [
            "type": "debug",
            "source": "notification_debug_view"
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request = UNNotificationRequest(
            identifier: "debug.test.notification",
            content: content,
            trigger: trigger
        )

        do {
            await environment.notificationClient.removePending(ids: ["debug.test.notification"])
            await environment.notificationClient.removeDelivered(ids: ["debug.test.notification"])
            try await environment.notificationClient.add(request)
        } catch {
//            print("Failed to schedule test notification:", error)
        }
    }

    private func statusText(_ status: NotificationAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        }
    }

    private func notificationDateDescription(for trigger: UNNotificationTrigger?) -> String? {
        if let nextDate = calendarTriggerDate(for: trigger) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: nextDate)
        }

        if let trigger = trigger as? UNTimeIntervalNotificationTrigger {
            return "in \(Int(trigger.timeInterval))s"
        }

        return nil
    }

    private func calendarTriggerDate(for trigger: UNNotificationTrigger?) -> Date? {
        guard let trigger = trigger as? UNCalendarNotificationTrigger else {
            return nil
        }

        return trigger.nextTriggerDate()
    }

    private func currentHOTDHasOpenedTodayText() -> String {
        let currentHOTD = environment.hymnService.currentHymnOfTheDay ?? environment.hymnService.hymnOfTheDay()

        guard
            let currentHOTD
        else {
            return "Unknown"
        }

        return environment.hymnOfTheDayEngagementService.hasOpenedToday(hymnID: currentHOTD.id) ? "Yes" : "No"
    }

    private func scheduledHOTDHasOpenedTodayText(for hymnID: String?) -> String {
        guard
            let hymnID,
            let parsedHymnID = Int(hymnID)
        else {
            return "Unknown"
        }

        return environment.hymnOfTheDayEngagementService.hasOpenedToday(hymnID: parsedHymnID) ? "Yes" : "No"
    }
}

private struct HOTDDebugDetails {
    let identifier: String
    let title: String
    let body: String
    let hymnID: String?
    let currentHOTDHasOpenedTodayText: String
    let scheduledHOTDHasOpenedTodayText: String
    let nextFireDateText: String?
    let nextFireDate: Date?
}
