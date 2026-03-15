//
//  QuizzesTab.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 25.02.2026.
//

import SwiftUI
import Combine

/// Таб з тестами - показує доступні тести та швидкий старт
struct QuizzesTab: View {
    
    // MARK: - State
    
    @StateObject private var viewModel = QuizzesTabViewModel()
    @State private var showQuiz = false
    @State private var selectedQuizType: QuizType = .career
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Заголовок секції
                    headerSection
                    
                    // Головний тест (великий)
                    mainQuizCard
                    
                    // Додаткові тести (скоро)
                    upcomingQuizzesSection
                    
                    // Статистика
                    if viewModel.hasCompletedTests {
                        statisticsSection
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Тести")
            .fullScreenCover(isPresented: $showQuiz) {
                QuizView()
            }
            .onAppear {
                viewModel.loadStatistics()
            }
        }
    }
    
    // MARK: - UI Components
    
    /// Заголовок секції
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Дізнайся більше про себе")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Пройди тести та отримай персоналізовані рекомендації")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Головна картка з тестом
    private var mainQuizCard: some View {
        Button(action: {
            selectedQuizType = .career
            showQuiz = true
        }) {
            VStack(spacing: 0) {
                // Верхня частина з градієнтом
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    
                    Text("Тест на професію")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("20 питань · 5-7 хвилин")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Нижня частина з інфо
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("AI аналіз результатів")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Персоналізовані рекомендації")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("План розвитку кар'єри")
                            .font(.subheadline)
                    }
                    
                    if viewModel.completedTestsCount > 0 {
                        Divider()
                            .padding(.vertical, 4)
                        
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                            Text("Пройдено: \(viewModel.completedTestsCount) раз(и)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
            }
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        }
        .buttonStyle(QuizScaleButtonStyle())
    }
    
    /// Секція майбутніх тестів
    private var upcomingQuizzesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Скоро доступні")
                .font(.title3)
                .fontWeight(.semibold)
            
            // Тест на навички
            UpcomingQuizCard(
                icon: "star.fill",
                title: "Тест на навички",
                description: "Визнач свої сильні сторони",
                color: .orange,
                comingSoon: true
            )
            
            // Тест на особистість
            UpcomingQuizCard(
                icon: "person.fill",
                title: "Тест особистості",
                description: "Дізнайся більше про свій характер",
                color: .pink,
                comingSoon: true
            )
            
            // Тест на IQ
            UpcomingQuizCard(
                icon: "lightbulb.fill",
                title: "Інтелект тест",
                description: "Перевір свої когнітивні здібності",
                color: .green,
                comingSoon: true
            )
        }
    }
    
    /// Статистика проходження
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Твоя статистика")
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                StatCard(
                    value: "\(viewModel.completedTestsCount)",
                    label: "Пройдено тестів",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    value: "\(viewModel.discoveredCareersCount)",
                    label: "Знайдено професій",
                    icon: "star.fill",
                    color: .orange
                )
            }
        }
    }
}

// MARK: - Supporting Views

/// Картка майбутнього тесту
struct UpcomingQuizCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let comingSoon: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if comingSoon {
                Text("Скоро")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(color)
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

/// Картка статистики
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

/// Стиль кнопки зі scale ефектом для QuizzesTab
struct QuizScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Quiz Type

enum QuizType {
    case career
    case skills
    case personality
    case iq
}

// MARK: - ViewModel

@MainActor
class QuizzesTabViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var completedTestsCount = 0
    @Published var discoveredCareersCount = 0
    @Published var hasCompletedTests = false
    
    // MARK: - Methods
    
    func loadStatistics() {
        // Завантажуємо статистику з TestHistoryService
        let history = TestHistoryService.shared.getHistory()
        completedTestsCount = history.count
        hasCompletedTests = completedTestsCount > 0
        
        // Підраховуємо унікальні професії
        var allCareers = Set<String>()
        for record in history {
            allCareers.formUnion(record.recommendedCareers)
        }
        discoveredCareersCount = allCareers.count
    }
}

// MARK: - Preview

#Preview {
    QuizzesTab()
}
