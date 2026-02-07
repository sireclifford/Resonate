//
//  ResonateApp.swift
//  Resonate
//
//  Created by Clifford Owusu on 2026-02-07.
//

import SwiftUI

@main
struct ResonateApp: App {
    @StateObject private var environment = AppEnvironment()
    
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(environment)
        }
    }
}
