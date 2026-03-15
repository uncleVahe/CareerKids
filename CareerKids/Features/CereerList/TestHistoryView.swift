//
//  TestHistoryView.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 06.02.2026.
//

import SwiftUI
import Combine

/// Екран історії пройдених тестів
struct TestHistoryView: View {
    @StateObject private var viewModel = TestHistoryViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTest: TestHistoryRecord?
    @State private var showResult = false
    
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .sheet(item: $selectedTest) { test in
                if let result = test.toQuizResult() {
                    QuizResultView(
                        result: result,
                        onRestart: {
                            // Закриваємо результат і історію
                            selectedTest = nil
                            dismiss()
                        },
                        onClose: {
                            selectedTest = nil
                        }
                    )
                }
            }
            .onAppear {
                viewModel.loadHistory()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Немає пройдених тестів")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Пройди свій перший тест щоб побачити результати тут")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - History List
    
    private var historyListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.history) { record in
                    TestHistoryCard(record: record) {
                        selectedTest = record
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Test History Card

struct TestHistoryCard: View {
    let record: TestHistoryRecord
    let onTap: () -> Void
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        return formatter.string(from: record.date)
    }
    
    private var category: CareerCategory? {
        CareerCategory(rawValue: record.topCategory)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Іконка категорії
                if let category = category {
                    ZStack {
                        Circle()
                            .fill(category.color.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: category.icon)
                            .font(.title2)
                            .foregroundColor(category.color)
                    }
                }
                
                // Інформація
                VStack(alignment: .leading, spacing: 6) {
                    Text(record.topCategory)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Label("\(record.recommendedCareers.count) професій", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                // Стрілка
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - ViewModel

@MainActor
class TestHistoryViewModel: ObservableObject {
    @Published var history: [TestHistoryRecord] = []
    
    private let service = TestHistoryService.shared
    
    func loadHistory() {
        history = service.getHistory()
    }
    
    func deleteTest(id: String) {
        service.deleteTest(id: id)
        loadHistory()
    }
}

// MARK: - Preview

#Preview {
    TestHistoryView()
}
