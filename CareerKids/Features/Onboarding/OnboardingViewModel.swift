//
// OnboardingViewModel.swift
// CareerKids
//
// Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var userName: String = ""
    @Published var userAge: Int = 10
    
    let totalSteps = 4
    
    var canProceed: Bool {
        switch currentStep {
        case 1: return !userName.isEmpty && userName.count >= 2
        case 2: return true
        default: return true
        }
    }
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            withAnimation(.spring()) {
                currentStep += 1
            }
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            withAnimation(.spring()) {
                currentStep -= 1
            }
        }
    }
    
    func completeOnboarding() {
        UserProfileService.shared.saveProfile(name: userName, age: userAge)
    }
}
