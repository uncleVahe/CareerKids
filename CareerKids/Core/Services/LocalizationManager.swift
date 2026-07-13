//
//  LocalizationManager.swift
//  CareerKids
//
//  Керує вибором мови застосунку і дає live-перемикання без рестарту.
//  Мова прокидується в дерево через `.environment(\.locale:)` на корені
//  (CareerKidsApp) — це нативний, задокументований шлях для String Catalog:
//  Text(LocalizedStringKey) резолвиться відносно \.locale з environment,
//  а не через Bundle.main.localizedString(forKey:), тому Bundle-swizzle
//  тут не потрібен і раніше просто не перехоплював виклики.
//  Для String(localized:) викликів поза view-деревом (де немає environment)
//  локаль треба передавати явно через параметр locale: — див. currentLocale.
//

import Foundation
import Combine

@MainActor
final class LocalizationManager: ObservableObject {

    enum Language: String, CaseIterable, Identifiable {
        case ukrainian = "uk"
        case english = "en"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .ukrainian: return "Українська"
            case .english: return "English"
            }
        }
    }

    static let shared = LocalizationManager()

    @Published private(set) var currentLanguage: Language

    /// Locale, що відповідає currentLanguage. Використовується там, де немає
    /// доступу до SwiftUI-environment (наприклад, explicit-key String(localized:)).
    var currentLocale: Locale { Locale(identifier: currentLanguage.rawValue) }

    private enum Keys {
        static let selectedLanguage = "selectedAppLanguage"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let resolved: Language
        if let saved = defaults.string(forKey: Keys.selectedLanguage),
           let language = Language(rawValue: saved) {
            resolved = language
        } else {
            // Перший запуск: дефолт завжди українська, незалежно від системної локалі.
            // Більшість контенту (квізи, AI-рекомендації) поки що не перекладена,
            // тож автопідхоплення English давало розсинхрон "мова=en, текст=uk".
            resolved = .ukrainian
        }

        self.currentLanguage = resolved
    }

    func setLanguage(_ language: Language) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        defaults.set(language.rawValue, forKey: Keys.selectedLanguage)
    }
}
