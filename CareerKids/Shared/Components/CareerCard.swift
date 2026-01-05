//
// CareerCard.swift
// CareerKids
//
// Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI

struct CareerCard: View {
    let career: Career
    
    var body: some View {
        HStack(spacing: 16) {
            // Іконка
            ZStack {
                Circle()
                    .fill(career.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: career.icon)
                    .font(.system(size: 28))
                    .foregroundColor(career.color)
            }
            
            // Текст
            VStack(alignment: .leading, spacing: 4) {
                Text(career.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(career.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Стрілка
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    CareerCard(career: Career(
        id: "1",
        title: "Програміст",
        description: "Створює додатки та веб-сайти",
        icon: "laptopcomputer",
        color: .blue
    ))
    .padding()
}
