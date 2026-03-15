//
//  CareersTab.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 25.02.2026.
//

import SwiftUI
import Combine

/// Таб з професіями - головний екран списку професій
struct CareersTab: View {
    
    // MARK: - State
    
    @StateObject private var viewModel = CareersTabViewModel()
    @State private var showProfile = false
    @State private var showSearch = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Промо блок "Пройди тест"
                    if viewModel.shouldShowQuizPromo {
                        quizPromoCard
                    }
                    
                    // Банер рекомендацій (якщо є)
                    if let category = viewModel.recommendedCategory {
                        recommendationBanner(category: category)
                    }
                    
                    // Фільтр по обраним
                    filterControls
                    
                    // Список професій
                    careersList
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Професії")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showSearch = true }) {
                            Label("Пошук", systemImage: "magnifyingglass")
                        }
                        
                        Button(action: { viewModel.showAllCareers() }) {
                            Label("Всі професії", systemImage: "list.bullet")
                        }
                        
                        Divider()
                        
                        ForEach(CareerCategory.allCases, id: \.self) { category in
                            Button(action: { viewModel.filterByCategory(category) }) {
                                Label(category.rawValue, systemImage: category.icon)
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                CareerSearchView()
            }
            .onAppear {
                viewModel.loadCareers()
            }
        }
    }
    
    // MARK: - UI Components
    
    /// Промо карточка для проходження тесту
    private var quizPromoCard: some View {
        NavigationLink(destination: QuizView()) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Не знаєш що обрати?")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Пройди тест і отримай рекомендації")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .blue.opacity(0.15), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
    
    /// Банер з рекомендаціями
    private func recommendationBanner(category: CareerCategory) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: category.icon)
                        .font(.title3)
                        .foregroundColor(category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Рекомендовано для тебе")
                        .font(.headline)
                    
                    Text("Категорія \"\(category.rawValue)\"")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { viewModel.clearRecommendation() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(category.color.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    /// Контроли фільтрації
    private var filterControls: some View {
        HStack {
            Toggle(isOn: $viewModel.showOnlyFavorites) {
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("Улюблені")
                        .font(.subheadline)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .red))
            
            Spacer()
            
            if viewModel.showOnlyFavorites || viewModel.recommendedCategory != nil {
                Button("Скинути") {
                    viewModel.showAllCareers()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
    
    /// Список професій
    private var careersList: some View {
        Group {
            if viewModel.filteredCareers.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.filteredCareers) { career in
                    NavigationLink(destination: CareerDetailView(career: career)) {
                        CareerCard(
                            career: career,
                            isFavorite: viewModel.isFavorite(career),
                            onFavoriteTap: {
                                viewModel.toggleFavorite(career)
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                }
            }
        }
    }
    
    /// Порожній стан
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "briefcase")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Немає професій")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Спробуй змінити фільтри")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: 300)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ViewModel

@MainActor
class CareersTabViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var careers: [Career] = []
    @Published var filteredCareers: [Career] = []
    @Published var showOnlyFavorites = false
    @Published var recommendedCategory: CareerCategory?
    @Published var shouldShowQuizPromo = true
    
    // MARK: - Services
    
    private let dataLoader = DataLoaderService.shared
    private let favoritesService = FavoritesService.shared
    
    // MARK: - Lifecycle
    
    init() {
        // Перевіряємо чи користувач вже проходив тест
        if let _ = UserDefaults.standard.array(forKey: "TestHistory") {
            shouldShowQuizPromo = false
        }
    }
    
    // MARK: - Methods
    
    func loadCareers() {
        careers = dataLoader.loadCareers()
        applyFilters()
    }
    
    func filterByCategory(_ category: CareerCategory) {
        recommendedCategory = category
        applyFilters()
    }
    
    func clearRecommendation() {
        recommendedCategory = nil
        showOnlyFavorites = false
        applyFilters()
    }
    
    func showAllCareers() {
        recommendedCategory = nil
        showOnlyFavorites = false
        applyFilters()
    }
    
    func isFavorite(_ career: Career) -> Bool {
        favoritesService.isFavorite(career.id)
    }
    
    func toggleFavorite(_ career: Career) {
        favoritesService.toggleFavorite(career.id)
        objectWillChange.send()
        
        // Якщо фільтр активний, оновлюємо список
        if showOnlyFavorites {
            applyFilters()
        }
    }
    
    private func applyFilters() {
        var result = careers
        
        // Фільтр по категорії
        if let category = recommendedCategory {
            result = result.filter { $0.category == category }
        }
        
        // Фільтр по обраним
        if showOnlyFavorites {
            let favoriteIds = favoritesService.getFavorites()
            result = result.filter { favoriteIds.contains($0.id) }
        }
        
        filteredCareers = result
    }
}

// MARK: - Preview

#Preview {
    CareersTab()
}
