//
//  SavedPlansView.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 13.02.2026.
//

import SwiftUI
import PDFKit

/// Екран для перегляду збережених планів розвитку
struct SavedPlansView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var savedPlans: [SavedDevelopmentPlan] = []
    @State private var selectedPlan: SavedDevelopmentPlan?
    @State private var showShareSheet = false
    @State private var pdfToShare: URL?
    @State private var showDeleteAlert = false
    @State private var planToDelete: SavedDevelopmentPlan?
    
    var body: some View {
        NavigationView {
            Group {
                if savedPlans.isEmpty {
                    emptyStateView
                } else {
                    plansList
                }
            }
            .navigationTitle("Збережені плани")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрити") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadSavedPlans()
            }
            .sheet(item: $selectedPlan) { plan in
                SavedPlanDetailView(plan: plan, onDelete: {
                    planToDelete = plan
                    showDeleteAlert = true
                    selectedPlan = nil
                })
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
                        deletePlan(plan)
                    }
                }
            } message: {
                Text("Цю дію не можна скасувати")
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Немає збережених планів")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Пройди тест та збережи свій план розвитку")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Plans List
    
    private var plansList: some View {
        List {
            ForEach(savedPlans) { plan in
                SavedPlanRow(plan: plan)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPlan = plan
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            planToDelete = plan
                            showDeleteAlert = true
                        } label: {
                            Label("Видалити", systemImage: "trash")
                        }
                        
                        Button {
                            exportToPDF(plan: plan)
                        } label: {
                            Label("PDF", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Methods
    
    private func loadSavedPlans() {
        let plansData = UserDefaults.standard.array(forKey: "SavedDevelopmentPlans") as? [[String: Any]] ?? []
        
        savedPlans = plansData.compactMap { dict in
            guard let dateTimestamp = dict["date"] as? TimeInterval,
                  let category = dict["category"] as? String,
                  let confidence = dict["confidence"] as? Double,
                  let planText = dict["plan"] as? String else {
                return nil
            }
            
            return SavedDevelopmentPlan(
                date: Date(timeIntervalSince1970: dateTimestamp),
                category: category,
                confidence: confidence,
                planText: planText
            )
        }
    }
    
    private func deletePlan(_ plan: SavedDevelopmentPlan) {
        savedPlans.removeAll { $0.id == plan.id }
        
        // Оновлюємо UserDefaults
        let plansData: [[String: Any]] = savedPlans.map { plan in
            [
                "date": plan.date.timeIntervalSince1970,
                "category": plan.category,
                "confidence": plan.confidence,
                "plan": plan.planText
            ]
        }
        
        UserDefaults.standard.set(plansData, forKey: "SavedDevelopmentPlans")
        planToDelete = nil
    }
    
    private func exportToPDF(plan: SavedDevelopmentPlan) {
        let pdfURL = createPDF(for: plan)
        pdfToShare = pdfURL
        showShareSheet = true
    }
    
    private func createPDF(for plan: SavedDevelopmentPlan) -> URL {
        let pdfMetaData = [
            kCGPDFContextCreator: "CareerKids",
            kCGPDFContextAuthor: "AI Career Analyzer",
            kCGPDFContextTitle: "План розвитку кар'єри"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 8.5 * 72.0
        let pageHeight: CGFloat = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let margin: CGFloat = 50
            var yPosition: CGFloat = margin
            
            // Заголовок
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.systemBlue
            ]
            let title = "План розвитку кар'єри"
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 20
            
            // Дата
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            let dateText = "Створено: \(dateFormatter.string(from: plan.date))"
            dateText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: dateAttributes)
            yPosition += 30
            
            // Категорія
            let categoryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.systemPurple
            ]
            let categoryText = "Категорія: \(plan.category)"
            categoryText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: categoryAttributes)
            yPosition += 30
            
            // Впевненість
            let confidenceAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.darkGray
            ]
            let confidenceText = "Впевненість: \(Int(plan.confidence * 100))%"
            confidenceText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: confidenceAttributes)
            yPosition += 30
            
            // Роздільна лінія
            let lineY = yPosition
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: margin, y: lineY))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: lineY))
            context.cgContext.strokePath()
            yPosition += 20
            
            // Контент плану
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            let fullAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            let textRect = CGRect(
                x: margin,
                y: yPosition,
                width: pageWidth - (2 * margin),
                height: pageHeight - yPosition - margin
            )
            
            plan.planText.draw(in: textRect, withAttributes: fullAttributes)
            
            // Футер
            let footerY = pageHeight - margin + 10
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            let footerText = "Згенеровано за допомогою CareerKids"
            footerText.draw(at: CGPoint(x: margin, y: footerY), withAttributes: footerAttributes)
        }
        
        // Зберігаємо PDF у тимчасову папку
        let fileName = "CareerPlan_\(UUID().uuidString).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: url)
        } catch {
            print("Error saving PDF: \(error)")
        }
        
        return url
    }
}

// MARK: - Saved Plan Row

struct SavedPlanRow: View {
    let plan: SavedDevelopmentPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(plan.category)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Іконка категорії
                Image(systemName: categoryIcon(for: plan.category))
                    .foregroundColor(categoryColor(for: plan.category))
            }
            
            HStack {
                Text(formatDate(plan.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Індикатор впевненості
                HStack(spacing: 4) {
                    Image(systemName: "brain.head.profile")
                        .font(.caption)
                    Text("\(Int(plan.confidence * 100))%")
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func categoryIcon(for category: String) -> String {
        // Повертаємо іконку на основі назви категорії
        switch category {
        case "Технології": return "laptopcomputer"
        case "Творчість": return "paintbrush.fill"
        case "Наука": return "flask.fill"
        case "Бізнес": return "briefcase.fill"
        case "Люди": return "person.3.fill"
        case "Спорт": return "figure.run"
        case "Мистецтво": return "music.note"
        case "Природа": return "leaf.fill"
        default: return "star.fill"
        }
    }
    
    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Технології": return .blue
        case "Творчість": return .purple
        case "Наука": return .green
        case "Бізнес": return .orange
        case "Люди": return .pink
        case "Спорт": return .red
        case "Мистецтво": return .indigo
        case "Природа": return .teal
        default: return .gray
        }
    }
}

// MARK: - Saved Plan Detail View

struct SavedPlanDetailView: View {
    let plan: SavedDevelopmentPlan
    let onDelete: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var pdfToShare: URL?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Заголовок
                    VStack(alignment: .leading, spacing: 8) {
                        Text(plan.category)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(formatDate(plan.date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "brain.head.profile")
                            Text("Впевненість: \(Int(plan.confidence * 100))%")
                                .font(.subheadline)
                        }
                        .foregroundColor(.blue)
                    }
                    .padding()
                    
                    Divider()
                    
                    // Контент плану
                    Text(plan.planText)
                        .font(.body)
                        .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("Деталі плану")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрити") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            exportToPDF()
                        }) {
                            Label("Експортувати PDF", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(role: .destructive, action: {
                            onDelete()
                            dismiss()
                        }) {
                            Label("Видалити", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let pdfURL = pdfToShare {
                    ShareSheet(items: [pdfURL])
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func exportToPDF() {
        let pdfURL = createPDF(for: plan)
        pdfToShare = pdfURL
        showShareSheet = true
    }
    
    private func createPDF(for plan: SavedDevelopmentPlan) -> URL {
        // Використовуємо ту ж саму функцію створення PDF
        let pdfMetaData = [
            kCGPDFContextCreator: "CareerKids",
            kCGPDFContextAuthor: "AI Career Analyzer",
            kCGPDFContextTitle: "План розвитку кар'єри"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth: CGFloat = 8.5 * 72.0
        let pageHeight: CGFloat = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let margin: CGFloat = 50
            var yPosition: CGFloat = margin
            
            // Заголовок
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.systemBlue
            ]
            let title = "План розвитку кар'єри"
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 20
            
            // Дата
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            let dateText = "Створено: \(dateFormatter.string(from: plan.date))"
            dateText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: dateAttributes)
            yPosition += 30
            
            // Категорія
            let categoryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.systemPurple
            ]
            let categoryText = "Категорія: \(plan.category)"
            categoryText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: categoryAttributes)
            yPosition += 30
            
            // Впевненість
            let confidenceAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.darkGray
            ]
            let confidenceText = "Впевненість: \(Int(plan.confidence * 100))%"
            confidenceText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: confidenceAttributes)
            yPosition += 30
            
            // Роздільна лінія
            let lineY = yPosition
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: margin, y: lineY))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: lineY))
            context.cgContext.strokePath()
            yPosition += 20
            
            // Контент плану
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            
            let fullAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            let textRect = CGRect(
                x: margin,
                y: yPosition,
                width: pageWidth - (2 * margin),
                height: pageHeight - yPosition - margin
            )
            
            plan.planText.draw(in: textRect, withAttributes: fullAttributes)
            
            // Футер
            let footerY = pageHeight - margin + 10
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 10),
                .foregroundColor: UIColor.gray
            ]
            let footerText = "Згенеровано за допомогою CareerKids"
            footerText.draw(at: CGPoint(x: margin, y: footerY), withAttributes: footerAttributes)
        }
        
        let fileName = "CareerPlan_\(UUID().uuidString).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: url)
        } catch {
            print("Error saving PDF: \(error)")
        }
        
        return url
    }
}

// MARK: - Preview

#Preview {
    SavedPlansView()
}
