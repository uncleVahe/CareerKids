//
// CareerListViewModel.swift
// CareerKids
//
// Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI
import Combine

class CareerListViewModel: ObservableObject {
    @Published var careers: [Career] = []
    @Published var showOnlyFavorites = false
    
    private let favoritesService = FavoritesService.shared
    
    var filteredCareers: [Career] {
        if showOnlyFavorites {
            return careers.filter { favoritesService.isFavorite($0.id) }
        }
        return careers
    }
    
    func loadCareers() {
        careers = [
            Career(
                id: "1",
                title: "Програміст",
                description: "Створює додатки та веб-сайти",
                icon: "laptopcomputer",
                color: .blue
            ),
            Career(
                id: "2",
                title: "Дизайнер",
                description: "Малює красиві інтерфейси",
                icon: "paintbrush.fill",
                color: .purple
            ),
            Career(
                id: "3",
                title: "Вчитель",
                description: "Допомагає дітям навчатись",
                icon: "book.fill",
                color: .green
            ),
            Career(
                id: "4",
                title: "Лікар",
                description: "Лікує людей та рятує життя",
                icon: "heart.fill",
                color: .red
            ),
            Career(
                id: "5",
                title: "Інженер",
                description: "Будує машини та механізми",
                icon: "gearshape.fill",
                color: .orange
            )
        ]
    }
    
    func toggleFavorite(_ career: Career) {
        favoritesService.toggleFavorite(career.id)
        objectWillChange.send()
    }
    
    func isFavorite(_ career: Career) -> Bool {
        return favoritesService.isFavorite(career.id)
    }
}
