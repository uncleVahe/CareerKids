//
//  PlansTab.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 25.02.2026.
//

import SwiftUI
import Combine

/// Таб зі збереженими планами розвитку
struct PlansTab: View {
    
    // MARK: - State
    
    @StateObject private var viewModel = PlansTabViewModel()
    @State private var selectedPlan: SavedDevelopmentPlan?
    @State private var showDeleteAlert = false
    @State private var planToDelete: SavedDevelopmentPlan?
    @State private var showShareSheet = false
    @State private var pdfToShare: URL?
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.savedPlans.isEmpty {
                    emptyStateView
                } else {
                    plansListView
                }
            }
            .navigationTitle("Збережені плани")
            .toolbar {
                if !viewModel.savedPlans.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: { viewModel.sortByDate() }) {
                                Label("За датою", systemImage: "calendar")
                            }
                            
                            Button(action: { viewModel.sortByCategory() }) {
                                Label("За категорією", systemImage: "folder")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive, action: {
                                viewModel.clearAllPlans()
                            }) {
                                Label("Видалити всі", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .sheet(item: $selectedPlan) { plan in
                SavedPlanDetailView(
                    plan: plan,
                    onDelete: {
                        planToDelete = plan
                        showDeleteAlert = true
                        selectedPlan = nil
                    }
                )
                
            }
            .sheet(isPresented: $showShareSheet) {
                if let pdfURL = pdfToShare {
                    ShareSheet(items: [pdfURL])
                }
            }
            .alert("Видалити план?", isPresented: $showDeleteAlert) {
                Button("Скасувати", role: .cancel) {
                    planToDelete = nil
                }
                Button("Видалити", role: .destructive) {
                    if let plan = planToDelete {
                        viewModel.deletePlan(plan)
                        planToDelete = nil
                    }
                }
            } message: {
                Text("Цю дію не можна скасувати")
            }
            .onAppear {
                viewModel.loadPlans()
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
                
                Image(systemName: "doc.text")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                Text("Немає збережених планів")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Пройди тест та збережи свій\nперсональний план розвитку")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            NavigationLink(destination: QuizView()) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Пройти тест")
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
    
    // MARK: - Plans List
    
    private var plansListView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Статистика
                statisticsSection
                
                // Список планів
                plansSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    /// Секція зі статистикою
    private var statisticsSection: some View {
        HStack(spacing: 12) {
            StatBox(
                icon: "doc.fill",
                value: "\(viewModel.savedPlans.count)",
                label: "Планів",
                color: .blue
            )
            
            StatBox(
                icon: "folder.fill",
                value: "\(viewModel.uniqueCategories)",
                label: "Категорій",
                color: .purple
            )
        }
    }
    
    /// Секція зі списком планів
    private var plansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Твої плани розвитку")
                .font(.title3)
                .fontWeight(.semibold)
            
            ForEach(viewModel.savedPlans) { plan in
                SavedPlanRow(plan: plan)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPlan = plan
                    }
                    .contextMenu {
                        Button(action: {
                            Task {
                                if let pdf = await viewModel.exportPlanToPDF(plan) {
                                    pdfToShare = pdf
                                    showShareSheet = true
                                }
                            }
                        }) {
                            Label("Поділитися", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(role: .destructive, action: {
                            planToDelete = plan
                            showDeleteAlert = true
                        }) {
                            Label("Видалити", systemImage: "trash")
                        }
                    }
            }
        }
    }
}

// MARK: - ViewModel

@MainActor
class PlansTabViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var savedPlans: [SavedDevelopmentPlan] = []
    @Published var uniqueCategories: Int = 0
    
    // MARK: - Services
    
    private let pdfGenerator = PDFGeneratorService()
    
    // MARK: - Methods
    
    func loadPlans() {
        let plansData = UserDefaults.standard.array(forKey: "SavedDevelopmentPlans") as? [[String: Any]] ?? []
        
        savedPlans = plansData.compactMap { dict in
            guard let timestamp = dict["date"] as? TimeInterval,
                  let category = dict["category"] as? String,
                  let confidence = dict["confidence"] as? Double,
                  let planText = dict["plan"] as? String else {
                return nil
            }
            
            return SavedDevelopmentPlan(
                date: Date(timeIntervalSince1970: timestamp),
                category: category,
                confidence: confidence,
                planText: planText
            )
        }
        
        calculateStatistics()
    }
    
    func deletePlan(_ plan: SavedDevelopmentPlan) {
        savedPlans.removeAll { $0.id == plan.id }
        savePlansToUserDefaults()
    }
    
    func clearAllPlans() {
        savedPlans.removeAll()
        savePlansToUserDefaults()
    }
    
    func sortByDate() {
        savedPlans.sort { $0.date > $1.date }
    }
    
    func sortByCategory() {
        savedPlans.sort { $0.category < $1.category }
    }
    
    func exportPlanToPDF(_ plan: SavedDevelopmentPlan) async -> URL? {
        return pdfGenerator.generateCareerPlanPDF(plan: plan)
    }
    
    private func calculateStatistics() {
        let categories = Set(savedPlans.map { $0.category })
        uniqueCategories = categories.count
    }
    
    private func savePlansToUserDefaults() {
        let plansData = savedPlans.map { plan in
            [
                "date": plan.date.timeIntervalSince1970,
                "category": plan.category,
                "confidence": plan.confidence,
                "plan": plan.planText
            ] as [String: Any]
        }
        
        UserDefaults.standard.set(plansData, forKey: "SavedDevelopmentPlans")
        calculateStatistics()
    }
}

// MARK: - Preview

#Preview {
    PlansTab()
}
