//
//  SavedDevelopmentPlan.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 13.02.2026.
//

import Foundation

/// Збережений план розвитку кар'єри
struct SavedDevelopmentPlan: Identifiable {
    let id = UUID()
    let date: Date
    let category: String
    let confidence: Double
    let planText: String
}
