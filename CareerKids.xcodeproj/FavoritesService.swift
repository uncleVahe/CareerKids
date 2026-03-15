//
//  FavoritesService.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 05.01.2026.
//

import Foundation

/// Сервіс для управління обраними професіями
/// Використовує UserDefaults для збереження списку улюблених професій
class FavoritesService {
    
    // MARK: - Singleton
    static let shared = FavoritesService()
    
    // MARK: - Private Properties
    private let defaults = UserDefaults.standard
    private let favoritesKey = "favoriteCareerIDs"
    
    // MARK: - Private Init
    private init() {}
    
    // MARK: - Public Methods
    
    /// Перевіряє чи професія в списку обраних
    /// - Parameter careerID: Ідентифікатор професії
    /// - Returns: true якщо професія в обраному, false якщо ні
    func isFavorite(_ careerID: String) -> Bool {
        let favorites = getFavorites()
        return favorites.contains(careerID)
    }
    
    /// Додає або видаляє професію з обраного
    /// - Parameter careerID: Ідентифікатор професії
    func toggleFavorite(_ careerID: String) {
        var favorites = getFavorites()
        
        if let index = favorites.firstIndex(of: careerID) {
            // Видаляємо якщо вже є
            favorites.remove(at: index)
            print("💔 Removed from favorites: \(careerID)")
        } else {
            // Додаємо якщо немає
            favorites.append(careerID)
            print("❤️ Added to favorites: \(careerID)")
        }
        
        saveFavorites(favorites)
    }
    
    /// Додає професію до обраного
    /// - Parameter careerID: Ідентифікатор професії
    func addFavorite(_ careerID: String) {
        var favorites = getFavorites()
        if !favorites.contains(careerID) {
            favorites.append(careerID)
            saveFavorites(favorites)
            print("❤️ Added to favorites: \(careerID)")
        }
    }
    
    /// Видаляє професію з обраного
    /// - Parameter careerID: Ідентифікатор професії
    func removeFavorite(_ careerID: String) {
        var favorites = getFavorites()
        if let index = favorites.firstIndex(of: careerID) {
            favorites.remove(at: index)
            saveFavorites(favorites)
            print("💔 Removed from favorites: \(careerID)")
        }
    }
    
    /// Отримує список всіх обраних професій
    /// - Returns: Масив ідентифікаторів обраних професій
    func getFavorites() -> [String] {
        return defaults.stringArray(forKey: favoritesKey) ?? []
    }
    
    /// Очищає всі обрані професії
    func clearAllFavorites() {
        defaults.removeObject(forKey: favoritesKey)
        print("🗑️ All favorites cleared")
    }
    
    // MARK: - Private Methods
    
    /// Зберігає список обраних професій
    /// - Parameter favorites: Масив ідентифікаторів професій
    private func saveFavorites(_ favorites: [String]) {
        defaults.set(favorites, forKey: favoritesKey)
    }
}
