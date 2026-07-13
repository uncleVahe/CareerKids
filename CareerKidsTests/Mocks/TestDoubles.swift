//
//  TestDoubles.swift
//  CareerKidsTests
//
//  Мок-реалізації протоколів DI-шару. Тримаємо їх окремо від *Tests.swift,
//  бо кілька test-класів (Quiz, Profile, Careers) ділять одні й ті самі дублери.
//

import Foundation
@testable import CareerKids

// MARK: - TestHistoryManaging

final class MockTestHistoryService: TestHistoryManaging {

    private(set) var savedResults: [QuizResult] = []
    private(set) var deletedIds: [String] = []
    private(set) var clearAllCallCount = 0

    /// Підстав сюди фікстуру перед тестом — це те, що поверне getHistory()/getLastTest()/getTestCount()
    var stubbedHistory: [TestHistoryRecord] = []

    func saveTest(result: QuizResult) {
        savedResults.append(result)
    }

    func getHistory() -> [TestHistoryRecord] {
        stubbedHistory
    }

    func deleteTest(id: String) {
        deletedIds.append(id)
        stubbedHistory.removeAll { $0.id == id }
    }

    func clearAll() {
        clearAllCallCount += 1
        stubbedHistory.removeAll()
    }

    func getLastTest() -> TestHistoryRecord? {
        stubbedHistory.first
    }

    func getTestCount() -> Int {
        stubbedHistory.count
    }

    func getTests(for category: CareerCategory) -> [TestHistoryRecord] {
        stubbedHistory.filter { $0.topCategory == category.rawValue }
    }
}

// MARK: - CareerDataLoading

final class MockCareerDataLoader: CareerDataLoading {

    var stubbedCareers: [Career] = []
    var stubbedQuestions: [QuizQuestion] = []

    func loadCareers() -> [Career] {
        stubbedCareers
    }

    func loadQuizQuestions() -> [QuizQuestion] {
        stubbedQuestions
    }
}

// MARK: - Fixtures

/// Спільні фікстури, щоб тести не плодили однакові літерали QuizQuestion/QuizAnswer.
enum QuizFixtures {

    /// 2 питання: перше з відповіддю в .technology, друге — .technology і .creative,
    /// плюс одна "власна" відповідь щоб покрити customAnswers-гілку.
    static func twoQuestions() -> [QuizQuestion] {
        [
            QuizQuestion(
                id: "q1",
                question: "Що подобається?",
                emoji: "🎮",
                answers: [
                    QuizAnswer(id: "q1a1", text: "Код", careerCategories: [.technology]),
                    QuizAnswer(id: "q1a2", text: "Малювання", careerCategories: [.creative])
                ]
            ),
            QuizQuestion(
                id: "q2",
                question: "А ще що?",
                emoji: "🔬",
                answers: [
                    QuizAnswer(id: "q2a1", text: "Роботи", careerCategories: [.technology]),
                    QuizAnswer(id: "q2a2", text: "Своя відповідь", careerCategories: [], isCustom: true)
                ],
                allowsCustomAnswer: true
            )
        ]
    }
}
