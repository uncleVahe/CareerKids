//
//  CareerExtended.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 04.02.2026.
//

import Foundation
import SwiftUI

// MARK: - Extended Career Model (Simple version without Codable issues)

/// Розширена модель професії з детальною інформацією
struct CareerExtended: Identifiable {
    let id: String
    let title: String
    let shortDescription: String
    let fullDescription: String
    let icon: String
    let colorName: String
    let category: CareerCategory
    let subcategory: String?
    
    // Детальна інформація
    let education: Education
    let salary: SalaryRange
    let skills: [Skill]
    let workEnvironment: WorkEnvironment
    let careerPath: CareerPath
    
    // Додаткові матеріали
    let famousPeople: [FamousPerson]?
    let videoURLs: [String]?
    let relatedCareers: [String]?
    
    /// Конвертація в просту модель Career
    func toCareer() -> Career {
        Career(
            id: id,
            title: title,
            description: shortDescription,
            icon: icon,
            color: colorFromString(colorName),
            category: category
        )
    }
    
    private func colorFromString(_ name: String) -> Color {
        switch name.lowercased() {
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
}

// MARK: - Education

struct Education {
    let requiredLevel: EducationLevel
    let duration: String
    let subjects: [String]
    let universities: [University]?
    let onlineCourses: [OnlineCourse]?
    let certifications: [String]?
}

enum EducationLevel: String {
    case school = "Школа"
    case vocational = "ПТУ/Коледж"
    case bachelor = "Бакалавр"
    case master = "Магістр"
    case phd = "Доктор наук"
    case courses = "Курси"
    case selfTaught = "Самонавчання"
}

struct University: Identifiable {
    let id: String
    let name: String
    let city: String
    let country: String
    let specialty: String
    let websiteURL: String?
}

struct OnlineCourse: Identifiable {
    let id: String
    let name: String
    let platform: String
    let duration: String
    let price: String
    let url: String?
}

// MARK: - Salary

struct SalaryRange {
    let currency: String
    let period: SalaryPeriod
    let juniorMin: Int
    let juniorMax: Int
    let middleMin: Int
    let middleMax: Int
    let seniorMin: Int
    let seniorMax: Int
    let region: String
    
    var juniorFormatted: String {
        "\(juniorMin.formatted()) - \(juniorMax.formatted()) \(currency)/\(period.rawValue)"
    }
    
    var middleFormatted: String {
        "\(middleMin.formatted()) - \(middleMax.formatted()) \(currency)/\(period.rawValue)"
    }
    
    var seniorFormatted: String {
        "\(seniorMin.formatted()) - \(seniorMax.formatted()) \(currency)/\(period.rawValue)"
    }
}

enum SalaryPeriod: String {
    case month = "міс"
    case year = "рік"
    case hour = "год"
}

// MARK: - Skills

struct Skill: Identifiable {
    let id: String
    let name: String
    let type: SkillType
    let importance: SkillImportance
    let description: String?
}

enum SkillType: String {
    case hard = "Технічна"
    case soft = "М'яка"
    case language = "Мова"
    case tool = "Інструмент"
}

enum SkillImportance: String {
    case essential = "Обов'язкова"
    case important = "Важлива"
    case useful = "Корисна"
    case optional = "Опціональна"
    
    var color: Color {
        switch self {
        case .essential: return .red
        case .important: return .orange
        case .useful: return .blue
        case .optional: return .gray
        }
    }
}

// MARK: - Work Environment

struct WorkEnvironment {
    let locations: [WorkLocation]
    let schedule: WorkSchedule
    let remoteWork: RemoteWorkAvailability
    let physicalDemand: PhysicalDemand
    let travelRequired: Bool
    let teamSize: TeamSize
}

enum WorkLocation: String {
    case office = "Офіс"
    case home = "Дім"
    case outdoor = "На вулиці"
    case lab = "Лабораторія"
    case hospital = "Лікарня"
    case school = "Школа"
    case factory = "Завод"
    case shop = "Магазин"
    case mixed = "Різні місця"
}

enum WorkSchedule: String {
    case fullTime = "Повний день"
    case partTime = "Частковий"
    case flexible = "Гнучкий"
    case shifts = "Змінний"
    case freelance = "Фріланс"
}

enum RemoteWorkAvailability: String {
    case yes = "Так"
    case no = "Ні"
    case hybrid = "Гібрид"
    case possible = "Можлива"
}

enum PhysicalDemand: String {
    case low = "Низьке"
    case medium = "Середнє"
    case high = "Високе"
}

enum TeamSize: String {
    case solo = "Один"
    case small = "2-5 людей"
    case medium = "6-15 людей"
    case large = "16+ людей"
}

// MARK: - Career Path

struct CareerPath {
    let entry: CareerLevel
    let middle: CareerLevel
    let senior: CareerLevel
    let timeToMiddle: String
    let timeToSenior: String
}

struct CareerLevel {
    let title: String
    let responsibilities: [String]
    let typicalAge: String?
}

// MARK: - Famous Person

struct FamousPerson: Identifiable {
    let id: String
    let name: String
    let achievement: String
    let imageURL: String?
    let bio: String?
}
