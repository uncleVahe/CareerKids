//
//  CareerDetailView.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI

struct CareerDetailView: View {
    let career: Career
    @State private var isInterested = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Велика іконка зверху
                ZStack {
                    Circle()
                        .fill(career.color.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: career.icon)
                        .font(.system(size: 60))
                        .foregroundColor(career.color)
                }
                .padding(.top, 20)
                
                // Назва
                                Text(career.title)
                                    .font(.system(size: 32, weight: .bold))
                                
                                // Опис
                                Text(career.description)
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                // Детальна інформація
                                VStack(alignment: .leading, spacing: 16) {
                                    InfoRow(
                                        icon: "graduationcap.fill",
                                        title: "Навчання",
                                        description: "Університет або курси програмування"
                                    )
                                    
                                    InfoRow(
                                        icon: "dollarsign.circle.fill",
                                        title: "Зарплата",
                                        description: "30,000 - 150,000 грн/місяць"
                                    )
                                    
                                    InfoRow(
                                        icon: "star.fill",
                                        title: "Навички",
                                        description: "Логіка, математика, англійська"
                                    )
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .padding(.horizontal)
                                
                                // Кнопка "Цікаво!"
                                Button(action: {
                                    withAnimation(.spring()) {
                                        isInterested.toggle()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: isInterested ? "heart.fill" : "heart")
                                            .font(.title2)
                                        
                                        Text(isInterested ? "Додано в обране!" : "Цікаво!")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(isInterested ? Color.green : career.color)
                                    .cornerRadius(16)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                
                                Spacer()
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }

                // Допоміжний компонент для інфо рядків
                struct InfoRow: View {
                    let icon: String
                    let title: String
                    let description: String
                    
                    var body: some View {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(title)
                                    .font(.headline)
                                
                                Text(description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                #Preview {
                    NavigationView {
                        CareerDetailView(career: Career(
                            id: "1",
                            title: "Програміст",
                            description: "Створює додатки та веб-сайти",
                            icon: "laptopcomputer",
                            color: .blue
                        ))
                    }
                }
