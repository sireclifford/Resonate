import SwiftUI
import Combine
import Foundation

final class SessionService: ObservableObject {
    
    private let analytics: AnalyticsService
    private let settingsService: AppSettingsService
    private var sessionStart: Date?
    private var hasInteracted = false
    private var sessionID: String = UUID().uuidString
    
    init(analytics: AnalyticsService, settingsService: AppSettingsService) {
        self.analytics = analytics
        self.settingsService = settingsService
    }
    
    func startSession(source: String = "direct") {
        sessionID = UUID().uuidString
        sessionStart = Date()
        hasInteracted = false
        
        analytics.sessionStarted(source: source, sessionID: sessionID)
    }
    
    func markInteraction() {
        hasInteracted = true
    }
    
    func endSession(){
        guard let start = sessionStart else { return }
        let duration = Date().timeIntervalSince(start)
        
        if hasInteracted {
            settingsService.meaningfulSessionCount += 1
            
            analytics.sessionCompleted(sessionID: sessionID, durationSeconds: Int(duration.rounded()))
        }
        sessionStart = nil
    }
}
