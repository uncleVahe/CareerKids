//
//  TestHistory.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 06.02.2026.
//

import Foundation

/// Запис про пройдений тест
struct TestHistoryRecord: Identifiable, Codable {
    let id: String
    let date: Date
    let topCategory: String // CareerCategory.rawValue
    let percentages: [String: Int] // [CareerCategory.rawValue: percentage]
    let recommendedCareers: [String]
    let customAnswers: [String]
    
    init(id: String = UUID().uuidString, 
         date: Date = Date(), 
         topCategory: String, 
         percentages: [String: Int], 
         recommendedCareers: [String], 
         customAnswers: [String]) {
        self.id = id
        self.date = date
        self.topCategory = topCategory
        self.percentages = percentages
        self.recommendedCareers = recommendedCareers
        self.customAnswers = customAnswers
    }
    
    /// Конвертує в QuizResult для відображення
    func toQuizResult() -> QuizResult? {
        guard let category = CareerCategory(rawValue: topCategory) else { return nil }
        
        var categoryPercentages: [CareerCategory: Int] = [:]
        for (key, value) in percentages {
            if let cat = CareerCategory(rawValue: key) {
                categoryPercentages[cat] = value
            }
        }
        
        return QuizResult(
            topCategory: category,
            percentages: categoryPercentages,
            recommendedCareers: recommendedCareers,
            customAnswers: customAnswers
        )
    }
    
    /// Створює запис з QuizResult
    static func from(result: QuizResult) -> TestHistoryRecord {
        var percentages: [String: Int] = [:]
        for (category, value) in result.percentages {
            percentages[category.rawValue] = value
        }
        
        return TestHistoryRecord(
            topCategory: result.topCategory.rawValue,
            percentages: percentages,
            recommendedCareers: result.recommendedCareers,
            customAnswers: result.customAnswers
        )
    }
}
