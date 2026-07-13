//
//  TestHistoryCard.swift
//  CareerKids
//
//  Винесено з видаленого TestHistoryView.swift — цей компонент реально
//  використовується в HistoryTab.swift (сам TestHistoryView вже ніде не викликався
//  і був видалений разом з TestHistoryViewModel).
//

import SwiftUI

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
