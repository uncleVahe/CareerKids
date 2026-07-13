//
//  TestHistoryService.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 25.02.2026.
//

import Foundation

/// Абстракція над TestHistoryService для DI/тестів — інжектуй мок замість .shared у ViewModel-ах
protocol TestHistoryManaging {
    func saveTest(result: QuizResult)
    func getHistory() -> [TestHistoryRecord]
    func deleteTest(id: String)
    func clearAll()
    func getLastTest() -> TestHistoryRecord?
    func getTestCount() -> Int
    func getTests(for category: CareerCategory) -> [TestHistoryRecord]
}

/// Сервіс для роботи з історією пройдених тестів
final class TestHistoryService: TestHistoryManaging {

    // MARK: - Singleton

    static let shared = TestHistoryService()

    // MARK: - Private Properties

    private let storageKey = "TestHistory"
    private let defaults: UserDefaults

    // MARK: - Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    // MARK: - Public Methods
    
    /// Зберігає результат тесту в історію
    /// - Parameter result: Результат пройденого тесту
    func saveTest(result: QuizResult) {
        let record = TestHistoryRecord.from(result: result)
        
        var history = getHistory()
        history.insert(record, at: 0) // Додаємо на початок
        
        // Зберігаємо максимум 50 тестів
        if history.count > 50 {
            history = Array(history.prefix(50))
        }
        
        saveHistory(history)
        
        print("✅ Test saved to history. Total: \(history.count)")
    }
    
    /// Отримує всю історію тестів
    /// - Returns: Масив записів про тести, відсортований за датою (від нових до старих)
    func getHistory() -> [TestHistoryRecord] {
        guard let data = defaults.data(forKey: storageKey) else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let history = try decoder.decode([TestHistoryRecord].self, from: data)
            return history.sorted { $0.date > $1.date }
        } catch {
            print("❌ Error decoding test history: \(error)")
            return []
        }
    }
    
    /// Видаляє конкретний тест з історії
    /// - Parameter id: ID тесту для видалення
    func deleteTest(id: String) {
        var history = getHistory()
        history.removeAll { $0.id == id }
        saveHistory(history)
        
        print("✅ Test deleted. Remaining: \(history.count)")
    }
    
    /// Очищає всю історію тестів
    func clearAll() {
        defaults.removeObject(forKey: storageKey)
        print("✅ Test history cleared")
    }
    
    /// Отримує останній пройдений тест
    /// - Returns: Останній запис тесту або nil
    func getLastTest() -> TestHistoryRecord? {
        return getHistory().first
    }
    
    /// Отримує кількість пройдених тестів
    /// - Returns: Загальна кількість тестів
    func getTestCount() -> Int {
        return getHistory().count
    }
    
    /// Отримує тести за категорією
    /// - Parameter category: Категорія професії
    /// - Returns: Масив тестів цієї категорії
    func getTests(for category: CareerCategory) -> [TestHistoryRecord] {
        return getHistory().filter { $0.topCategory == category.rawValue }
    }
    
    // MARK: - Private Methods
    
    private func saveHistory(_ history: [TestHistoryRecord]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(history)
            defaults.set(data, forKey: storageKey)
        } catch {
            print("❌ Error encoding test history: \(error)")
        }
    }
}
