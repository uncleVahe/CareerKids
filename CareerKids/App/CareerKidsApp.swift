//
// CareerKidsApp.swift
// CareerKids
//

import SwiftUI

@main
struct CareerKidsApp: App {
    @State private var isOnboardingComplete = UserProfileService.shared.hasCompletedOnboarding
    
    var body: some Scene {
        WindowGroup {
            if isOnboardingComplete {
                CareerListView()
            } else {
                OnboardingView(isOnboardingComplete: $isOnboardingComplete)
            }
        }
    }
}
