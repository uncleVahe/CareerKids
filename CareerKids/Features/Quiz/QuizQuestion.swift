//
//  QuizQuestion.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 08.01.2026.
//

import SwiftUI

struct QuizQuestion: Identifiable {
    let id: String
    let question: String
    let emoji: String
    let answers: [QuizAnswer]
}

struct QuizAnswer: Identifiable {
    let id: String
    let text: String
    let careerCategories: [CareerCategory]
}

enum CareerCategory: String, CaseIterable {
    case technology = "Технології"
    case creative = "Творчість"
    case science = "Наука"
    case business = "Бізнес"
    case social = "Люди"
    case sports = "Спорт"
    case art = "Мистецтво"
    case nature = "Природа"
    
    var color: Color {
        switch self {
        case .technology: return .blue
        case .creative: return .purple
        case .science: return .green
        case .business: return .orange
        case .social: return .pink
        case .sports: return .red
        case .art: return .indigo
        case .nature: return .teal
        }
    }
    
    var icon: String {
        switch self {
        case .technology: return "laptopcomputer"
        case .creative: return "paintbrush.fill"
        case .science: return "flask.fill"
        case .business: return "briefcase.fill"
        case .social: return "person.3.fill"
        case .sports: return "figure.run"
        case .art: return "music.note"
        case .nature: return "leaf.fill"
        }
    }
}

struct QuizResult {
    let topCategory: CareerCategory
    let percentages: [CareerCategory: Int]
    let recommendedCareers: [String]
}
