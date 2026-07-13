//
//  CareerDetailView.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI

struct CareerDetailView: View {
    let career: Career
    
    // Відстежуємо стан favorites
    @State private var isFavorite: Bool = false
    private let favoritesService = FavoritesService.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(career.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: career.icon)
                        .font(.system(size: 60))
                        .foregroundColor(career.color)
                }
                .padding(.top, 20)
                
                // Title
                Text(career.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Description
                Text(career.description)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Info rows
                VStack(spacing: 12) {
                    InfoRow(
                        icon: "graduationcap.fill",
                        title: "Навчання",
                        description: "Університет або курси програмування",
                        color: .blue
                    )
                    
                    InfoRow(
                        icon: "dollarsign.circle.fill",
                        title: "Зарплата",
                        description: "30,000 - 150,000 грн/місяць",
                        color: .green
                    )
                    
                    InfoRow(
                        icon: "star.fill",
                        title: "Навички",
                        description: "Логіка, математика, англійська",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 0)
                
                //Синхронізована з Favorites
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        favoritesService.toggleFavorite(career.id)
                        isFavorite.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title3)
                        
                        Text(isFavorite ? "Додано в обране!" : "Цікаво!")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFavorite ? Color.green : Color.blue)
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Перевіряємо чи вже в favorites
            isFavorite = favoritesService.isFavorite(career.id)
        }
    }
}

// InfoRow component
struct InfoRow: View {
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        CareerDetailView(
            career: Career(
                id: "programmer",
                title: "Програміст",
                description: "Створює додатки та веб-сайти",
                icon: "laptopcomputer",
                color: .blue,
                category: .technology
            )
        )
    }
}
