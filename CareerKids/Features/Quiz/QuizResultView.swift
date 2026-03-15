//
// QuizResultView.swift
// CareerKids
//
// Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI

struct QuizResultView: View {
    let result: QuizResult
    let onRestart: () -> Void
    let onClose: () -> Void
    let onViewCareers: ((CareerCategory) -> Void)?
    
    @State private var showAIRecommendations = false
    @State private var aiRecommendation: AICareerRecommendation?
    
    init(result: QuizResult, onRestart: @escaping () -> Void, onClose: @escaping () -> Void, onViewCareers: ((CareerCategory) -> Void)? = nil) {
        self.result = result
        self.onRestart = onRestart
        self.onClose = onClose
        self.onViewCareers = onViewCareers
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 20)
                    
                    // Іконка категорії
                    ZStack {
                        Circle()
                            .fill(result.topCategory.color.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: result.topCategory.icon)
                            .font(.system(size: 60))
                            .foregroundColor(result.topCategory.color)
                    }
                    
                    // Заголовок
                    VStack(spacing: 8) {
                        Text("Твоя категорія:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(result.topCategory.rawValue)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(result.topCategory.color)
                    }
                    
                    // Опис
                    Text("Тобі підходять професії пов'язані з \(result.topCategory.rawValue.lowercased())!")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 30)
                    
                    // Рекомендовані професії
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Рекомендовані професії:")
                            .font(.headline)
                        
                        ForEach(result.recommendedCareers, id: \.self) { career in
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(result.topCategory.color)
                                
                                Text(career)
                                    .font(.body)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Відсотки по категоріям (топ 3)
                    if !result.percentages.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Твої результати:")
                                .font(.headline)
                                .padding(.horizontal, 30)
                            
                            ForEach(result.percentages.sorted(by: { $0.value > $1.value }).prefix(3), id: \.key) { category, percentage in
                                CategoryPercentageView(
                                    category: category,
                                    percentage: percentage
                                )
                                .padding(.horizontal, 30)
                            }
                        }
                    }
                    
                    // Кнопки
                    VStack(spacing: 12) {
                        // Кнопка AI рекомендацій
                        Button(action: {
                            // Generate recommendations synchronously
                            if aiRecommendation == nil {
                                let userProfile = UserProfileService.shared.getProfile()
                                aiRecommendation = AICareerAnalyzer.shared.analyzeQuizResults(
                                    quizResult: result,
                                    userProfile: userProfile
                                )
                            }
                            // Now open the sheet
                            showAIRecommendations = true
                        }) {
                            HStack {
                                Image(systemName: "brain.head.profile")
                                    .font(.headline)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("AI Рекомендації")
                                        .font(.headline)
                                    
                                    Text("Отримай персональний план розвитку")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "sparkles")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.purple, Color.blue]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        Button(action: {
                            if let onViewCareers = onViewCareers {
                                onViewCareers(result.topCategory)
                            } else {
                                onClose()
                            }
                        }) {
                            Text("Переглянути професії")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(result.topCategory.color)
                                .cornerRadius(16)
                        }
                        
                        Button(action: onRestart) {
                            Text("Пройти тест знову")
                                .font(.headline)
                                .foregroundColor(result.topCategory.color)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
            
            // Close button in top-right corner
            Button(action: onClose) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 32, height: 32)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }
            }
            .padding(.top, 50)
            .padding(.trailing, 20)
        }
        .sheet(item: Binding(
            get: { showAIRecommendations ? aiRecommendation : nil },
            set: { _ in showAIRecommendations = false }
        )) { recommendation in
            AIRecommendationView(
                recommendation: recommendation,
                onClose: { showAIRecommendations = false },
                onViewCareers: {
                    showAIRecommendations = false
                    onClose()
                }
            )
        }
        .onAppear {
            // Pre-generate AI recommendations for faster access
            if aiRecommendation == nil {
                let userProfile = UserProfileService.shared.getProfile()
                aiRecommendation = AICareerAnalyzer.shared.analyzeQuizResults(
                    quizResult: result,
                    userProfile: userProfile
                )
            }
        }
    }
    
    // MARK: - Category Percentage View
    struct CategoryPercentageView: View {
        let category: CareerCategory
        let percentage: Int
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .foregroundColor(category.color)
                        
                        Text(category.rawValue)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    Text("\(percentage)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(category.color)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Фон
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        // Прогрес
                        RoundedRectangle(cornerRadius: 4)
                            .fill(category.color)
                            .frame(width: geometry.size.width * CGFloat(percentage) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }
    
    #Preview {
        QuizResultView(
            result: QuizResult(
                topCategory: .technology,
                percentages: [
                    .technology: 80,
                    .creative: 60,
                    .science: 40
                ],
                recommendedCareers: ["Програміст", "Інженер", "Робототехнік"],
                customAnswers: []
            ),
            onRestart: {},
            onClose: {}
        )
    }
}
