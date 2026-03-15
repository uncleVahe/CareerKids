//
//  AIRecommendationView.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 04.02.2026.
//

import SwiftUI
import PDFKit

/// Екран з AI рекомендаціями після проходження тесту
/// Показує персоналізовані поради, план розвитку, тренінги
struct AIRecommendationView: View {
    let recommendation: AICareerRecommendation
    let onClose: () -> Void
    let onViewCareers: () -> Void
    
    @State private var selectedTab: RecommendationTab = .overview
    @State private var showShareSheet = false
    @State private var showSaveAlert = false
    @State private var pdfToShare: URL?
    @State private var saveAlertMessage = ""
    @State private var saveAlertTitle = ""
    @State private var isPlanAlreadySaved = false
    
    // MARK: - Services
    
    private let pdfGenerator = PDFGeneratorService()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок з AI іконкою
                    headerSection
                    
                    // Табби
                    tabSelector
                    
                    // Контент залежно від табу
                    switch selectedTab {
                    case .overview:
                        overviewContent
                    case .plan:
                        planContent
                    case .trainings:
                        trainingsContent
                    case .next:
                        nextStepsContent
                    }
                    
                    // Кнопки дій
                    actionButtons
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("AI Рекомендації")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .alert(saveAlertTitle, isPresented: $showSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveAlertMessage)
            }
            .onAppear {
                checkIfPlanAlreadySaved()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // AI іконка
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            
            Text("Персоналізовані рекомендації")
                .font(.title2)
                .fontWeight(.bold)
            
            // Рівень впевненості
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(.green)
                Text("Впевненість: \(recommendation.confidenceText)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.green.opacity(0.1))
            .cornerRadius(20)
        }
        .padding(.vertical)
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(RecommendationTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation {
                            selectedTab = tab
                        }
                    }) {
                        HStack {
                            Image(systemName: tab.icon)
                            Text(tab.title)
                        }
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .foregroundColor(selectedTab == tab ? .white : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(selectedTab == tab ? Color.blue : Color.gray.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    // MARK: - Overview Content
    
    private var overviewContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Персоналізована порада
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Персональна порада")
                        .font(.headline)
                }
                
                Text(recommendation.personalizedAdvice)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Топ категорія
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: recommendation.topCategory.icon)
                        .foregroundColor(recommendation.topCategory.color)
                    Text("Твоя категорія")
                        .font(.headline)
                }
                
                Text(recommendation.topCategory.rawValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(recommendation.topCategory.color)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Рекомендовані професії
            VStack(alignment: .leading, spacing: 12) {
                Text("Основні професії")
                    .font(.headline)
                
                ForEach(recommendation.recommendedCareers, id: \.self) { career in
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text(career)
                            .font(.body)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
            }
            
            // Додаткові професії (AI згенеровані)
            if !recommendation.additionalCareers.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.purple)
                        Text("AI рекомендує також розглянути")
                            .font(.headline)
                    }
                    
                    ForEach(recommendation.additionalCareers, id: \.self) { career in
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(.purple)
                            Text(career)
                                .font(.body)
                            Spacer()
                        }
                        .padding()
                        .background(Color.purple.opacity(0.05))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    // MARK: - Plan Content
    
    private var planContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Загальна інформація
            VStack(alignment: .leading, spacing: 8) {
                Text("Орієнтовний час до кар'єри")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(recommendation.developmentPlan.estimatedTimeToCareer)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            
            // Короткострокові цілі
            goalSection(
                title: "Короткострокові цілі (0-1 рік)",
                icon: "flag.fill",
                color: .green,
                goals: recommendation.developmentPlan.shortTerm
            )
            
            // Середньострокові цілі
            goalSection(
                title: "Середньострокові цілі (1-3 роки)",
                icon: "flag.2.crossed.fill",
                color: .blue,
                goals: recommendation.developmentPlan.mediumTerm
            )
            
            // Довгострокові цілі
            goalSection(
                title: "Довгострокові цілі (3+ роки)",
                icon: "flag.checkered",
                color: .purple,
                goals: recommendation.developmentPlan.longTerm
            )
        }
    }
    
    private func goalSection(title: String, icon: String, color: Color, goals: [DevelopmentGoal]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            
            ForEach(goals) { goal in
                GoalCard(goal: goal, color: color)
            }
        }
    }
    
    // MARK: - Trainings Content
    
    private var trainingsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Рекомендовані тренінги та курси")
                .font(.headline)
            
            ForEach(recommendation.trainings) { training in
                TrainingCard(training: training)
            }
        }
    }
    
    // MARK: - Next Steps Content
    
    private var nextStepsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Що робити далі")
                .font(.headline)
            
            ForEach(Array(recommendation.nextSteps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 30, height: 30)
                        
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Text(step)
                        .font(.body)
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: onViewCareers) {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("Переглянути професії")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    saveDevelopmentPlan()
                }) {
                    HStack {
                        Image(systemName: isPlanAlreadySaved ? "checkmark.circle.fill" : "arrow.down.doc")
                        Text(isPlanAlreadySaved ? "Збережено" : "Зберегти")
                    }
                    .font(.headline)
                    .foregroundColor(isPlanAlreadySaved ? .green : .blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isPlanAlreadySaved ? Color.green : Color.blue, lineWidth: 2)
                    )
                }
                .disabled(isPlanAlreadySaved)
                
                Button(action: {
                    exportToPDF()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("PDF")
                    }
                    .font(.headline)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green, lineWidth: 2)
                    )
                }
            }
        }
        .padding(.top)
        .sheet(isPresented: $showShareSheet) {
            if let pdfURL = pdfToShare {
                ShareSheet(items: [pdfURL])
            }
        }
    }

    // MARK: - Methods
    
    private func checkIfPlanAlreadySaved() {
        let savedPlans = UserDefaults.standard.array(forKey: "SavedDevelopmentPlans") as? [[String: Any]] ?? []
        let planText = formatPlanForSaving()
        
        isPlanAlreadySaved = savedPlans.contains { dict in
            guard let existingPlan = dict["plan"] as? String,
                  let existingCategory = dict["category"] as? String else {
                return false
            }
            return existingCategory == recommendation.topCategory.rawValue && existingPlan == planText
        }
    }
    
    private func saveDevelopmentPlan() {
        // Перевіряємо чи вже є такий план
        let savedPlans = UserDefaults.standard.array(forKey: "SavedDevelopmentPlans") as? [[String: Any]] ?? []
        
        let planText = formatPlanForSaving()
        
        // Перевіряємо чи існує план з таким же контентом
        let isDuplicate = savedPlans.contains { dict in
            guard let existingPlan = dict["plan"] as? String,
                  let existingCategory = dict["category"] as? String else {
                return false
            }
            // Перевіряємо чи співпадають категорія та текст плану
            return existingCategory == recommendation.topCategory.rawValue && existingPlan == planText
        }
        
        if isDuplicate {
            saveAlertTitle = "План вже збережений"
            saveAlertMessage = "Цей план розвитку вже є у вашій колекції"
            showSaveAlert = true
            return
        }
        
        // Зберігаємо план в UserDefaults
        let planData: [String: Any] = [
            "date": Date().timeIntervalSince1970,
            "category": recommendation.topCategory.rawValue,
            "confidence": recommendation.confidence,
            "plan": planText
        ]
        
        var updatedPlans = savedPlans
        updatedPlans.insert(planData, at: 0)
        
        // Зберігаємо максимум 10 планів
        if updatedPlans.count > 10 {
            updatedPlans = Array(updatedPlans.prefix(10))
        }
        
        UserDefaults.standard.set(updatedPlans, forKey: "SavedDevelopmentPlans")
        
        // Оновлюємо статус
        isPlanAlreadySaved = true
        
        // Показуємо успішне збереження
        saveAlertTitle = "План збережено!"
        saveAlertMessage = "Ваш план розвитку збережено і доступний в профілі"
        showSaveAlert = true
    }

private func formatPlanForSaving() -> String {
    var text = "🎯 План розвитку: \(recommendation.topCategory.rawValue)\n\n"
    text += "📚 Короткострокові цілі:\n"
    recommendation.developmentPlan.shortTerm.forEach { goal in text += "• \(goal.title)\n" }
    text += "\n📖 Довгострокові цілі:\n"
    recommendation.developmentPlan.longTerm.forEach { goal in text += "• \(goal.title)\n" }
    text += "\n💡 Поради:\n\(recommendation.personalizedAdvice)\n"
    text += "\n✅ Наступні кроки:\n"
    recommendation.nextSteps.forEach { text += "• \($0)\n" }
    return text
}

private func exportToPDF() {
    let plan = SavedDevelopmentPlan(
        date: Date(),
        category: recommendation.topCategory.rawValue,
        confidence: recommendation.confidence,
        planText: formatPlanForSaving()
    )
    
    if let pdfURL = pdfGenerator.generateCareerPlanPDF(plan: plan) {
        pdfToShare = pdfURL
        showShareSheet = true
    }
}
}

// MARK: - Supporting Views

enum RecommendationTab: CaseIterable {
    case overview, plan, trainings, next
    
    var title: String {
        switch self {
        case .overview: return "Огляд"
        case .plan: return "План"
        case .trainings: return "Курси"
        case .next: return "Далі"
        }
    }
    
    var icon: String {
        switch self {
        case .overview: return "doc.text.fill"
        case .plan: return "map.fill"
        case .trainings: return "graduationcap.fill"
        case .next: return "arrow.right.circle.fill"
        }
    }
}

struct GoalCard: View {
    let goal: DevelopmentGoal
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.title)
                    .font(.headline)
                
                Spacer()
                
                Text(goal.duration)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Text(goal.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !goal.resources.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ресурси:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(goal.resources, id: \.self) { resource in
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .font(.caption)
                                .foregroundColor(color)
                            Text(resource)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 2)
        )
    }
}

struct TrainingCard: View {
    let training: Training
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(training.title)
                        .font(.headline)
                    
                    Text(training.provider)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Складність
                Text(training.difficulty.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(difficultyColor(training.difficulty))
                    .cornerRadius(8)
            }
            
            // Інформація
            HStack {
                Label(training.duration, systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Label(training.type.rawValue, systemImage: "globe")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Вартість
            HStack {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.green)
                Text(training.cost)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            // Навички
            if !training.skills.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Навички:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 6) {
                        ForEach(training.skills, id: \.self) { skill in
                            Text(skill)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Кнопка відкрити
            if let urlString = training.url, let _ = URL(string: urlString) {
                Button(action: {
                    // TODO: Відкрити URL
                }) {
                    HStack {
                        Image(systemName: "arrow.up.right.square")
                        Text("Відкрити курс")
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func difficultyColor(_ difficulty: TrainingDifficulty) -> Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

// Простий FlowLayout для тегів
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        
        for (rowIndex, row) in result.rows.enumerated() {
            let y = bounds.minY + row.yOffset
            for (indexInRow, subviewIndex) in row.subviewIndices.enumerated() {
                let x = bounds.minX + row.xOffsets[indexInRow]
                subviews[subviewIndex].place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            }
        }
    }
    
    struct FlowResult {
        struct Row {
            var yOffset: CGFloat
            var xOffsets: [CGFloat]
            var subviewIndices: [Int]
        }
        
        var rows: [Row] = []
        var height: CGFloat = 0
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var currentRowXOffsets: [CGFloat] = []
            var currentRowIndices: [Int] = []
            var rowHeight: CGFloat = 0
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && !currentRowXOffsets.isEmpty {
                    rows.append(Row(
                        yOffset: currentY,
                        xOffsets: currentRowXOffsets,
                        subviewIndices: currentRowIndices
                    ))
                    currentY += rowHeight + spacing
                    currentX = 0
                    currentRowXOffsets = []
                    currentRowIndices = []
                    rowHeight = 0
                }
                
                currentRowXOffsets.append(currentX)
                currentRowIndices.append(index)
                currentX += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
            
            if !currentRowXOffsets.isEmpty {
                rows.append(Row(
                    yOffset: currentY,
                    xOffsets: currentRowXOffsets,
                    subviewIndices: currentRowIndices
                ))
                currentY += rowHeight
            }
            
            height = currentY
        }
    }
}

// MARK: - Preview

#Preview {
    AIRecommendationView(
        recommendation: AICareerRecommendation(
            topCategory: .technology,
            confidence: 0.85,
            recommendedCareers: ["Програміст", "Інженер", "Робототехнік"],
            additionalCareers: ["Web-розробник", "Тестувальник ПЗ"],
            developmentPlan: DevelopmentPlan(
                shortTerm: [],
                mediumTerm: [],
                longTerm: [],
                estimatedTimeToCareer: "5-7 років"
            ),
            trainings: [],
            personalizedAdvice: "Ти маєш великий потенціал!",
            nextSteps: ["Крок 1", "Крок 2"]
        ),
        onClose: {},
        onViewCareers: {}
    )
}
