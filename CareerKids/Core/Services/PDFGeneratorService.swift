//
//  PDFGeneratorService.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 25.02.2026.
//

import Foundation
import UIKit
import PDFKit

/// Сервіс для генерації PDF документів
/// Відповідає за створення PDF з планів розвитку кар'єри
final class PDFGeneratorService {
    
    // MARK: - Public Methods
    
    /// Генерує PDF документ з плану розвитку
    /// - Parameter plan: План розвитку для експорту
    /// - Returns: URL до створеного PDF файлу
    func generateCareerPlanPDF(plan: SavedDevelopmentPlan) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "CareerKids",
            kCGPDFContextAuthor: "AI Career Analyzer",
            kCGPDFContextTitle: "План розвитку кар'єри"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // A4 розмір сторінки
        let pageWidth: CGFloat = 8.5 * 72.0  // 612 points
        let pageHeight: CGFloat = 11.0 * 72.0 // 792 points
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let margin: CGFloat = 50
            var yPosition: CGFloat = margin
            
            // Заголовок
            yPosition = drawTitle(in: context.cgContext, at: yPosition, margin: margin, width: pageWidth)
            
            // Дата створення
            yPosition = drawDate(plan.date, in: context.cgContext, at: yPosition, margin: margin)
            
            // Категорія
            yPosition = drawCategory(plan.category, in: context.cgContext, at: yPosition, margin: margin)
            
            // Впевненість
            yPosition = drawConfidence(plan.confidence, in: context.cgContext, at: yPosition, margin: margin)
            
            // Роздільна лінія
            yPosition = drawDivider(in: context.cgContext, at: yPosition, margin: margin, width: pageWidth)
            
            // Контент плану
            drawPlanContent(
                plan.planText,
                in: context.cgContext,
                startingAt: yPosition,
                margin: margin,
                pageWidth: pageWidth,
                pageHeight: pageHeight
            )
            
            // Футер
            drawFooter(in: context.cgContext, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin)
        }
        
        // Зберігаємо в тимчасову директорію
        let fileName = "CareerPlan_\(UUID().uuidString).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: url)
            return url
        } catch {
            print("❌ Error saving PDF: \(error)")
            return nil
        }
    }
    
    // MARK: - Private Drawing Methods
    
    private func drawTitle(in context: CGContext, at yPosition: CGFloat, margin: CGFloat, width: CGFloat) -> CGFloat {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 28),
            .foregroundColor: UIColor.systemBlue
        ]
        
        let title = "План розвитку кар'єри"
        let titleSize = title.size(withAttributes: titleAttributes)
        
        title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
        
        return yPosition + titleSize.height + 20
    }
    
    private func drawDate(_ date: Date, in context: CGContext, at yPosition: CGFloat, margin: CGFloat) -> CGFloat {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "uk_UA")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        
        let dateText = "Створено: \(dateFormatter.string(from: date))"
        dateText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: dateAttributes)
        
        return yPosition + 30
    }
    
    private func drawCategory(_ category: String, in context: CGContext, at yPosition: CGFloat, margin: CGFloat) -> CGFloat {
        let categoryAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.systemPurple
        ]
        
        let categoryText = "Категорія: \(category)"
        categoryText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: categoryAttributes)
        
        return yPosition + 35
    }
    
    private func drawConfidence(_ confidence: Double, in context: CGContext, at yPosition: CGFloat, margin: CGFloat) -> CGFloat {
        let confidenceAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ]
        
        let confidenceText = "Впевненість: \(Int(confidence * 100))%"
        confidenceText.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: confidenceAttributes)
        
        return yPosition + 30
    }
    
    private func drawDivider(in context: CGContext, at yPosition: CGFloat, margin: CGFloat, width: CGFloat) -> CGFloat {
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: margin, y: yPosition))
        context.addLine(to: CGPoint(x: width - margin, y: yPosition))
        context.strokePath()
        
        return yPosition + 20
    }
    
    private func drawPlanContent(_ text: String, in context: CGContext, startingAt yPosition: CGFloat, margin: CGFloat, pageWidth: CGFloat, pageHeight: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = .left
        
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        let textRect = CGRect(
            x: margin,
            y: yPosition,
            width: pageWidth - (2 * margin),
            height: pageHeight - yPosition - margin - 40
        )
        
        text.draw(in: textRect, withAttributes: contentAttributes)
    }
    
    private func drawFooter(in context: CGContext, pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat) {
        let footerY = pageHeight - margin + 10
        
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.italicSystemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        
        let footerText = "Згенеровано за допомогою CareerKids"
        let footerSize = footerText.size(withAttributes: footerAttributes)
        let footerX = (pageWidth - footerSize.width) / 2
        
        footerText.draw(at: CGPoint(x: footerX, y: footerY), withAttributes: footerAttributes)
    }
}
