//
// OnboardingView.swift
// CareerKids
//
// Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject var viewModel = OnboardingViewModel()
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: Double(viewModel.currentStep + 1), total: Double(viewModel.totalSteps))
                    .tint(.blue)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Кнопка "назад" (тільки стрілка)
                HStack {
                    if viewModel.currentStep > 0 {
                        Button(action: {
                            hideKeyboard()
                            viewModel.previousStep()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .frame(height: 44) // фіксована висота щоб не стрибало
                .padding(.top, 8)
                
                // Content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeStep()
                        .tag(0)
                    
                    NameStep(name: $viewModel.userName)
                        .tag(1)
                    
                    AgeStep(age: $viewModel.userAge)
                        .tag(2)
                    
                    ReadyStep(name: viewModel.userName)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)
                
                // Кнопка "Далі" / "Почати"
                Button(action: {
                    hideKeyboard()
                    if viewModel.currentStep == viewModel.totalSteps - 1 {
                        viewModel.completeOnboarding()
                        isOnboardingComplete = true
                    } else {
                        viewModel.nextStep()
                    }
                }) {
                    Text(viewModel.currentStep == viewModel.totalSteps - 1 ? "Почати!" : "Далі")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canProceed ? Color.blue : Color.gray)
                        .cornerRadius(16)
                }
                .disabled(!viewModel.canProceed)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .onChange(of: viewModel.currentStep) { _ in
                    hideKeyboard()
                }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
