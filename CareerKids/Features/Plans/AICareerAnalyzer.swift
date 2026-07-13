//
//  AICareerAnalyzer.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 04.02.2026.
//

import Foundation

/// AI сервіс для аналізу відповідей користувача та генерації рекомендацій
/// Використовує алгоритми машинного навчання для персоналізації
class AICareerAnalyzer {
    
    // MARK: - Singleton
    
    static let shared = AICareerAnalyzer()
    
    // MARK: - Private Init
    
    private init() {}
    
    // MARK: - AI Analysis
    
    /// Аналізує результати тесту та генерує персоналізовані рекомендації
    /// - Parameters:
    ///   - quizResult: Результат тесту користувача
    ///   - userProfile: Профіль користувача
    /// - Returns: Розширені рекомендації з AI аналізом
    func analyzeQuizResults(quizResult: QuizResult, userProfile: UserProfile) -> AICareerRecommendation {
        print("🤖 AI: Analyzing quiz results...")
        
        // Базовий аналіз (поки без справжнього AI, але структура готова)
        let topCategory = quizResult.topCategory
        let percentages = quizResult.percentages
        let customAnswers = quizResult.customAnswers
        
        // Аналізуємо власні відповіді користувача
        if !customAnswers.isEmpty {
            print("📝 AI: Analyzing \(customAnswers.count) custom answers...")
            for (index, answer) in customAnswers.enumerated() {
                print("   \(index + 1). \(answer)")
            }
        }
        
        // Генеруємо додаткові професії на основі категорій ТА власних відповідей
        var additionalCareers = generateAdditionalCareers(percentages: percentages, userAge: userProfile.age)
        
        // Додаємо професії на основі власних відповідей
        if !customAnswers.isEmpty {
            let customBasedCareers = analyzeCustomAnswers(customAnswers, userAge: userProfile.age)
            additionalCareers.append(contentsOf: customBasedCareers)
            additionalCareers = Array(Set(additionalCareers)) // Унікальні
        }
        
        // Створюємо план розвитку
        let developmentPlan = createDevelopmentPlan(for: topCategory, age: userProfile.age)
        
        // Рекомендовані тренінги та курси
        let trainings = recommendTrainings(for: topCategory)
        
        // Персоналізовані поради (з урахуванням власних відповідей)
        let personalizedAdvice = generatePersonalizedAdvice(
            category: topCategory,
            userName: userProfile.name,
            age: userProfile.age,
            customAnswers: customAnswers
        )
        
        return AICareerRecommendation(
            topCategory: topCategory,
            confidence: calculateConfidence(percentages: percentages),
            recommendedCareers: quizResult.recommendedCareers,
            additionalCareers: additionalCareers,
            developmentPlan: developmentPlan,
            trainings: trainings,
            personalizedAdvice: personalizedAdvice,
            nextSteps: generateNextSteps(for: topCategory, age: userProfile.age)
        )
    }
    
    // MARK: - Private Methods
    
    /// Генерує додаткові професії на основі відсотків категорій
    private func generateAdditionalCareers(percentages: [CareerCategory: Int], userAge: Int?) -> [String] {
        var careers: [String] = []
        
        // Беремо топ 3 категорії
        let sortedCategories = percentages.sorted { $0.value > $1.value }.prefix(3)
        
        for (category, percentage) in sortedCategories where percentage > 20 {
            careers.append(contentsOf: getAdditionalCareersForCategory(category, age: userAge))
        }
        
        return Array(Set(careers)) // Унікальні професії
    }
    
    /// Повертає додаткові професії для категорії
    private func getAdditionalCareersForCategory(_ category: CareerCategory, age: Int?) -> [String] {
        let ageGroup = getAgeGroup(age)
        
        switch category {
        case .technology:
            if ageGroup == .young {
                return ["Тестувальник ПЗ", "Web-розробник", "Адміністратор соцмереж"]
            } else {
                return ["DevOps інженер", "Архітектор ПЗ", "Machine Learning інженер"]
            }
            
        case .creative:
            if ageGroup == .young {
                return ["TikTok креатор", "Ілюстратор", "Графічний дизайнер"]
            } else {
                return ["UX/UI дизайнер", "3D моделлер", "Арт-директор"]
            }
            
        case .science:
            return ["Біоінженер", "Дослідник даних", "Лабораторний технік", "Науковий журналіст"]
            
        case .business:
            if ageGroup == .young {
                return ["Блогер", "Малий бізнес", "Онлайн продавець"]
            } else {
                return ["Стартап-фаундер", "Інвестиційний аналітик", "Бізнес-консультант"]
            }
            
        case .social:
            return ["Волонтер-координатор", "HR менеджер", "Коуч", "Медіатор"]
            
        case .sports:
            return ["Спортивний психолог", "Нутриціоніст", "Реабілітолог", "Спортивний менеджер"]
            
        case .art:
            return ["Танцівник", "Режисер", "Сценарист", "Артист озвучування"]
            
        case .nature:
            return ["Ландшафтний дизайнер", "Агроном", "Лісник", "Океанолог"]
        }
    }
    
    /// Створює план розвитку кар'єри
    private func createDevelopmentPlan(for category: CareerCategory, age: Int?) -> DevelopmentPlan {
        let ageGroup = getAgeGroup(age)
        
        let shortTerm = getShortTermGoals(category: category, ageGroup: ageGroup)
        let mediumTerm = getMediumTermGoals(category: category, ageGroup: ageGroup)
        let longTerm = getLongTermGoals(category: category, ageGroup: ageGroup)
        
        return DevelopmentPlan(
            shortTerm: shortTerm,
            mediumTerm: mediumTerm,
            longTerm: longTerm,
            estimatedTimeToCareer: getEstimatedTime(category: category, ageGroup: ageGroup)
        )
    }
    
    /// Короткострокові цілі (0-1 рік)
    private func getShortTermGoals(category: CareerCategory, ageGroup: AgeGroup) -> [DevelopmentGoal] {
        switch category {
        case .technology:
            return [
                DevelopmentGoal(
                    title: "Навчись основам програмування",
                    description: "Почни з Python або Scratch (для молодших)",
                    duration: "2-3 місяці",
                    resources: ["Codecademy", "YouTube tutorials", "Scratch.mit.edu"]
                ),
                DevelopmentGoal(
                    title: "Створи перший проект",
                    description: "Зроби простий додаток або гру",
                    duration: "1 місяць",
                    resources: ["GitHub", "CodePen"]
                )
            ]
            
        case .creative:
            return [
                DevelopmentGoal(
                    title: "Освой інструменти дизайну",
                    description: "Вивчи Figma або Canva",
                    duration: "1-2 місяці",
                    resources: ["Figma tutorials", "YouTube Design School"]
                ),
                DevelopmentGoal(
                    title: "Створи портфоліо",
                    description: "Зроби 5-10 власних робіт",
                    duration: "2 місяці",
                    resources: ["Behance", "Dribbble"]
                )
            ]
            
        case .science:
            return [
                DevelopmentGoal(
                    title: "Поглибся в науку",
                    description: "Читай наукові статті та журнали",
                    duration: "Постійно",
                    resources: ["National Geographic Kids", "Science News"]
                ),
                DevelopmentGoal(
                    title: "Роби експерименти",
                    description: "Проводь досліди вдома",
                    duration: "Щотижня",
                    resources: ["Science Experiments YouTube", "Local Science Club"]
                )
            ]
            
        default:
            return [
                DevelopmentGoal(
                    title: "Вивчай основи",
                    description: "Дізнайся більше про цю сферу",
                    duration: "1-2 місяці",
                    resources: ["YouTube", "Online courses"]
                )
            ]
        }
    }
    
    /// Середньострокові цілі (1-3 роки)
    private func getMediumTermGoals(category: CareerCategory, ageGroup: AgeGroup) -> [DevelopmentGoal] {
        switch category {
        case .technology:
            return [
                DevelopmentGoal(
                    title: "Вивчи фреймворки",
                    description: "React, SwiftUI, або інші сучасні технології",
                    duration: "6-12 місяців",
                    resources: ["Online bootcamps", "University courses"]
                ),
                DevelopmentGoal(
                    title: "Отримай перший досвід",
                    description: "Стажування або фріланс проекти",
                    duration: "1 рік",
                    resources: ["Internships", "Freelance platforms"]
                )
            ]
            
        case .creative:
            return [
                DevelopmentGoal(
                    title: "Професійні курси",
                    description: "Візьми курси з UX/UI або графічного дизайну",
                    duration: "6 місяців",
                    resources: ["Skillshare", "Domestika", "Local design school"]
                )
            ]
            
        default:
            return [
                DevelopmentGoal(
                    title: "Практичний досвід",
                    description: "Працюй над реальними проектами",
                    duration: "1-2 роки",
                    resources: ["Volunteer work", "Part-time jobs"]
                )
            ]
        }
    }
    
    /// Довгострокові цілі (3+ роки)
    private func getLongTermGoals(category: CareerCategory, ageGroup: AgeGroup) -> [DevelopmentGoal] {
        return [
            DevelopmentGoal(
                title: "Професійна освіта",
                description: "Університет або спеціалізовані курси",
                duration: "4-5 років",
                resources: ["Universities", "Professional certifications"]
            ),
            DevelopmentGoal(
                title: "Побудуй кар'єру",
                description: "Працюй в компанії або створи власний бізнес",
                duration: "5+ років",
                resources: ["Job platforms", "Networking events"]
            )
        ]
    }
    
    /// Рекомендує тренінги та курси
    private func recommendTrainings(for category: CareerCategory) -> [Training] {
        switch category {
        case .technology:
            return [
                Training(
                    title: "Основи програмування",
                    provider: "Codecademy",
                    type: .online,
                    duration: "3 місяці",
                    difficulty: .beginner,
                    cost: "Безкоштовно / $20/міс",
                    skills: ["Python", "JavaScript", "Логіка"],
                    url: "https://www.codecademy.com"
                ),
                Training(
                    title: "CS50 - Вступ до Computer Science",
                    provider: "Harvard University",
                    type: .online,
                    duration: "12 тижнів",
                    difficulty: .intermediate,
                    cost: "Безкоштовно",
                    skills: ["C", "Python", "Алгоритми"],
                    url: "https://cs50.harvard.edu"
                ),
                Training(
                    title: "iOS розробка на Swift",
                    provider: "Stanford University",
                    type: .online,
                    duration: "4 місяці",
                    difficulty: .intermediate,
                    cost: "Безкоштовно",
                    skills: ["Swift", "SwiftUI", "iOS"],
                    url: nil
                )
            ]
            
        case .creative:
            return [
                Training(
                    title: "UX/UI дизайн з нуля",
                    provider: "Google UX Design",
                    type: .online,
                    duration: "6 місяців",
                    difficulty: .beginner,
                    cost: "$39/міс",
                    skills: ["Figma", "User Research", "Prototyping"],
                    url: "https://www.coursera.org"
                ),
                Training(
                    title: "Графічний дизайн",
                    provider: "Skillshare",
                    type: .online,
                    duration: "Різне",
                    difficulty: .beginner,
                    cost: "$32/міс",
                    skills: ["Adobe Photoshop", "Illustrator", "Design Theory"],
                    url: "https://www.skillshare.com"
                )
            ]
            
        case .science:
            return [
                Training(
                    title: "Наукове мислення",
                    provider: "Khan Academy",
                    type: .online,
                    duration: "Різне",
                    difficulty: .beginner,
                    cost: "Безкоштовно",
                    skills: ["Біологія", "Хімія", "Фізика"],
                    url: "https://www.khanacademy.org"
                ),
                Training(
                    title: "Лабораторні навички",
                    provider: "Local Science Centers",
                    type: .inPerson,
                    duration: "Варіюється",
                    difficulty: .intermediate,
                    cost: "Варіюється",
                    skills: ["Експерименти", "Аналіз даних"],
                    url: nil
                )
            ]
            
        case .business:
            return [
                Training(
                    title: "Основи підприємництва",
                    provider: "Coursera",
                    type: .online,
                    duration: "4 місяці",
                    difficulty: .beginner,
                    cost: "$49/міс",
                    skills: ["Бізнес-планування", "Маркетинг", "Фінанси"],
                    url: "https://www.coursera.org"
                )
            ]
            
        case .social:
            return [
                Training(
                    title: "Психологія спілкування",
                    provider: "Online Platforms",
                    type: .online,
                    duration: "2 місяці",
                    difficulty: .beginner,
                    cost: "Варіюється",
                    skills: ["Емпатія", "Комунікація", "Лідерство"],
                    url: nil
                )
            ]
            
        case .sports:
            return [
                Training(
                    title: "Фізична підготовка та нутриція",
                    provider: "Local Sports Academies",
                    type: .inPerson,
                    duration: "Постійно",
                    difficulty: .intermediate,
                    cost: "Варіюється",
                    skills: ["Фізична форма", "Харчування", "Тренування"],
                    url: nil
                )
            ]
            
        case .art:
            return [
                Training(
                    title: "Основи малювання",
                    provider: "Domestika",
                    type: .online,
                    duration: "Різне",
                    difficulty: .beginner,
                    cost: "$10-30 per course",
                    skills: ["Малювання", "Композиція", "Кольорознавство"],
                    url: "https://www.domestika.org"
                )
            ]
            
        case .nature:
            return [
                Training(
                    title: "Екологія та охорона природи",
                    provider: "WWF / Local Organizations",
                    type: .mixed,
                    duration: "Варіюється",
                    difficulty: .beginner,
                    cost: "Часто безкоштовно",
                    skills: ["Екологія", "Збереження природи"],
                    url: nil
                )
            ]
        }
    }
    
    /// Аналізує власні відповіді користувача та генерує професії
    private func analyzeCustomAnswers(_ answers: [String], userAge: Int?) -> [String] {
        var suggestedCareers: [String] = []
        
        // Прості ключові слова для аналізу (можна розширити)
        let keywords: [String: [String]] = [
            "програм": ["Програміст", "Розробник додатків", "Web-дизайнер"],
            "компʼют": ["IT-спеціаліст", "Системний адміністратор"],
            "малюв": ["Художник", "Ілюстратор", "Графічний дизайнер"],
            "дизайн": ["Дизайнер", "UX/UI дизайнер", "Веб-дизайнер"],
            "музик": ["Музикант", "Композитор", "Звукорежисер"],
            "спорт": ["Тренер", "Спортсмен", "Фітнес-інструктор"],
            "тварин": ["Ветеринар", "Зоолог", "Кінолог"],
            "природ": ["Еколог", "Біолог", "Ландшафтний дизайнер"],
            "людьми": ["Психолог", "Вчитель", "HR-менеджер"],
            "допомаг": ["Соціальний працівник", "Медсестра", "Волонтер-координатор"],
            "наук": ["Вчений", "Дослідник", "Лаборант"],
            "бізнес": ["Підприємець", "Менеджер", "Маркетолог"],
            "готув": ["Кухар", "Кондитер", "Шеф-кухар"],
            "подорож": ["Туристичний гід", "Пілот", "Бортпровідник"],
            "відео": ["Відеограф", "Режисер", "Монтажер"],
            "фото": ["Фотограф", "Фоторедактор"],
            "пис": ["Письменник", "Журналіст", "Копірайтер"],
            "будув": ["Архітектор", "Інженер-будівельник", "Дизайнер інтер'єрів"]
        ]
        
        // Аналізуємо кожну відповідь
        for answer in answers {
            let lowerAnswer = answer.lowercased()
            
            for (keyword, careers) in keywords {
                if lowerAnswer.contains(keyword) {
                    suggestedCareers.append(contentsOf: careers)
                    print("🎯 AI: Found keyword '\(keyword)' → suggesting: \(careers.joined(separator: ", "))")
                }
            }
        }
        
        // Видаляємо дублікати та обмежуємо до 5
        return Array(Set(suggestedCareers)).prefix(5).map { $0 }
    }
    
    /// Генерує персоналізовані поради з врахуванням власних відповідей
    private func generatePersonalizedAdvice(category: CareerCategory, userName: String, age: Int?, customAnswers: [String]) -> String {
        let ageGroup = getAgeGroup(age)
        
        var greeting = "\(userName), "
        
        // Якщо є власні відповіді, згадуємо їх
        if !customAnswers.isEmpty {
            greeting += "я проаналізував твої відповіді і бачу що "
            let firstAnswer = customAnswers.first!.lowercased()
            if firstAnswer.contains("люблю") || firstAnswer.contains("подобається") {
                greeting += "тобі дуже важливо займатись улюбленою справою! "
            } else {
                greeting += "ти маєш унікальні інтереси! "
            }
        }
        
        switch category {
        case .technology:
            if ageGroup == .young {
                return greeting + "у тебе великий потенціал стати програмістом! 💻 Почни з простих ігор на Scratch, а потім переходь до Python. Вже в 12-14 років можеш створити свій перший додаток!"
            } else {
                return greeting + "твої результати показують схильність до технологій! Рекомендую почати з вивчення основ програмування та створення власних проектів. До 18 років зможеш мати солідне портфоліо!"
            }
            
        case .creative:
            return greeting + "в тобі живе справжній творець! 🎨 Розвивай свої навички через практику - малюй, проектуй, експериментуй. Створи своє портфоліо та показуй роботи світу!"
            
        case .science:
            return greeting + "ти маєш аналітичний склад розуму! 🔬 Цікався всім, читай наукові статті, роби експерименти. Наука потребує таких допитливих людей як ти!"
            
        case .business:
            return greeting + "бачу в тобі майбутнього підприємця! 💼 Спробуй почати з малого - створи свій маленький бізнес, навчись управляти грошима та людьми."
            
        case .social:
            return greeting + "ти народжений допомагати людям! ❤️ Твоя емпатія та комунікабельність - це великий дар. Розвивай ці навички через волонтерство та спілкування."
            
        case .sports:
            return greeting + "рух - це твоє життя! 💪 Тренуйся регулярно, вивчай свій вид спорту, працюй з тренером. Можливо, ти станеш чемпіоном!"
            
        case .art:
            return greeting + "мистецтво - твоє покликання! 🎭 Не бійся експериментувати, знаходь свій стиль, ділися своєю творчістю з іншими."
            
        case .nature:
            return greeting + "ти любиш природу і це чудово! 🌿 Вивчай екологію, працюй з тваринами, захищай довкілля. Планета потребує таких захисників як ти!"
        }
    }
    
    /// Генерує наступні кроки
    private func generateNextSteps(for category: CareerCategory, age: Int?) -> [String] {
        let ageGroup = getAgeGroup(age)
        
        var steps = [
            "✅ Пройди ще раз тест через 3 місяці і подивись як змінились результати",
            "✅ Додай цікаві професії в обране та вивчи їх детально"
        ]
        
        if ageGroup == .young {
            steps.append("✅ Поговори з батьками про свої інтереси")
            steps.append("✅ Запишись на кружок або гурток за інтересами")
        } else {
            steps.append("✅ Почни вивчати базові навички в цій сфері")
            steps.append("✅ Знайди ментора або досвідчену людину для порад")
        }
        
        steps.append("✅ Створи план розвитку на рік")
        
        return steps
    }
    
    /// Розраховує впевненість в рекомендації
    private func calculateConfidence(percentages: [CareerCategory: Int]) -> Double {
        guard let topPercentage = percentages.values.max() else { return 0.5 }
        
        // Конвертуємо в 0...1
        return Double(topPercentage) / 100.0
    }
    
    /// Розраховує час до кар'єри
    private func getEstimatedTime(category: CareerCategory, ageGroup: AgeGroup) -> String {
        switch ageGroup {
        case .young:
            return "8-10 років (з урахуванням освіти)"
        case .teen:
            return "4-6 років (після школи)"
        case .youngAdult:
            return "2-4 роки (з професійною освітою)"
        }
    }
    
    /// Визначає вікову групу
    private func getAgeGroup(_ age: Int?) -> AgeGroup {
        guard let age = age else { return .teen }
        
        if age < 12 {
            return .young
        } else if age < 16 {
            return .teen
        } else {
            return .youngAdult
        }
    }
}

// MARK: - Models

/// Розширені рекомендації з AI аналізом
struct AICareerRecommendation: Identifiable {
    let id = UUID()
    let topCategory: CareerCategory
    let confidence: Double // 0...1
    let recommendedCareers: [String]
    let additionalCareers: [String]
    let developmentPlan: DevelopmentPlan
    let trainings: [Training]
    let personalizedAdvice: String
    let nextSteps: [String]
    
    /// Рівень впевненості у вигляді тексту
    var confidenceText: String {
        if confidence >= 0.8 {
            return "Дуже впевнений"
        } else if confidence >= 0.6 {
            return "Впевнений"
        } else if confidence >= 0.4 {
            return "Помірно впевнений"
        } else {
            return "Потрібно більше даних"
        }
    }
}

/// План розвитку кар'єри
struct DevelopmentPlan {
    let shortTerm: [DevelopmentGoal] // 0-1 рік
    let mediumTerm: [DevelopmentGoal] // 1-3 роки
    let longTerm: [DevelopmentGoal] // 3+ роки
    let estimatedTimeToCareer: String
}

/// Ціль розвитку
struct DevelopmentGoal: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String
    let resources: [String]
}

/// Тренінг або курс
struct Training: Identifiable {
    let id = UUID()
    let title: String
    let provider: String
    let type: TrainingType
    let duration: String
    let difficulty: TrainingDifficulty
    let cost: String
    let skills: [String]
    let url: String?
}

/// Тип тренінгу
enum TrainingType: String {
    case online = "Онлайн"
    case inPerson = "Очно"
    case mixed = "Змішаний"
}

/// Складність тренінгу
enum TrainingDifficulty: String {
    case beginner = "Початковий"
    case intermediate = "Середній"
    case advanced = "Просунутий"
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
}

/// Вікова група
enum AgeGroup {
    case young // 6-11
    case teen // 12-15
    case youngAdult // 16-18
}
