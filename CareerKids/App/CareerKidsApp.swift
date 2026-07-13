//
// CareerKidsApp.swift
// CareerKids
//

import SwiftUI
import Combine

@main
struct CareerKidsApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var localization = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isOnboardingComplete {
                    MainTabView()
                } else {
                    OnboardingView(isOnboardingComplete: $appState.isOnboardingComplete)
                }
            }
            // .id() форсить повне перестворення дерева view при зміні мови —
            // без цього SwiftUI не перерезолвить вже інстанційовані LocalizedStringKey.
            .id(localization.currentLanguage)
            .environmentObject(localization)
            // Нативний шлях String Catalog для live-перемикання: Text(LocalizedStringKey)
            // резолвиться відносно цієї locale, а не системної.
            .environment(\.locale, localization.currentLocale)
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

