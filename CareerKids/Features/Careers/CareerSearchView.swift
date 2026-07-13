//
//  CareerSearchView.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 25.02.2026.
//

import SwiftUI
import Combine

/// Екран пошуку професій
struct CareerSearchView: View {
    
    // MARK: - State
    
    @StateObject private var viewModel = CareerSearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Поле пошуку
                searchBar
                
                // Результати або пусто
                if viewModel.searchText.isEmpty {
                    emptySearchView
                } else if viewModel.searchResults.isEmpty {
                    noResultsView
                } else {
                    searchResultsList
                }
            }
            .navigationTitle("Пошук")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isSearchFocused = true
            }
        }
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Шукати професії...", text: $viewModel.searchText)
                .focused($isSearchFocused)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }
    
    // MARK: - Empty Search
    
    private var emptySearchView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Почни вводити назву професії")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - No Results
    
    private var noResultsView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("Нічого не знайдено")
                .font(.headline)
            
            Text("Спробуй інший запит")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Results List
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.searchResults) { career in
                    NavigationLink(destination: CareerDetailView(career: career)) {
                        SearchResultRow(career: career)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

// MARK: - Search Result Row

struct SearchResultRow: View {
    let career: Career
    
    var body: some View {
        HStack(spacing: 16) {
            // Іконка
            ZStack {
                Circle()
                    .fill(career.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: career.icon)
                    .font(.title3)
                    .foregroundColor(career.color)
            }
            
            // Інформація
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
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - ViewModel

@MainActor
class CareerSearchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var searchText = "" {
        didSet {
            performSearch()
        }
    }
    @Published var searchResults: [Career] = []
    
    // MARK: - Private Properties
    
    private let dataLoader = DataLoaderService.shared
    private var allCareers: [Career] = []
    
    // MARK: - Init
    
    init() {
        allCareers = dataLoader.loadCareers()
    }
    
    // MARK: - Methods
    
    private func performSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        let query = searchText.lowercased()
        
        searchResults = allCareers.filter { career in
            career.title.lowercased().contains(query) ||
            career.description.lowercased().contains(query) ||
            (career.category?.rawValue.lowercased().contains(query) ?? false)
        }
    }
}

// MARK: - Preview

#Preview {
    CareerSearchView()
}
