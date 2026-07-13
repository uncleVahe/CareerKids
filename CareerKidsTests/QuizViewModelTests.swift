//
//  QuizViewModelTests.swift
//  CareerKidsTests
//

import XCTest
@testable import CareerKids

@MainActor
final class QuizViewModelTests: XCTestCase {

    private var historyService: MockTestHistoryService!
    private var dataLoader: MockCareerDataLoader!
    private var sut: QuizViewModel!

    override func setUp() {
        super.setUp()
        historyService = MockTestHistoryService()
        dataLoader = MockCareerDataLoader()
        dataLoader.stubbedQuestions = QuizFixtures.twoQuestions()
        sut = QuizViewModel(historyService: historyService, dataLoader: dataLoader)
    }

    override func tearDown() {
        historyService = nil
        dataLoader = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - calculateResult

    func test_calculateResult_picksTopCategoryByHighestScore() {
        // 2 голоси .technology, 1 голос .creative → топ має бути .technology
        sut.selectedAnswers = [
            "q1": QuizAnswer(id: "q1a1", text: "Код", careerCategories: [.technology]),
            "q2": QuizAnswer(id: "q2a1", text: "Роботи", careerCategories: [.technology])
        ]

        sut.calculateResult()

        XCTAssertEqual(sut.quizResult?.topCategory, .technology)
        XCTAssertEqual(sut.quizResult?.percentages[.technology], 100)
        XCTAssertTrue(sut.showResult)
    }

    func test_calculateResult_splitVotes_topCategoryIsHigherCount() {
        sut.selectedAnswers = [
            "q1": QuizAnswer(id: "q1a1", text: "Код", careerCategories: [.technology]),
            "q2": QuizAnswer(id: "q2a2", text: "Своя", careerCategories: [.creative])
        ]

        sut.calculateResult()

        // categoryScores: technology=1, creative=1 — max(by:) при рівності бере останній
        // знайдений критерій із суворим "<". Явно фіксуємо контракт, а не здогадуємось.
        XCTAssertNotNil(sut.quizResult?.topCategory)
        XCTAssertEqual(sut.quizResult?.percentages.values.reduce(0, +), 100)
    }

    func test_calculateResult_collectsCustomAnswerTextSeparatelyFromScoring() {
        sut.selectedAnswers = [
            "q1": QuizAnswer(id: "q1a1", text: "Код", careerCategories: [.technology]),
            "q2": QuizAnswer(id: "q2a2", text: "Люблю тварин", careerCategories: [], isCustom: true)
        ]

        sut.calculateResult()

        XCTAssertEqual(sut.quizResult?.customAnswers, ["Люблю тварин"])
        // custom-відповідь не повинна потрапляти в categoryScores/percentages,
        // і не повинна "розбавляти" знаменник — рівно один голос за technology = 100%.
        XCTAssertEqual(sut.quizResult?.percentages[.technology], 100)
    }

    func test_calculateResult_percentagesAlwaysSumTo100_evenWithMultiCategoryAnswers() {
        // Реальні дані (fallbackQuestions) мають відповіді на кшталт
        // careerCategories: [.creative, .art] — одна відповідь голосує за 2 категорії.
        // Якщо ділити на кількість відповідей (як було), сума percentages "втрачає" голоси.
        sut.selectedAnswers = [
            "q1": QuizAnswer(id: "multi", text: "І малюю, і програмую", careerCategories: [.technology, .creative])
        ]

        sut.calculateResult()

        let sum = sut.quizResult?.percentages.values.reduce(0, +)
        XCTAssertEqual(sum, 100)
        XCTAssertEqual(sut.quizResult?.percentages[.technology], 50)
        XCTAssertEqual(sut.quizResult?.percentages[.creative], 50)
    }

    func test_calculateResult_noStandardAnswers_fallsBackToTechnologyWithEmptyPercentages() {
        sut.selectedAnswers = [
            "q2": QuizAnswer(id: "q2a2", text: "Тільки своя відповідь", careerCategories: [], isCustom: true)
        ]

        sut.calculateResult()

        XCTAssertEqual(sut.quizResult?.topCategory, .technology) // дефолт з `?? .technology`
        XCTAssertEqual(sut.quizResult?.percentages, [:])
    }

    func test_calculateResult_savesResultToHistoryService() {
        sut.selectedAnswers = [
            "q1": QuizAnswer(id: "q1a1", text: "Код", careerCategories: [.technology])
        ]

        sut.calculateResult()

        XCTAssertEqual(historyService.savedResults.count, 1)
        XCTAssertEqual(historyService.savedResults.first?.topCategory, .technology)
    }

    // MARK: - restartQuiz

    func test_restartQuiz_resetsAllPublishedState() {
        sut.selectedAnswers = ["q1": QuizAnswer(id: "q1a1", text: "Код", careerCategories: [.technology])]
        sut.currentQuestionIndex = 1
        sut.calculateResult()
        XCTAssertTrue(sut.showResult)

        sut.restartQuiz()

        XCTAssertEqual(sut.currentQuestionIndex, 0)
        XCTAssertTrue(sut.selectedAnswers.isEmpty)
        XCTAssertFalse(sut.showResult)
        XCTAssertNil(sut.quizResult)
    }

    // MARK: - progress edge case

    func test_progress_withEmptyQuestions_isZeroNotInfinite() {
        let emptyLoader = MockCareerDataLoader() // stubbedQuestions лишається []
        let vm = QuizViewModel(historyService: historyService, dataLoader: emptyLoader)

        XCTAssertEqual(vm.progress, 0)
        XCTAssertTrue(vm.progress.isFinite)
    }

    func test_progress_reflectsCurrentQuestionIndex() {
        XCTAssertEqual(sut.progress, 0.5, accuracy: 0.0001) // (0+1)/2
        sut.currentQuestionIndex = 1
        XCTAssertEqual(sut.progress, 1.0, accuracy: 0.0001) // (1+1)/2
    }

    // MARK: - currentQuestion bounds

    func test_currentQuestion_outOfBounds_returnsNilInsteadOfCrashing() {
        sut.currentQuestionIndex = 99
        XCTAssertNil(sut.currentQuestion)
    }

    // MARK: - canGoBack

    func test_canGoBack_falseOnFirstQuestion() {
        XCTAssertFalse(sut.canGoBack)
    }

    func test_canGoBack_falseWhileProcessingAnswer() {
        sut.currentQuestionIndex = 1
        sut.isProcessingAnswer = true
        XCTAssertFalse(sut.canGoBack)
    }

    // MARK: - selectAnswer (async, реальна затримка через Task.sleep)

    func test_selectAnswer_advancesToNextQuestionAfterDelay() async throws {
        let answer = QuizAnswer(id: "q1a1", text: "Код", careerCategories: [.technology])

        sut.selectAnswer(answer)

        XCTAssertTrue(sut.isProcessingAnswer) // одразу після виклику — ще true
        XCTAssertEqual(sut.currentQuestionIndex, 0) // перехід ще не стався

        try await Task.sleep(for: .milliseconds(700)) // трохи більше за 300+300мс з ViewModel

        XCTAssertEqual(sut.currentQuestionIndex, 1)
        XCTAssertFalse(sut.isProcessingAnswer)
        XCTAssertEqual(sut.selectedAnswers["q1"]?.id, "q1a1")
    }

    func test_selectAnswer_ignoredWhileAlreadyProcessing() {
        sut.isProcessingAnswer = true
        let answer = QuizAnswer(id: "q1a1", text: "Код", careerCategories: [.technology])

        sut.selectAnswer(answer)

        // guard !isProcessingAnswer має відсікти повторний виклик — жодного answer не записано
        XCTAssertTrue(sut.selectedAnswers.isEmpty)
    }
}
