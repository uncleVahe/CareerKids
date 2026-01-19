//
//  QuizViewModel.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI
import Combine

class QuizViewModel: ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswers: [String: QuizAnswer] = [:]
    @Published var showResult = false
    @Published var quizResult: QuizResult?
    
    let questions: [QuizQuestion] = [
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
        ),
        QuizQuestion(
            id: "2",
            question: "Який предмет тобі найцікавіше вчити в школі?",
            emoji: "📚",
            answers: [
                QuizAnswer(id: "2a", text: "Математика або інформатика", careerCategories: [.technology, .science]),
                QuizAnswer(id: "2b", text: "Малювання або музика", careerCategories: [.art, .creative]),
                QuizAnswer(id: "2c", text: "Природознавство або біологія", careerCategories: [.science, .nature]),
                QuizAnswer(id: "2d", text: "Фізкультура", careerCategories: [.sports])
            ]
        ),
        QuizQuestion(
            id: "3",
            question: "Яку ти хочеш мати суперсилу?",
            emoji: "⚡",
            answers: [
                QuizAnswer(id: "3a", text: "Розуміти всю техніку і роботів", careerCategories: [.technology]),
                QuizAnswer(id: "3b", text: "Створювати красиві речі з нічого", careerCategories: [.creative, .art]),
                QuizAnswer(id: "3c", text: "Знати відповіді на всі питання", careerCategories: [.science]),
                QuizAnswer(id: "3d", text: "Розуміти людей і допомагати їм", careerCategories: [.social])
            ]
        ),
        QuizQuestion(
            id: "4",
            question: "Де б ти хотів працювати в майбутньому?",
            emoji: "🏢",
            answers: [
                QuizAnswer(id: "4a", text: "В офісі з комп'ютерами", careerCategories: [.technology, .business]),
                QuizAnswer(id: "4b", text: "В студії або майстерні", careerCategories: [.creative, .art]),
                QuizAnswer(id: "4c", text: "В лабораторії або на природі", careerCategories: [.science, .nature]),
                QuizAnswer(id: "4d", text: "З людьми (лікарня, школа)", careerCategories: [.social])
            ]
        ),
        QuizQuestion(
            id: "5",
            question: "Що тебе найбільше мотивує?",
            emoji: "🎯",
            answers: [
                QuizAnswer(id: "5a", text: "Створювати нові технології", careerCategories: [.technology]),
                QuizAnswer(id: "5b", text: "Виражати себе через творчість", careerCategories: [.creative, .art]),
                QuizAnswer(id: "5c", text: "Робити наукові відкриття", careerCategories: [.science]),
                QuizAnswer(id: "5d", text: "Допомагати іншим людям", careerCategories: [.social])
            ]
        )
    ]
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    var canGoBack: Bool {
        currentQuestionIndex > 0
    }
    
    func selectAnswer(_ answer: QuizAnswer) {
        guard let question = currentQuestion else { return }
        selectedAnswers[question.id] = answer
        
        // Перехід до наступного питання
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.nextQuestion()
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.spring()) {
                currentQuestionIndex += 1
            }
        } else {
            // Закінчили тест - показуємо результат
            calculateResult()
        }
    }
    
    func previousQuestion() {
        if currentQuestionIndex > 0 {
            withAnimation(.spring()) {
                currentQuestionIndex -= 1
            }
        }
    }
    
    func calculateResult() {
        var categoryScores: [CareerCategory: Int] = [:]
        
        // Рахуємо скільки разів вибрана кожна категорія
        for answer in selectedAnswers.values {
            for category in answer.careerCategories {
                categoryScores[category, default: 0] += 1
            }
        }
        
        // Знаходимо топ категорію
        let topCategory = categoryScores.max(by: { $0.value < $1.value })?.key ?? .technology
        
        // Розраховуємо відсотки
        let totalAnswers = selectedAnswers.count
        var percentages: [CareerCategory: Int] = [:]
        for (category, score) in categoryScores {
            percentages[category] = (score * 100) / totalAnswers
        }
        
        // Рекомендовані професії
        let recommendedCareers = getRecommendedCareers(for: topCategory)
        
        quizResult = QuizResult(
            topCategory: topCategory,
            percentages: percentages,
            recommendedCareers: recommendedCareers
        )
        
        withAnimation(.spring()) {
            showResult = true
        }
    }
    
    func getRecommendedCareers(for category: CareerCategory) -> [String] {
        switch category {
        case .technology:
            return ["Програміст", "Інженер", "Робототехнік"]
        case .creative:
            return ["Дизайнер", "Архітектор", "Аніматор"]
        case .science:
            return ["Вчений", "Лікар", "Біолог"]
        case .business:
            return ["Підприємець", "Менеджер", "Економіст"]
        case .social:
            return ["Вчитель", "Психолог", "Соціальний працівник"]
        case .sports:
            return ["Спортсмен", "Тренер", "Фізіотерапевт"]
        case .art:
            return ["Художник", "Музикант", "Актор"]
        case .nature:
            return ["Еколог", "Ветеринар", "Агроном"]
        }
    }
    
    func restartQuiz() {
        currentQuestionIndex = 0
        selectedAnswers = [:]
        showResult = false
        quizResult = nil
    }
}


