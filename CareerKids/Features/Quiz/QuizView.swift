//
// QuizView.swift
// CareerKids
//
// Created by Vahe Bazikyan on 19.12.2025.
//

import SwiftUI

struct QuizView: View {
    @StateObject var viewModel = QuizViewModel()
    @Environment(\.dismiss) var dismiss
    var onViewCareersWithCategory: ((CareerCategory) -> Void)?
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if viewModel.showResult, let result = viewModel.quizResult {
                // Результат тесту
                QuizResultView(
                    result: result,
                    onRestart: {
                        viewModel.restartQuiz()
                    },
                    onClose: {
                        dismiss()
                    },
                    onViewCareers: { category in
                        dismiss()
                        onViewCareersWithCategory?(category)
                    }
                )
            } else {
                // Питання тесту
                VStack(spacing: 0) {
                    // Header з прогресом
                    QuizHeaderView(
                        progress: viewModel.progress,
                        currentQuestion: viewModel.currentQuestionIndex + 1,
                        totalQuestions: viewModel.questions.count,
                        canGoBack: viewModel.canGoBack,
                        onBack: { viewModel.previousQuestion() },
                        onClose: { dismiss() }
                    )
                    
                    // Питання
                    if let question = viewModel.currentQuestion {
                        QuizQuestionView(
                            question: question,
                            onAnswerSelected: { answer in
                                viewModel.selectAnswer(answer)
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .id(question.id) // Важливо для анімації
                    }
                }
            }
        }
    }
}

// MARK: - Quiz Header
struct QuizHeaderView: View {
    let progress: Double
    let currentQuestion: Int
    let totalQuestions: Int
    let canGoBack: Bool
    let onBack: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Кнопка назад
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                }
                .opacity(canGoBack ? 1 : 0)
                .disabled(!canGoBack)
                
                Spacer()
                
                // Лічильник питань
                Text("\(currentQuestion)/\(totalQuestions)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Кнопка закрити
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal)
            
            // Progress bar
            ProgressView(value: progress)
                .tint(.blue)
                .padding(.horizontal)
        }
        .padding(.top)
    }
}

// MARK: - Quiz Question
struct QuizQuestionView: View {
    let question: QuizQuestion
    let onAnswerSelected: (QuizAnswer) -> Void
    
    @State private var customAnswerText: String = ""
    @State private var showCustomInput: Bool = false
    @FocusState private var isCustomFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Emoji
            Text(question.emoji)
                .font(.system(size: 80))
            
            // Питання
            Text(question.question)
                .font(.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // Відповіді
            VStack(spacing: 12) {
                ForEach(question.answers) { answer in
                    Button(action: {
                        onAnswerSelected(answer)
                    }) {
                        Text(answer.text)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                // Кнопка "Свій варіант" якщо дозволено
                if question.allowsCustomAnswer {
                    Button(action: {
                        withAnimation {
                            showCustomInput.toggle()
                            if showCustomInput {
                                isCustomFieldFocused = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text(showCustomInput ? "Сховати" : "Написати свій варіант")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Поле для власної відповіді
                    if showCustomInput {
                        VStack(spacing: 12) {
                            TextField("Твоя відповідь...", text: $customAnswerText)
                                .textFieldStyle(.roundedBorder)
                                .focused($isCustomFieldFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    submitCustomAnswer()
                                }
                            
                            Button(action: {
                                submitCustomAnswer()
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                    Text("Підтвердити")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(customAnswerText.isEmpty ? Color.gray : Color.green)
                                .cornerRadius(12)
                            }
                            .disabled(customAnswerText.isEmpty)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
    
    private func submitCustomAnswer() {
        guard !customAnswerText.isEmpty else { return }
        
        // Створюємо власну відповідь з порожніми категоріями
        // AI пізніше проаналізує текст
        let customAnswer = QuizAnswer(
            id: UUID().uuidString,
            text: customAnswerText,
            careerCategories: [], // AI визначить категорії
            isCustom: true
        )
        
        onAnswerSelected(customAnswer)
        customAnswerText = ""
        showCustomInput = false
    }
}

// Анімація натискання
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

#Preview {
    QuizView()
}
