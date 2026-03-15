//
//  ProfileTab.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 25.02.2026.
//

import SwiftUI
import Combine
import PhotosUI

/// Таб з профілем користувача
struct ProfileTab: View {
    
    // MARK: - State
    
    @StateObject private var viewModel = ProfileTabViewModel()
    @State private var showEditProfile = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Аватар та ім'я
                    profileHeader
                    
                    // Швидка статистика
                    quickStatsSection
                    
                    // Досягнення (скоро)
                    achievementsSection
                    
                    // Налаштування
                    settingsSection
                    
                    // Про додаток
                    aboutSection
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Профіль")
            .sheet(isPresented: $showEditProfile) {
                ProfileEditView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadProfile()
            }
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Аватар
            ZStack {
                if let imageData = viewModel.profileImageData,
                   let uiImage = UIImage(data: imageData) {
                    // Показуємо фото користувача
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    // Показуємо градієнт з ініціалами
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Text(viewModel.initials)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // Ім'я
            VStack(spacing: 4) {
                Text(viewModel.userName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let age = viewModel.userAge {
                    Text("\(age) років")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Кнопка редагування
            Button(action: { showEditProfile = true }) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Редагувати профіль")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Quick Stats
    
    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Твоя активність")
                .font(.headline)
            
            HStack(spacing: 12) {
                QuickStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.testsCompleted)",
                    label: "Тестів",
                    color: .green
                )
                
                QuickStatCard(
                    icon: "heart.fill",
                    value: "\(viewModel.favoritesCount)",
                    label: "Улюблених",
                    color: .red
                )
                
                QuickStatCard(
                    icon: "doc.fill",
                    value: "\(viewModel.plansCount)",
                    label: "Планів",
                    color: .blue
                )
            }
        }
    }
    
    // MARK: - Achievements
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Досягнення")
                    .font(.headline)
                
                Spacer()
                
                Text("Скоро")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    AchievementBadge(
                        icon: "star.fill",
                        title: "Перший крок",
                        description: "Пройди перший тест",
                        isUnlocked: viewModel.testsCompleted > 0,
                        color: .yellow
                    )
                    
                    AchievementBadge(
                        icon: "heart.fill",
                        title: "Колекціонер",
                        description: "Додай 5 улюблених професій",
                        isUnlocked: viewModel.favoritesCount >= 5,
                        color: .red
                    )
                    
                    AchievementBadge(
                        icon: "doc.fill",
                        title: "Планувальник",
                        description: "Збережи план розвитку",
                        isUnlocked: viewModel.plansCount > 0,
                        color: .blue
                    )
                    
                    AchievementBadge(
                        icon: "flame.fill",
                        title: "У вогні",
                        description: "Пройди 5 тестів",
                        isUnlocked: viewModel.testsCompleted >= 5,
                        color: .orange
                    )
                }
            }
        }
    }
    
    // MARK: - Settings
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Налаштування")
                .font(.headline)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Нагадування",
                    color: .orange,
                    showChevron: true
                ) {
                    // TODO: Notifications settings
                }
                
                Divider()
                    .padding(.leading, 52)
                
                SettingsRow(
                    icon: "globe",
                    title: "Мова",
                    color: .blue,
                    subtitle: "Українська",
                    showChevron: true
                ) {
                    // TODO: Language settings
                }
                
                Divider()
                    .padding(.leading, 52)
                
                SettingsRow(
                    icon: "paintbrush.fill",
                    title: "Тема",
                    color: .purple,
                    subtitle: "Системна",
                    showChevron: true
                ) {
                    // TODO: Theme settings
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }
    
    // MARK: - About
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Інформація")
                .font(.headline)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Про додаток",
                    color: .blue,
                    showChevron: true
                ) {
                    // TODO: About screen
                }
                
                Divider()
                    .padding(.leading, 52)
                
                SettingsRow(
                    icon: "star.fill",
                    title: "Оцінити додаток",
                    color: .yellow,
                    showChevron: true
                ) {
                    // TODO: Rate app
                }
                
                Divider()
                    .padding(.leading, 52)
                
                SettingsRow(
                    icon: "envelope.fill",
                    title: "Зв'язатися з нами",
                    color: .green,
                    showChevron: true
                ) {
                    // TODO: Contact
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            
            // Версія додатку
            Text("Версія 1.0.0")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
        }
    }
}

// MARK: - Supporting Views

/// Швидка статистична картка
struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

/// Значок досягнення
struct AchievementBadge: View {
    let icon: String
    let title: String
    let description: String
    let isUnlocked: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? color : .gray)
            }
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isUnlocked ? .primary : .secondary)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 100)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .opacity(isUnlocked ? 1 : 0.6)
    }
}

/// Рядок налаштувань
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    var subtitle: String?
    var showChevron: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - ViewModel

@MainActor
class ProfileTabViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var userName: String = ""
    @Published var userAge: Int?
    @Published var testsCompleted: Int = 0
    @Published var favoritesCount: Int = 0
    @Published var plansCount: Int = 0
    @Published var profileImageData: Data?
    
    // MARK: - Computed Properties
    
    var initials: String {
        let components = userName.components(separatedBy: " ")
        let initials = components.compactMap { $0.first }.map { String($0) }
        return initials.prefix(2).joined().uppercased()
    }
    
    // MARK: - Services
    
    private let userProfileService = UserProfileService.shared
    private let favoritesService = FavoritesService.shared
    private let historyService = TestHistoryService.shared
    
    // MARK: - Methods
    
    func loadProfile() {
        let profile = userProfileService.getProfile()
        userName = profile.name.isEmpty ? "Користувач" : profile.name
        userAge = profile.age
        profileImageData = userProfileService.getProfileImage()
        
        loadStatistics()
    }
    
    func updateProfile(name: String, age: Int) {
        userProfileService.saveProfile(name: name, age: age)
        userName = name
        userAge = age
        
        print("✅ Profile updated: \(name), age: \(age)")
    }
    
    func updateProfileImage(_ imageData: Data?) {
        userProfileService.saveProfileImage(imageData)
        profileImageData = imageData
        
        print("✅ Profile image updated")
    }
    
    func loadStatistics() {
        // Тести
        let history = historyService.getHistory()
        testsCompleted = history.count
        
        // Улюблені
        favoritesCount = favoritesService.count
        
        // Плани
        let plans = UserDefaults.standard.array(forKey: "SavedDevelopmentPlans") as? [[String: Any]] ?? []
        plansCount = plans.count
    }
}

// MARK: - Preview

#Preview {
    ProfileTab()
}
