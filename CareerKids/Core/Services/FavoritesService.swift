//
//  FavoritesService.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 08.01.2026.
//

import Foundation

extension Notification.Name {
    static let favoritesDidChange = Notification.Name("favoritesDidChange")
}

protocol FavoritesManaging {
    func isFavorite(_ careerId: String) -> Bool
    func toggleFavorite(_ careerId: String)
    func removeFavorite(_ careerId: String)
    func getFavorites() -> [String]
    func clearAll()
    var count: Int { get }
}

final class FavoritesService: FavoritesManaging {
    static let shared = FavoritesService()
    
    private let defaults: UserDefaults
    private let favoritesKey = "FavoriteCareerIds"
    private let queue = DispatchQueue(label: "com.careerkids.favorites", attributes: .concurrent)
    
    private var _favoriteIds: Set<String> = []
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadFavorites()
    }
    
    // MARK: - Private
    
    private func loadFavorites() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            if let ids = self.defaults.array(forKey: self.favoritesKey) as? [String] {
                self._favoriteIds = Set(ids)
            }
        }
    }
    
    private func saveFavorites() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.defaults.set(Array(self._favoriteIds), forKey: self.favoritesKey)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .favoritesDidChange, object: nil)
            }
        }
    }
    
    // MARK: - Public
    
    func isFavorite(_ careerId: String) -> Bool {
        queue.sync {
            _favoriteIds.contains(careerId)
        }
    }
    
    func toggleFavorite(_ careerId: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            if self._favoriteIds.contains(careerId) {
                self._favoriteIds.remove(careerId)
            } else {
                self._favoriteIds.insert(careerId)
            }
            
            self.saveFavorites()
        }
    }
    
    func removeFavorite(_ careerId: String) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self._favoriteIds.remove(careerId)
            self.saveFavorites() // було: дублювало persist-логіку і не постило .favoritesDidChange
        }
    }
    
    func getFavorites() -> [String] {
        queue.sync {
            Array(_favoriteIds)
        }
    }
    
    func clearAll() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self._favoriteIds.removeAll()
            self.saveFavorites()
        }
    }
    
    var count: Int {
        queue.sync {
            _favoriteIds.count
        }
    }
}
