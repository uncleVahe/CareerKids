//
// OnboardingSteps.swift
// CareerKids
//
// Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI

// STEP 1: Welcome
struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Emoji
            Text("👋")
                .font(.system(size: 100))
            
            // Title
            Text("Привіт!")
                .font(.system(size: 40, weight: .bold))
            
            // Description
            Text("Допоможемо тобі знайти\nтвою майбутню професію!")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// STEP 2: Name Input
struct NameStep: View {
    @Binding var name: String
    @EnvironmentObject private var localization: LocalizationManager
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("📝")
                .font(.system(size: 80))
            
            Text("Як тебе звати?")
                .font(.system(size: 32, weight: .bold))
            
            TextField("Введи своє ім'я", text: $name)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal, 40)
                .focused($isTextFieldFocused)
                .onAppear {
                    // Автоматично відкриваємо клавіатуру
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isTextFieldFocused = true
                    }
                }
                .onTapGesture {
                    // Відкриваємо клавіатуру при тапі на поле
                    isTextFieldFocused = true
                }
            
            if !name.isEmpty {
                Text(String(localized: "onboarding.nameStep.greeting", defaultValue: "Приємно познайомитись, \(name)!", locale: localization.currentLocale))
                    .font(.headline)
                    .foregroundColor(.blue)
                    .transition(.scale)
            }
            
            Spacer()
        }
        .animation(.spring(), value: name)
        .contentShape(Rectangle()) // ← ВАЖЛИВО для tap gesture
        .onTapGesture {
            // Закриваємо клавіатуру при тапі поза полем
            isTextFieldFocused = false
        }
    }
}

// STEP 3: Age Selection
struct AgeStep: View {
    @Binding var age: Int
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("🎂")
                .font(.system(size: 80))

            Text("Скільки тобі років?")
                .font(.system(size: 32, weight: .bold))

            // Age picker
            Picker("Вік", selection: $age) {
                ForEach(6...18, id: \.self) { age in
                    Text(String(localized: "onboarding.ageStep.pickerItem", defaultValue: "\(age) років", locale: localization.currentLocale))
                        .tag(age)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .padding(.horizontal, 40)

            Text(String(localized: "onboarding.ageStep.selected", defaultValue: "Обрано: \(age) років", locale: localization.currentLocale))
                .font(.headline)
                .foregroundColor(.blue)

            Spacer()
        }
    }
}

// STEP 4: Ready
struct ReadyStep: View {
    let name: String
    @EnvironmentObject private var localization: LocalizationManager

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("🚀")
                .font(.system(size: 100))

            Text(String(localized: "onboarding.readyStep.greeting", defaultValue: "Готово, \(name)!", locale: localization.currentLocale))
                .font(.system(size: 36, weight: .bold))
            
            Text("Давай досліджувати професії\nта знайдемо твоє покликання!")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeStep()
}
