//
//  ProfileView.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 04.02.2026.
//

import SwiftUI
import Combine

/// Екран профілю користувача
/// Показує персональні дані, статистику тестів, налаштування
struct ProfileView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showTestHistory = false
    @State private var showSavedPlans = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Аватар та ім'я
                    profileHeader
                    
                    // Персональна інформація
                    personalInfoSection
                    
                    // Статистика тестів
                    if viewModel.hasTestHistory {
                        testStatisticsSection
                    }
                    
                    // Кількість обраних професій
                    favoritesSection
                    
                    // Історія тестів
                    if viewModel.hasTestHistory {
                        testHistoryButton
                    }
                    
                    // Збережені плани розвитку
                    savedPlansButton
                    
                    // Кнопка редагування профілю
                    editProfileButton
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Профіль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showEditProfile) {
                ProfileEditView(viewModel: viewModel)
            }
            .sheet(isPresented: $showTestHistory) {
                TestHistoryView()
            }
            .sheet(isPresented: $showSavedPlans) {
                SavedPlansView()
            }
            .onAppear {
                viewModel.loadProfile()
            }
            .onReceive(NotificationCenter.default.publisher(for: .favoritesDidChange)) { _ in
                // Оновлюємо кількість обраних при зміні
                viewModel.loadFavoritesCount()
            }
        }
    }
    
    // MARK: - UI Components
    
    /// Заголовок профілю з аватаром
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Аватар (поки що просто іконка, пізніше можна додати фото)
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(viewModel.userInitials)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Ім'я
            Text(viewModel.userName)
                .font(.system(size: 28, weight: .bold))
            
            // Вік
            if let age = viewModel.userAge {
                Text("\(age) років")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 20)
    }
    
    /// Секція з персональною інформацією
    private var personalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Персональна інформація")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                InfoRowView(
                    icon: "person.fill",
                    title: "Ім'я",
                    value: viewModel.userName,
                    color: .blue
                )
                
                Divider()
                    .padding(.leading, 60)
                
                InfoRowView(
                    icon: "calendar",
                    title: "Вік",
                    value: viewModel.userAge.map { "\($0) років" } ?? "Не вказано",
                    color: .green
                )
                
                Divider()
                    .padding(.leading, 60)
                
                InfoRowView(
                    icon: "clock.fill",
                    title: "З нами з",
                    value: viewModel.memberSince,
                    color: .orange
                )
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    /// Секція зі статистикою тестів
    private var testStatisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Статистика")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                // Кількість пройдених тестів
                StatCardView(
                    icon: "checkmark.circle.fill",
                    title: "Пройдено тестів",
                    value: "\(viewModel.testsCompleted)",
                    color: .green
                )
                
                // Топ категорія
                if let topCategory = viewModel.topCategory {
                    StatCardView(
                        icon: topCategory.icon,
                        title: "Улюблена категорія",
                        value: topCategory.rawValue,
                        color: topCategory.color
                    )
                }
            }
        }
    }
    
    /// Секція з обраними професіями
    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Обрані професії")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            HStack {
                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Улюблених професій")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(viewModel.favoritesCount)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
    
    /// Кнопка редагування профілю
    private var editProfileButton: some View {
        Button(action: { viewModel.showEditProfile = true }) {
            HStack {
                Image(systemName: "pencil")
                    .font(.headline)
                
                Text("Редагувати профіль")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
    
    /// Кнопка перегляду історії тестів
    private var testHistoryButton: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Історія тестів")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: { showTestHistory = true }) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.title3)
                        .foregroundColor(.purple)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Переглянути історію")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(viewModel.testsCompleted) пройдено")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    /// Кнопка перегляду збережених планів
    private var savedPlansButton: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Плани розвитку")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: { showSavedPlans = true }) {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .font(.title3)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Збережені плани")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("AI рекомендації та плани")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// MARK: - Supporting Views

/// Рядок інформації в профілі
struct InfoRowView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Іконка
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            // Текст
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

/// Картка статистики
struct StatCardView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
