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

    private let historyService: TestHistoryManaging
    private let dataLoader: CareerDataLoading

    // Завантажуємо питання з JSON файлу
    let questions: [QuizQuestion]

    /// Task замість вкладених DispatchQueue.asyncAfter — має cancellation,
    /// тому якщо ViewModel деалокується (юзер вийшов з квізу) під час 0.6с
    /// анімаційної затримки, перехід до наступного питання просто не відбудеться,
    /// замість того щоб стріляти в задеалокований/змінений стан.
    private var advanceTask: Task<Void, Never>?

    init(historyService: TestHistoryManaging = TestHistoryService.shared,
         dataLoader: CareerDataLoading = DataLoaderService.shared) {
        self.historyService = historyService
        self.dataLoader = dataLoader
        self.questions = dataLoader.loadQuizQuestions()
    }

    deinit {
        advanceTask?.cancel()
    }

    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        // questions.count == 0 (наприклад, дефолтний DataLoaderService провалив завантаження
        // ще й fallback повернув порожній масив) інакше давав би +inf, а не 0/1 —
        // ProgressView(value:) з infinite вилітає в SwiftUI шумними warning-ами про layout.
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
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

        advanceTask?.cancel()
        advanceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard let self, !Task.isCancelled else { return }
            self.nextQuestion()

            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            self.isProcessingAnswer = false
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

        // Розраховуємо відсотки відносно кількості "голосів" за категорії, а не
        // кількості відповідей: одна відповідь може голосувати за 2+ категорії одразу
        // (див. фолбек-дані: careerCategories: [.creative, .art]), а custom-відповіді
        // не голосують взагалі. Ділення на selectedAnswers.count (як було) робило так,
        // що percentages по категоріях не сумувались у 100% — знайдено юніт-тестом.
        let totalVotes = categoryScores.values.reduce(0, +)
        var percentages: [CareerCategory: Int] = [:]
        if totalVotes > 0 {
            for (category, score) in categoryScores {
                percentages[category] = (score * 100) / totalVotes
            }
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
    
    /// Зберігає результат тесту в історію.
    /// Раніше тут ще дублювались лічильник "testsCompleted" і "lastTopCategory" напряму
    /// в UserDefaults.standard — жива екранна логіка (ProfileTabViewModel) їх не читає,
    /// вона вже рахує все з historyService.getHistory(), тому ці два write були мертвим кодом
    /// і другим джерелом правди на той самий стан. Прибрано.
    private func saveTestStatistics(topCategory: CareerCategory) {
        if let result = quizResult {
            historyService.saveTest(result: result)
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


