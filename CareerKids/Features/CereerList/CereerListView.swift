//
// CareerListView.swift
// CareerKids
//
// Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI

struct CareerListView: View {
    @StateObject var viewModel = CareerListViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.careers) { career in
                        NavigationLink(destination: CareerDetailView(career: career)) {
                            CareerCard(career: career)
                        }
                        .buttonStyle(PlainButtonStyle()) // щоб картка не змінювала колір
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
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
        }
        .onAppear {
            viewModel.loadCareers()
            
            let profile = UserProfileService.shared.getProfile()
            print("👤 User: \(profile.name), Age: \(profile.age ?? 0)")
        }
    }
}

#Preview {
    CareerListView()
}
