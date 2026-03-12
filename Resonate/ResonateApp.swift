import SwiftUI
import YouVersionPlatform
import Firebase
import UserNotifications
import UIKit

final class ResonateAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var onNotificationTapped: ((Int) -> Void)?
    var pendingTappedHymnID: Int?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        let hymnID: Int?
        if let intID = userInfo["hymnID"] as? Int {
            hymnID = intID
        } else if let numberID = userInfo["hymnID"] as? NSNumber {
            hymnID = numberID.intValue
        } else if let stringID = userInfo["hymnID"] as? String, let intID = Int(stringID) {
            hymnID = intID
        } else {
            hymnID = nil
        }

        if let hymnID {
            DispatchQueue.main.async {
                if let onNotificationTapped = self.onNotificationTapped {
                    onNotificationTapped(hymnID)
                } else {
                    self.pendingTappedHymnID = hymnID
                }
            }
        }

        completionHandler()
    }
}

@main
struct ResonateApp: App {
    @StateObject private var environment = AppEnvironment()
    @UIApplicationDelegateAdaptor(ResonateAppDelegate.self) private var appDelegate
    
    init() {
        YouVersionPlatform.configure(appKey: "gSTExotiejEWpm6iAL9Js2g4ySwgQB9eDhQzxvwqO4uGReVv")
        FirebaseApp.configure()
    }
    
    private func bindNotificationRouting() {
        appDelegate.onNotificationTapped = { hymnID in
            environment.navigationService.openHymnFromNotification(id: hymnID)
            environment.pendingSessionSource = "push_notification"
            environment.analyticsService.reminderNotificationTapped(hymnID: hymnID)
        }

        if let pendingTappedHymnID = appDelegate.pendingTappedHymnID {
            appDelegate.pendingTappedHymnID = nil
            appDelegate.onNotificationTapped?(pendingTappedHymnID)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView(environment: environment)
                .environmentObject(environment)
                .onAppear {
                    bindNotificationRouting()
                }
        }
    }
}
