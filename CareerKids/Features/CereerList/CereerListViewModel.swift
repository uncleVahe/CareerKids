//
// CareerListViewModel.swift
// CareerKids
//
// Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI
import Combine

@MainActor
class CareerListViewModel: ObservableObject {
    @Published var careers: [Career] = []
    @Published var showOnlyFavorites = false
    @Published var showRecommendedOnly = true
    @Published var refreshTrigger: UUID = UUID() // Для примусового оновлення
    @Published var recommendedCategory: CareerCategory?
    
    private let favoritesService = FavoritesService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(recommendedCategory: CareerCategory? = nil) {
        self.recommendedCategory = recommendedCategory
        
        // Слухаємо зміни в обраних професіях
        NotificationCenter.default.publisher(for: .favoritesDidChange)
            .sink { [weak self] _ in
                self?.refreshTrigger = UUID()
            }
            .store(in: &cancellables)
    }
    
    var filteredCareers: [Career] {
        // Використовуємо refreshTrigger щоб computed property перерахувалась
        _ = refreshTrigger
        
        var filtered = careers
        
        // Фільтр по обраним
        if showOnlyFavorites {
            filtered = filtered.filter { favoritesService.isFavorite($0.id) }
        }
        
        // Фільтр та сортування по рекомендованій категорії
        if let category = recommendedCategory, showRecommendedOnly {
            // Спочатку показуємо професії з рекомендованої категорії
            let recommended = filtered.filter { $0.category == category }
            let others = filtered.filter { $0.category != category }
            filtered = recommended + others
        }
        
        return filtered
    }
    
    /// Завантажує список професій з JSON файлу через DataLoaderService
    func loadCareers() {
        careers = DataLoaderService.shared.loadCareers()
    }
    
    func toggleFavorite(_ career: Career) {
        favoritesService.toggleFavorite(career.id)
        // No need to manually trigger refresh - NotificationCenter will handle it
    }
    
    func isFavorite(_ career: Career) -> Bool {
        return favoritesService.isFavorite(career.id)
    }
    
    func showAllCareers() {
        showOnlyFavorites = false
        showRecommendedOnly = false
    }
    
    func setRecommendedCategory(_ category: CareerCategory) {
        recommendedCategory = category
        showRecommendedOnly = true
        refreshTrigger = UUID()
    }
}
