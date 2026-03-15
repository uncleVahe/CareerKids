//
//  CareerListView.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI

/// Головний екран зі списком професій
/// Показує всі доступні професії з можливістю фільтрації по обраним
struct CareerListView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: CareerListViewModel
    @State private var showQuiz = false
    @State private var showProfile = false
    @State private var refreshID = UUID()
    @State private var showCareersWithCategory: CareerCategory?
    
    // MARK: - Init
    
    init(recommendedCategory: CareerCategory? = nil) {
        _viewModel = StateObject(wrappedValue: CareerListViewModel(recommendedCategory: recommendedCategory))
        _showCareersWithCategory = State(initialValue: recommendedCategory)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    
                    // Кнопка запуску тесту
                    quizPromptButton
                    
                    // Банер рекомендацій (якщо є фільтр по категорії)
                    if viewModel.recommendedCategory != nil {
                        recommendationBanner
                    }
                    
                    // Фільтр по обраним
                    favoritesToggle
                    
                    // Список професій
                    careersList
                }
                .padding(.vertical)
                .id(refreshID)
            }
            .onAppear {
                viewModel.loadCareers()
                refreshID = UUID()
            }
            .navigationTitle("Професії")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                // Кнопка профілю
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showProfile = true }) {
                        Image(systemName: "person.circle.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                
                // Debug: Reset кнопка
                #if DEBUG
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        UserProfileService.shared.clearProfile()
                        exit(0) // Перезапустить додаток (тільки для debug)
                    }
                    .font(.caption)
                }
                #endif
            }
            .sheet(isPresented: $showQuiz) {
                QuizView(onViewCareersWithCategory: { category in
                    showQuiz = false
                    // Update the recommended category
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.setRecommendedCategory(category)
                    }
                })
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
    
    // MARK: - UI Components
    
    /// Кнопка для запуску тесту
    private var quizPromptButton: some View {
        Button(action: { showQuiz = true }) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Не знаєш що обрати?")
                        .font(.headline)
                    
                    Text("Пройди тест і дізнайся!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .padding(.top, 12)
    }
    
    /// Перемикач фільтру по обраним професіям
    private var favoritesToggle: some View {
        Toggle(isOn: $viewModel.showOnlyFavorites) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("Тільки улюблені")
                    .font(.subheadline)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    /// Банер з рекомендаціями по категорії
    private var recommendationBanner: some View {
        VStack(spacing: 12) {
            if let category = viewModel.recommendedCategory, viewModel.showRecommendedOnly {
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
                            .foregroundColor(.primary)
                        
                        Text("Професії у категорії \"\(category.rawValue)\"")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(category.color.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // Кнопка показати всі професії
            if viewModel.showRecommendedOnly || viewModel.showOnlyFavorites {
                Button(action: {
                    viewModel.showAllCareers()
                }) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .font(.headline)
                        
                        Text("Показати всі професії")
                            .font(.headline)
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
    }
    
    /// Список професій
    private var careersList: some View {
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

// MARK: - Preview

#Preview {
    CareerListView()
}
