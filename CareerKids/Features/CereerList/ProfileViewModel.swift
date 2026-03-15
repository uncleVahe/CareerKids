//
//  ProfileViewModel.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 04.02.2026.
//

import SwiftUI
import Combine

/// ViewModel для екрану профілю
/// Управляє даними користувача, статистикою тестів та налаштуваннями
@MainActor
class ProfileViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var userName: String = ""
    @Published var userAge: Int?
    @Published var memberSince: String = ""
    @Published var testsCompleted: Int = 0
    @Published var topCategory: CareerCategory?
    @Published var favoritesCount: Int = 0
    @Published var showEditProfile: Bool = false
    @Published var profileImageData: Data?
    
    // MARK: - Private Properties
    
    private let profileService = UserProfileService.shared
    private let favoritesService = FavoritesService.shared
    
    // MARK: - Computed Properties
    
    /// Ініціали користувача для аватара
    var userInitials: String {
        let words = userName.split(separator: " ")
        if words.count >= 2 {
            // Ім'я та Прізвище → І.П.
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        } else if let firstLetter = userName.first {
            // Тільки ім'я → І
            return String(firstLetter).uppercased()
        }
        return "?"
    }
    
    /// Чи є історія тестів
    var hasTestHistory: Bool {
        testsCompleted > 0
    }
    
    // MARK: - Public Methods
    
    /// Завантажує дані профілю
    func loadProfile() {
        let profile = profileService.getProfile()
        userName = profile.name
        userAge = profile.age
        profileImageData = profileService.getProfileImage()
        
        // Завантажуємо дату створення профілю
        loadMemberSince()
        
        // Завантажуємо статистику
        loadStatistics()
        
        // Завантажуємо обрані професії
        loadFavoritesCount()
    }
    
    /// Оновлює дані профілю
    func updateProfile(name: String, age: Int) {
        profileService.saveProfile(name: name, age: age)
        userName = name
        userAge = age
        
        print("✅ Profile updated: \(name), age: \(age)")
    }
    
    /// Оновлює фото профілю
    func updateProfileImage(_ imageData: Data?) {
        profileService.saveProfileImage(imageData)
        profileImageData = imageData
        
        print("✅ Profile image updated")
    }
    
    // MARK: - Private Methods
    
    /// Завантажує дату реєстрації користувача
    private func loadMemberSince() {
        // TODO: Зберігати дату першого запуску в UserDefaults
        // Поки що показуємо поточний місяць/рік
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "MMMM yyyy"
        memberSince = formatter.string(from: Date())
    }
    
    /// Завантажує статистику тестів
    private func loadStatistics() {
        // TODO: Реалізувати збереження історії тестів
        // Поки що показуємо моковані дані
        testsCompleted = UserDefaults.standard.integer(forKey: "testsCompleted")
        
        // Завантажуємо топ категорію з останнього тесту
        if let categoryRawValue = UserDefaults.standard.string(forKey: "lastTopCategory"),
           let category = CareerCategory(rawValue: categoryRawValue) {
            topCategory = category
        }
    }
    
    /// Завантажує кількість обраних професій
    func loadFavoritesCount() {
        // Get all stored favorites
        let allFavorites = favoritesService.getFavorites()
        
        // Load all available careers
        let availableCareers = DataLoaderService.shared.loadCareers()
        let validCareerIds = Set(availableCareers.map { $0.id })
        
        // Count only favorites that match actual careers
        let validFavorites = allFavorites.filter { validCareerIds.contains($0) }
        favoritesCount = validFavorites.count
        
        // Debug: Show what's actually stored
        print("❤️ All favorites stored: \(allFavorites)")
        print("❤️ Valid favorites: \(validFavorites)")
        print("❤️ Valid count: \(favoritesCount)")
        
        // Debug: Check UserDefaults directly
        if let stored = UserDefaults.standard.array(forKey: "FavoriteCareerIds") as? [String] {
            print("🔍 Raw UserDefaults: \(stored)")
            print("🔍 Raw count: \(stored.count)")
        }
        
        // Clean up invalid favorites if found
        if allFavorites.count != validFavorites.count {
            print("⚠️ Found invalid favorites, cleaning up...")
            // Remove invalid favorites
            let invalidFavorites = Set(allFavorites).subtracting(validCareerIds)
            invalidFavorites.forEach { favoritesService.removeFavorite($0) }
        }
    }
    
    /// Зберігає результат тесту
    func saveTestResult(category: CareerCategory) {
        // Збільшуємо лічильник тестів
        testsCompleted += 1
        UserDefaults.standard.set(testsCompleted, forKey: "testsCompleted")
        
        // Зберігаємо топ категорію
        UserDefaults.standard.set(category.rawValue, forKey: "lastTopCategory")
        topCategory = category
    }
}
