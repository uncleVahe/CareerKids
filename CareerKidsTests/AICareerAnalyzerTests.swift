//
//  AICareerAnalyzerTests.swift
//  CareerKidsTests
//
//  AICareerAnalyzer — чиста функція (нема I/O, нема .shared стейту, який читається),
//  тому це найдешевша і найцінніша ціль для unit-тестів у всьому проєкті.
//

import XCTest
@testable import CareerKids

final class AICareerAnalyzerTests: XCTestCase {

    private let sut = AICareerAnalyzer.shared

    // MARK: - Confidence

    func test_confidence_matchesTopPercentage() {
        let result = QuizResult(
            topCategory: .technology,
            percentages: [.technology: 75, .creative: 25],
            recommendedCareers: [],
            customAnswers: []
        )
        let profile = UserProfile(name: "Тест", age: 14, hasCompletedOnboarding: true)

        let recommendation = sut.analyzeQuizResults(quizResult: result, userProfile: profile)

        XCTAssertEqual(recommendation.confidence, 0.75, accuracy: 0.0001)
    }

    func test_confidence_emptyPercentages_defaultsToHalf() {
        // Edge case: юзер відповів тільки "своїми" відповідями, categoryScores порожній —
        // calculateConfidence має guard-fallback на 0.5, а не ділення на нуль/crash.
        let result = QuizResult(topCategory: .technology, percentages: [:], recommendedCareers: [], customAnswers: ["хочу подорожувати"])
        let profile = UserProfile(name: "Тест", age: 14, hasCompletedOnboarding: true)

        let recommendation = sut.analyzeQuizResults(quizResult: result, userProfile: profile)

        XCTAssertEqual(recommendation.confidence, 0.5, accuracy: 0.0001)
    }

    func test_confidenceText_thresholdBoundaries() {
        XCTAssertEqual(makeRecommendation(confidencePercentage: 80).confidenceText, "Дуже впевнений")
        XCTAssertEqual(makeRecommendation(confidencePercentage: 79).confidenceText, "Впевнений")
        XCTAssertEqual(makeRecommendation(confidencePercentage: 60).confidenceText, "Впевнений")
        XCTAssertEqual(makeRecommendation(confidencePercentage: 59).confidenceText, "Помірно впевнений")
        XCTAssertEqual(makeRecommendation(confidencePercentage: 40).confidenceText, "Помірно впевнений")
        XCTAssertEqual(makeRecommendation(confidencePercentage: 39).confidenceText, "Потрібно більше даних")
    }

    // MARK: - Age group boundary (11 vs 12 — межа young/teen в getAgeGroup)

    func test_additionalCareers_age11_returnsYoungBucket() {
        let recommendation = analyze(category: .technology, percentage: 50, age: 11)

        XCTAssertTrue(recommendation.additionalCareers.contains("Тестувальник ПЗ"))
        XCTAssertFalse(recommendation.additionalCareers.contains("DevOps інженер"))
    }

    func test_additionalCareers_age12_returnsNonYoungBucket() {
        let recommendation = analyze(category: .technology, percentage: 50, age: 12)

        XCTAssertTrue(recommendation.additionalCareers.contains("DevOps інженер"))
        XCTAssertFalse(recommendation.additionalCareers.contains("Тестувальник ПЗ"))
    }

    func test_additionalCareers_nilAge_defaultsToTeenBucket() {
        // getAgeGroup(nil) -> .teen за замовчуванням, тобто НЕ young-гілка
        let recommendation = analyze(category: .technology, percentage: 50, age: nil)

        XCTAssertTrue(recommendation.additionalCareers.contains("DevOps інженер"))
    }

    // MARK: - Threshold: категорії <= 20% не потрапляють у additionalCareers

    func test_additionalCareers_excludesCategoriesAtOrBelow20Percent() {
        let result = QuizResult(
            topCategory: .technology,
            percentages: [.technology: 60, .creative: 20, .science: 20],
            recommendedCareers: [],
            customAnswers: []
        )
        let profile = UserProfile(name: "Тест", age: 15, hasCompletedOnboarding: true)

        let recommendation = sut.analyzeQuizResults(quizResult: result, userProfile: profile)

        // .creative і .science рівно на межі (20%), фільтр `where percentage > 20` мусить їх відсікти
        XCTAssertFalse(recommendation.additionalCareers.contains("UX/UI дизайнер"))
        XCTAssertFalse(recommendation.additionalCareers.contains("Біоінженер"))
    }

    // MARK: - Custom answers keyword matching

    func test_customAnswers_keywordMatch_addsRelatedCareers() {
        let result = QuizResult(
            topCategory: .technology,
            percentages: [.technology: 100],
            recommendedCareers: [],
            customAnswers: ["Люблю малювати щось нове"]
        )
        let profile = UserProfile(name: "Тест", age: 13, hasCompletedOnboarding: true)

        let recommendation = sut.analyzeQuizResults(quizResult: result, userProfile: profile)

        XCTAssertTrue(recommendation.additionalCareers.contains("Художник"))
    }

    func test_customAnswers_noKeywordMatch_addsNothingExtra() {
        let result = QuizResult(
            topCategory: .technology,
            percentages: [:], // топ-категорії немає, щоб виключити внесок generateAdditionalCareers
            recommendedCareers: [],
            customAnswers: ["xyz123 незрозумілий текст без ключових слів"]
        )
        let profile = UserProfile(name: "Тест", age: 13, hasCompletedOnboarding: true)

        let recommendation = sut.analyzeQuizResults(quizResult: result, userProfile: profile)

        XCTAssertTrue(recommendation.additionalCareers.isEmpty)
    }

    // MARK: - Helpers

    private func analyze(category: CareerCategory, percentage: Int, age: Int?) -> AICareerRecommendation {
        let result = QuizResult(topCategory: category, percentages: [category: percentage], recommendedCareers: [], customAnswers: [])
        let profile = UserProfile(name: "Тест", age: age, hasCompletedOnboarding: true)
        return sut.analyzeQuizResults(quizResult: result, userProfile: profile)
    }

    private func makeRecommendation(confidencePercentage: Int) -> AICareerRecommendation {
        analyze(category: .technology, percentage: confidencePercentage, age: 14)
    }
}
