//
//  ProfileEditView.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 04.02.2026.
//

import SwiftUI
import Combine
import PhotosUI

// MARK: - Protocol для ProfileViewModel

/// Протокол для ViewModels які можуть редагувати профіль
protocol ProfileEditableViewModel: ObservableObject {
    var userName: String { get set }
    var userAge: Int? { get set }
    var profileImageData: Data? { get set }
    func updateProfile(name: String, age: Int)
    func updateProfileImage(_ imageData: Data?)
}

// MARK: - Conformance

extension ProfileTabViewModel: ProfileEditableViewModel {}

/// Екран редагування профілю
/// Дозволяє користувачу змінити ім'я та вік
struct ProfileEditView<ViewModel: ProfileEditableViewModel>: View {
    
    // MARK: - Properties
    
    @ObservedObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var editedName: String = ""
    @State private var editedAge: Int = 10
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @FocusState private var isNameFieldFocused: Bool
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Form {
                // Секція з фото профілю
                Section {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 12) {
                            // Аватар
                            ZStack {
                                if let imageData = selectedImageData ?? viewModel.profileImageData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [.blue, .purple]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                }
                            }
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                            
                            // PhotosPicker для вибору фото
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                HStack {
                                    Image(systemName: "camera.fill")
                                    Text(selectedImageData != nil || viewModel.profileImageData != nil ? "Змінити фото" : "Додати фото")
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                            
                            // Кнопка видалення (якщо є фото)
                            if selectedImageData != nil || viewModel.profileImageData != nil {
                                Button(role: .destructive) {
                                    selectedImageData = nil
                                } label: {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                        Text("Видалити фото")
                                    }
                                    .font(.caption)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Spacer()
                    }
                } header: {
                    Text("Фото профілю")
                }
                
                // Секція з особистими даними
                Section {
                    // Поле для імені
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        TextField("Ім'я", text: $editedName)
                            .focused($isNameFieldFocused)
                            .textContentType(.name)
                    }
                    
                    // Picker для віку
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        
                        Picker("Вік", selection: $editedAge) {
                            ForEach(6...18, id: \.self) { age in
                                Text("\(age) років").tag(age)
                            }
                        }
                    }
                } header: {
                    Text("Особисті дані")
                } footer: {
                    Text("Ця інформація допоможе нам краще підібрати професії")
                        .font(.caption)
                }
                
                // TODO: Додаткові поля (як в вашій ідеї)
                Section {
                    HStack {
                        Image(systemName: "building.2")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        
                        Text("Де навчаєшся")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Скоро")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.purple)
                            .frame(width: 30)
                        
                        Text("Мова")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Скоро")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .frame(width: 30)
                        
                        Text("Інтереси")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Скоро")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } header: {
                    Text("Додаткова інформація")
                } footer: {
                    Text("Ці поля будуть доступні в наступних оновленнях")
                        .font(.caption)
                }
            }
            .navigationTitle("Редагувати профіль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Зберегти") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(editedName.isEmpty || editedName.count < 2)
                }
            }
            .onAppear {
                // Завантажуємо поточні дані
                editedName = viewModel.userName
                editedAge = viewModel.userAge ?? 10
                selectedImageData = viewModel.profileImageData
            }
            .onChange(of: selectedPhotoItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
    }
    
    // MARK: - Methods
    
    /// Зберігає зміни в профілі
    private func saveChanges() {
        viewModel.updateProfile(name: editedName, age: editedAge)
        viewModel.updateProfileImage(selectedImageData)
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    ProfileEditView(viewModel: ProfileTabViewModel())
}
