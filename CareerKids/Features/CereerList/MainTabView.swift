//
//  MainTabView.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 25.02.2026.
//

import SwiftUI

/// Головний екран додатку з TabBar навігацією
/// Містить 5 основних розділів: Професії, Тести, Історія, Плани, Профіль
struct MainTabView: View {
    
    // MARK: - State
    
    @State private var selectedTab: Tab = .careers
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 1. Професії
            CareersTab()
                .tabItem {
                    Label("Професії", systemImage: "briefcase.fill")
                }
                .tag(Tab.careers)
            
            // 2. Тести
            QuizzesTab()
                .tabItem {
                    Label("Тести", systemImage: "checklist")
                }
                .tag(Tab.quizzes)
            
            // 3. Історія тестів
            HistoryTab()
                .tabItem {
                    Label("Історія", systemImage: "clock.fill")
                }
                .tag(Tab.history)
            
            // 4. Збережені плани
            PlansTab()
                .tabItem {
                    Label("Плани", systemImage: "doc.text.fill")
                }
                .tag(Tab.plans)
            
            // 5. Профіль
            ProfileTab()
                .tabItem {
                    Label("Профіль", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
        .tint(.blue) // Колір активного табу
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    // MARK: - Configuration
    
    /// Налаштовує вигляд TabBar
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Тінь
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Tab Enum

extension MainTabView {
    enum Tab: Int, CaseIterable {
        case careers
        case quizzes
        case history
        case plans
        case profile
        
        var title: String {
            switch self {
            case .careers: return "Професії"
            case .quizzes: return "Тести"
            case .history: return "Історія"
            case .plans: return "Плани"
            case .profile: return "Профіль"
            }
        }
        
        var icon: String {
            switch self {
            case .careers: return "briefcase.fill"
            case .quizzes: return "checklist"
            case .history: return "clock.fill"
            case .plans: return "doc.text.fill"
            case .profile: return "person.fill"
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
