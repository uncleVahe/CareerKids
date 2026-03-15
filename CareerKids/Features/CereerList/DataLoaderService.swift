//
//  DataLoaderService.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 04.02.2026.
//

import Foundation
import SwiftUI

/// Сервіс для завантаження даних з JSON файлів
/// Відповідає за парсинг та надання даних про професії та питання тестів
class DataLoaderService {
    
    // MARK: - Singleton
    
    static let shared = DataLoaderService()
    
    // MARK: - Private Init
    
    private init() {}
    
    // MARK: - Career Loading
    
    /// Завантажує список професій з JSON файлу
    /// - Returns: Масив професій
    func loadCareers() -> [Career] {
        guard let url = Bundle.main.url(forResource: "careers_data", withExtension: "json") else {
            print("❌ careers_data.json not found")
            return fallbackCareers()
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(CareersResponse.self, from: data)
            
            let careers = response.careers.map { careerData in
                Career(
                    id: careerData.id,
                    title: careerData.title,
                    description: careerData.shortDescription,
                    icon: careerData.icon,
                    color: colorFromString(careerData.color),
                    category: categoryFromString(careerData.category)
                )
            }
            
            print("✅ Loaded \(careers.count) careers from JSON")
            return careers
            
        } catch {
            print("❌ Error loading careers: \(error)")
            return fallbackCareers()
        }
    }
    
    /// Резервні дані якщо JSON не завантажився
    private func fallbackCareers() -> [Career] {
        return [
            Career(id: "1", title: "Програміст", description: "Створює додатки", icon: "laptopcomputer", color: .blue, category: .technology),
            Career(id: "2", title: "Дизайнер", description: "Малює інтерфейси", icon: "paintbrush.fill", color: .purple, category: .creative),
            Career(id: "3", title: "Вчитель", description: "Навчає дітей", icon: "book.fill", color: .green, category: .social),
            Career(id: "4", title: "Лікар", description: "Лікує людей", icon: "heart.fill", color: .red, category: .science),
            Career(id: "5", title: "Інженер", description: "Будує механізми", icon: "gearshape.fill", color: .orange, category: .technology)
        ]
    }
    
    // MARK: - Quiz Loading
    
    /// Завантажує питання тесту з JSON файлу
    /// - Returns: Масив питань
    func loadQuizQuestions() -> [QuizQuestion] {
        guard let url = Bundle.main.url(forResource: "quiz_questions", withExtension: "json") else {
            print("❌ quiz_questions.json not found")
            return fallbackQuestions()
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(QuizQuestionsResponse.self, from: data)
            
            let questions = response.questions.map { questionData in
                QuizQuestion(
                    id: questionData.id,
                    question: questionData.question,
                    emoji: questionData.emoji,
                    answers: questionData.answers.map { answerData in
                        QuizAnswer(
                            id: answerData.id,
                            text: answerData.text,
                            careerCategories: answerData.categories.compactMap { categoryString in
                                categoryFromString(categoryString)
                            }
                        )
                    }
                )
            }
            
            print("✅ Loaded \(questions.count) quiz questions from JSON")
            return questions
            
        } catch {
            print("❌ Error loading quiz questions: \(error)")
            return fallbackQuestions()
        }
    }
    
    /// Резервні питання якщо JSON не завантажився
    private func fallbackQuestions() -> [QuizQuestion] {
        return [
            QuizQuestion(
                id: "1",
                question: "Що тобі найбільше подобається робити у вільний час?",
                emoji: "🎮",
                answers: [
                    QuizAnswer(id: "1a", text: "Грати в комп'ютерні ігри", careerCategories: [.technology]),
                    QuizAnswer(id: "1b", text: "Малювати або створювати щось руками", careerCategories: [.creative, .art]),
                    QuizAnswer(id: "1c", text: "Читати книжки або дізнаватись нове", careerCategories: [.science]),
                    QuizAnswer(id: "1d", text: "Гратись з друзями", careerCategories: [.social, .sports])
                ]
            )
        ]
    }
    
    // MARK: - Helper Methods
    
    /// Конвертує рядок в колір
    private func colorFromString(_ string: String) -> Color {
        switch string.lowercased() {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "red": return .red
        case "orange": return .orange
        case "pink": return .pink
        case "yellow": return .yellow
        case "indigo": return .indigo
        case "teal": return .teal
        default: return .blue
        }
    }
    
    /// Конвертує рядок в категорію професії
    private func categoryFromString(_ string: String) -> CareerCategory? {
        switch string.lowercased() {
        case "technology": return .technology
        case "creative": return .creative
        case "science": return .science
        case "business": return .business
        case "social": return .social
        case "sports": return .sports
        case "art": return .art
        case "nature": return .nature
        default: return nil
        }
    }
}

// MARK: - JSON Response Models

/// Відповідь з JSON файлу з професіями
struct CareersResponse: Codable {
    let careers: [CareerData]
}

/// Дані професії з JSON
struct CareerData: Codable {
    let id: String
    let title: String
    let shortDescription: String
    let icon: String
    let color: String
    let category: String
}

/// Відповідь з JSON файлу з питаннями
struct QuizQuestionsResponse: Codable {
    let questions: [QuizQuestionData]
}

/// Дані питання з JSON
struct QuizQuestionData: Codable {
    let id: String
    let question: String
    let emoji: String
    let answers: [QuizAnswerData]
}

/// Дані відповіді з JSON
struct QuizAnswerData: Codable {
    let id: String
    let text: String
    let categories: [String]
}
