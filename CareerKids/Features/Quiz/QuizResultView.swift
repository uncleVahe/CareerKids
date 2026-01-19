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
    
    var body: some View {
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
                    Button(action: onClose) {
                        Text("Дивитись професії")
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
            recommendedCareers: ["Програміст", "Інженер", "Робототехнік"]
        ),
        onRestart: {},
        onClose: {}
    )
}
