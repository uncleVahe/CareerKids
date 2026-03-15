//
//  SharedViews.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 13.02.2026.
//

import SwiftUI
import UIKit

// MARK: - Share Sheet

/// UIKit wrapper для системного sheet для шарингу
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// MARK: - Models

/// Збережений план розвитку кар'єри
struct SavedDevelopmentPlan: Identifiable {
    let id = UUID()
    let date: Date
    let category: String
    let confidence: Double
    let planText: String
}
