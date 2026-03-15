//
//  QuizViewModel.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI
import Combine

@MainActor
class QuizViewModel: ObservableObject {
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswers: [String: QuizAnswer] = [:]
    @Published var showResult = false
    @Published var quizResult: QuizResult?
    @Published var isProcessingAnswer = false // Запобігає подвійному натисканню
    
    // Завантажуємо питання з JSON файлу
    let questions: [QuizQuestion] = DataLoaderService.shared.loadQuizQuestions()
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    var canGoBack: Bool {
        currentQuestionIndex > 0 && !isProcessingAnswer
    }
    
    func selectAnswer(_ answer: QuizAnswer) {
        // Запобігаємо подвійному натисканню
        guard !isProcessingAnswer else { return }
        guard let question = currentQuestion else { return }
        
        isProcessingAnswer = true
        selectedAnswers[question.id] = answer
        
        // Перехід до наступного питання з затримкою
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.nextQuestion()
            // Дозволяємо нові натискання після анімації
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isProcessingAnswer = false
            }
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
        var customAnswersTexts: [String] = []
        
        // Рахуємо скільки разів вибрана кожна категорія
        for answer in selectedAnswers.values {
            if answer.isCustom {
                // Зберігаємо власні відповіді для AI
                customAnswersTexts.append(answer.text)
            } else {
                // Рахуємо стандартні відповіді
                for category in answer.careerCategories {
                    categoryScores[category, default: 0] += 1
                }
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
            recommendedCareers: recommendedCareers,
            customAnswers: customAnswersTexts
        )
        
        // Зберігаємо статистику в профіль
        saveTestStatistics(topCategory: topCategory)
        
        withAnimation(.spring()) {
            showResult = true
        }
    }
    
    /// Зберігає статистику тесту в профіль користувача
    private func saveTestStatistics(topCategory: CareerCategory) {
        // Збільшуємо лічильник пройдених тестів
        let currentCount = UserDefaults.standard.integer(forKey: "testsCompleted")
        UserDefaults.standard.set(currentCount + 1, forKey: "testsCompleted")
        
        // Зберігаємо топ категорію
        UserDefaults.standard.set(topCategory.rawValue, forKey: "lastTopCategory")
        
        // Зберігаємо результат в історію тестів
        if let result = quizResult {
            TestHistoryService.shared.saveTest(result: result)
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


