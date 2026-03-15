//
//  HistoryTab.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 25.02.2026.
//

import SwiftUI
import Combine

/// Таб з історією пройдених тестів
struct HistoryTab: View {
    
    // MARK: - State
    
    @StateObject private var viewModel = HistoryTabViewModel()
    @State private var selectedTest: TestHistoryRecord?
    @State private var showDeleteAlert = false
    @State private var testToDelete: TestHistoryRecord?
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.history.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .navigationTitle("Історія тестів")
            .toolbar {
                if !viewModel.history.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(role: .destructive, action: {
                                viewModel.clearAllHistory()
                            }) {
                                Label("Очистити історію", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(item: $selectedTest) { test in
                if let result = test.toQuizResult() {
                    NavigationView {
                        QuizResultView(
                            result: result,
                            onRestart: {
                                selectedTest = nil
                            },
                            onClose: {
                                selectedTest = nil
                            }
                        )
                    }
                }
            }
            .alert("Видалити тест?", isPresented: $showDeleteAlert) {
                Button("Скасувати", role: .cancel) {
                    testToDelete = nil
                }
                Button("Видалити", role: .destructive) {
                    if let test = testToDelete {
                        viewModel.deleteTest(test)
                        testToDelete = nil
                    }
                }
            } message: {
                Text("Цю дію не можна скасувати")
            }
            .onAppear {
                viewModel.loadHistory()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "clock")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                Text("Немає історії")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Пройди свій перший тест\nщоб побачити результати тут")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            NavigationLink(destination: QuizView()) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Почати тест")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - History List
    
    private var historyListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Статистика
                statisticsSection
                
                // Список тестів
                testsListSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    /// Секція зі статистикою
    private var statisticsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Всього тестів
                StatBox(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.history.count)",
                    label: "Тестів",
                    color: .green
                )
                
                // Унікальних категорій
                StatBox(
                    icon: "folder.fill",
                    value: "\(viewModel.uniqueCategories)",
                    label: "Категорій",
                    color: .blue
                )
                
                // Знайдено професій
                StatBox(
                    icon: "star.fill",
                    value: "\(viewModel.totalCareersDiscovered)",
                    label: "Професій",
                    color: .orange
                )
            }
        }
    }
    
    /// Секція зі списком тестів
    private var testsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Пройдені тести")
                .font(.title3)
                .fontWeight(.semibold)
            
            ForEach(viewModel.history) { record in
                TestHistoryCard(record: record) {
                    selectedTest = record
                }
                .contextMenu {
                    Button(role: .destructive, action: {
                        testToDelete = record
                        showDeleteAlert = true
                    }) {
                        Label("Видалити", systemImage: "trash")
                    }
                }
            }
        }
    }
}

// MARK: - Stat Box

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - ViewModel

@MainActor
class HistoryTabViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var history: [TestHistoryRecord] = []
    @Published var uniqueCategories: Int = 0
    @Published var totalCareersDiscovered: Int = 0
    
    // MARK: - Services
    
    private let historyService = TestHistoryService.shared
    
    // MARK: - Methods
    
    func loadHistory() {
        history = historyService.getHistory()
        calculateStatistics()
    }
    
    func deleteTest(_ test: TestHistoryRecord) {
        historyService.deleteTest(id: test.id)
        loadHistory()
    }
    
    func clearAllHistory() {
        historyService.clearAll()
        loadHistory()
    }
    
    private func calculateStatistics() {
        // Унікальні категорії
        let categories = Set(history.map { $0.topCategory })
        uniqueCategories = categories.count
        
        // Всі знайдені професії
        var allCareers = Set<String>()
        for record in history {
            allCareers.formUnion(record.recommendedCareers)
        }
        totalCareersDiscovered = allCareers.count
    }
}

// MARK: - Preview

#Preview {
    HistoryTab()
}
