//
// CareerListView.swift
// CareerKids
//
// Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI

struct CareerListView: View {
    @StateObject var viewModel = CareerListViewModel()
    @State private var showQuiz = false
    @State private var refreshID = UUID()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    Button(action: {
                        showQuiz = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Не знаєш що обрати?")
                                    .font(.headline)
                                
                                Text("Пройди тест і дізнайся!")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3),
                                radius: 8, x: 0, y: 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    Toggle(isOn: $viewModel.showOnlyFavorites) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Тільки улюблені")
                                .font(.subheadline)
                        }
                    }
                    
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    ForEach(viewModel.filteredCareers) { career in
                        NavigationLink(destination: CareerDetailView(career: career)) {
                            CareerCard(
                                career: career,
                                isFavorite: viewModel.isFavorite(career),
                                onFavoriteTap: {
                                    viewModel.toggleFavorite(career)
                                })
                        }
                        .buttonStyle(PlainButtonStyle()) // щоб картка не змінювала колір
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .id(refreshID)
            }
            .onAppear {
                viewModel.loadCareers()
                refreshID = UUID()
                
                let profile = UserProfileService.shared.getProfile()
                print("👤 User: \(profile.name), Age: \(profile.age ?? 0)")
            }
            .navigationTitle("Професії")
            .background(Color(.systemGroupedBackground))
            .toolbar {
#if DEBUG
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        UserProfileService.shared.clearProfile()
                        exit(0) // Перезапустить додаток (тільки для debug)
                    }
                }
#endif
            }
            .sheet(isPresented: $showQuiz) {
                QuizView()
            }
        }
    }
}

#Preview {
    CareerListView()
}
