//
//  FavoritesService.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 08.01.2026.
//

import Foundation

class FavoritesService {
    static let shared = FavoritesService()
    
    private let defaults = UserDefaults.standard
    private let favoritesKey = "FavoriteCareerIds"
    
    private(set) var favoriteIds: Set<String> = []
    
    init() {
        loadFavorites()
    }
    
    // MARK: - Load
    
    private func loadFavorites() {
        if let ids = defaults.array(forKey: self.favoritesKey) as? [String] {
            self.favoriteIds = Set(ids)
            print("📂 Loaded \(ids.count) favorites: \(ids)")
        }
    }
    
    // MARK: - Save
    
    private func saveFavorites() {
        let idsArray = Array(favoriteIds)
        defaults.set(idsArray, forKey: favoritesKey)
        print("💾 Saved \(idsArray.count) favorites")
    }
    
    // MARK: - Public Methods
    
    func isFavorite(_ careerId: String) -> Bool {
        return favoriteIds.contains(careerId)
    }
    
    func toggleFavorite(_ careerId: String) {
        if favoriteIds.contains(careerId) {
            favoriteIds.remove(careerId)
            print("💔 Removed from favorites: \(careerId)")
        } else {
            favoriteIds.insert(careerId)
            print("❤️ Added to favorites: \(careerId)")
        }
        saveFavorites()
    }
    
    func addFavorite(_ careerId: String) {
        favoriteIds.insert(careerId)
        saveFavorites()
    }
    
    func removeFavorite(_ careerId: String) {
        favoriteIds.remove(careerId)
        saveFavorites()
    }
    
    func clearAll() {
        favoriteIds.removeAll()
        saveFavorites()
        print("🗑️ All favorites cleared")
    }
    
    var count: Int {
        return favoriteIds.count
    }
}
