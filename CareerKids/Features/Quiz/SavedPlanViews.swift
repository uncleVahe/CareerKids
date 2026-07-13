//
//  SavedPlanViews.swift
//  CareerKids
//
//  Винесено з видаленого SavedPlansView.swift — SavedPlanRow і SavedPlanDetailView
//  реально використовуються в PlansTab.swift (сам екран SavedPlansView вже ніде
//  не викликався і був видалений).
//

import SwiftUI
import PDFKit

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

                Image(systemName: categoryIcon(for: plan.category))
                    .foregroundColor(categoryColor(for: plan.category))
            }

            HStack {
                Text(formatDate(plan.date))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

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

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.systemBlue
            ]
            let title = "План розвитку кар'єри"
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 20

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

            let categoryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.systemPurple
            ]
            let categoryText = "Категорія: \(plan.category)"
            categoryText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: categoryAttributes)
            yPosition += 30

            let confidenceAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.darkGray
            ]
            let confidenceText = "Впевненість: \(Int(plan.confidence * 100))%"
            confidenceText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: confidenceAttributes)
            yPosition += 30

            let lineY = yPosition
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: margin, y: lineY))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: lineY))
            context.cgContext.strokePath()
            yPosition += 20

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
