//
// CareerKidsApp.swift
// CareerKids
//

import SwiftUI
import Combine

@main
struct CareerKidsApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.isOnboardingComplete {
                MainTabView()
            } else {
                OnboardingView(isOnboardingComplete: $appState.isOnboardingComplete)
            }
        }
    }
}

// MARK: - App State

@MainActor
final class AppState: ObservableObject {
    @Published var isOnboardingComplete: Bool
    
    private let userProfileService: UserProfileService
    
    init(userProfileService: UserProfileService = .shared) {
        self.userProfileService = userProfileService
        self.isOnboardingComplete = userProfileService.hasCompletedOnboarding
    }
}

