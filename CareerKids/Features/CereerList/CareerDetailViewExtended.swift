//
//  CareerDetailViewExtended.swift
//  CareerKids
//
//  Created by Vahe Bazikyan on 04.02.2026.
//

import SwiftUI

/// Розширений екран деталей професії
/// Показує всю доступну інформацію про кар'єру
struct CareerDetailViewExtended: View {
    let career: CareerExtended
    
    // MARK: - State
    
    @State private var isFavorite: Bool = false
    @State private var selectedTab: DetailTab = .overview
    private let favoritesService = FavoritesService.shared
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Заголовок з іконкою
                headerSection
                
                // Табби для навігації
                tabSelector
                
                // Контент залежно від вибраного табу
                TabView(selection: $selectedTab) {
                    overviewTab.tag(DetailTab.overview)
                    educationTab.tag(DetailTab.education)
                    skillsTab.tag(DetailTab.skills)
                    salaryTab.tag(DetailTab.salary)
                    pathTab.tag(DetailTab.path)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 600)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                favoriteButton
            }
        }
        .onAppear {
            isFavorite = favoritesService.isFavorite(career.id)
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Іконка
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                (Color(career.colorName) ?? .blue).opacity(0.3),
                                (Color(career.colorName) ?? .blue)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Image(systemName: career.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
            
            // Назва
            Text(career.title)
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            
            // Короткий опис
            Text(career.shortDescription)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Категорія
            HStack {
                Image(systemName: career.category.icon)
                    .foregroundColor(career.category.color)
                Text(career.category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(career.category.color.opacity(0.1))
            .cornerRadius(20)
        }
        .padding(.top, 30)
        .padding(.bottom, 20)
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(DetailTab.allCases, id: \.self) { tab in
                    TabButton(
                        title: tab.title,
                        icon: tab.icon,
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - Tabs Content
    
    private var overviewTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Повний опис
            SectionHeader(title: "Про професію", icon: "info.circle.fill")
            
            Text(career.fullDescription)
                .font(.body)
                .padding(.horizontal)
            
            // Робоче середовище
            SectionHeader(title: "Робоче середовище", icon: "building.2.fill")
            
            VStack(spacing: 12) {
                InfoChip(icon: "mappin.circle.fill", text: career.workEnvironment.locations.first?.rawValue ?? "Різні місця", color: .blue)
                InfoChip(icon: "clock.fill", text: career.workEnvironment.schedule.rawValue, color: .green)
                InfoChip(icon: "wifi", text: "Віддалена робота: \(career.workEnvironment.remoteWork.rawValue)", color: .purple)
                InfoChip(icon: "figure.walk", text: "Навантаження: \(career.workEnvironment.physicalDemand.rawValue)", color: .orange)
            }
            .padding(.horizontal)
            
            // Відомі люди
            if let famousPeople = career.famousPeople, !famousPeople.isEmpty {
                SectionHeader(title: "Відомі представники", icon: "star.fill")
                
                ForEach(famousPeople) { person in
                    FamousPersonCard(person: person)
                        .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    private var educationTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Навчання", icon: "graduationcap.fill")
            
            // Рівень освіти
            ExtendedInfoRow(
                icon: "book.fill",
                title: "Необхідна освіта",
                value: career.education.requiredLevel.rawValue,
                color: .blue
            )
            
            // Тривалість
            ExtendedInfoRow(
                icon: "hourglass",
                title: "Тривалість навчання",
                value: career.education.duration,
                color: .green
            )
            
            // Предмети
            SectionHeader(title: "Важливі предмети", icon: "list.bullet")
            
            ForEach(career.education.subjects, id: \.self) { subject in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(subject)
                        .font(.body)
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            // Університети
            if let universities = career.education.universities, !universities.isEmpty {
                SectionHeader(title: "Де можна навчатися", icon: "building.columns.fill")
                
                ForEach(universities) { uni in
                    UniversityCard(university: uni)
                        .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    private var skillsTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Необхідні навички", icon: "brain.head.profile")
            
            ForEach(career.skills) { skill in
                SkillCard(skill: skill)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    private var salaryTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Зарплата", icon: "dollarsign.circle.fill")
            
            Text("Регіон: \(career.salary.region)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            // Початковий рівень
            SalaryCard(
                level: "Junior (Початківець)",
                salary: career.salary.juniorFormatted,
                color: .green
            )
            .padding(.horizontal)
            
            // Середній рівень
            SalaryCard(
                level: "Middle (Досвідчений)",
                salary: career.salary.middleFormatted,
                color: .blue
            )
            .padding(.horizontal)
            
            // Старший рівень
            SalaryCard(
                level: "Senior (Експерт)",
                salary: career.salary.seniorFormatted,
                color: .purple
            )
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
    }
    
    private var pathTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Кар'єрний шлях", icon: "chart.line.uptrend.xyaxis")
            
            // Entry level
            CareerLevelCard(
                level: career.careerPath.entry,
                timeline: "Початок кар'єри",
                color: .green
            )
            .padding(.horizontal)
            
            // Стрілка вниз
            Image(systemName: "arrow.down")
                .font(.title)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            
            Text("Через \(career.careerPath.timeToMiddle)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
            
            // Middle level
            CareerLevelCard(
                level: career.careerPath.middle,
                timeline: career.careerPath.timeToMiddle,
                color: .blue
            )
            .padding(.horizontal)
            
            // Стрілка вниз
            Image(systemName: "arrow.down")
                .font(.title)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            
            Text("Через \(career.careerPath.timeToSenior)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
            
            // Senior level
            CareerLevelCard(
                level: career.careerPath.senior,
                timeline: career.careerPath.timeToSenior,
                color: .purple
            )
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
    }
    
    // MARK: - Favorite Button
    
    private var favoriteButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                favoritesService.toggleFavorite(career.id)
                isFavorite.toggle()
            }
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundColor(isFavorite ? .red : .gray)
        }
    }
}

// MARK: - Supporting Views

enum DetailTab: CaseIterable {
    case overview, education, skills, salary, path
    
    var title: String {
        switch self {
        case .overview: return "Огляд"
        case .education: return "Навчання"
        case .skills: return "Навички"
        case .salary: return "Зарплата"
        case .path: return "Кар'єра"
        }
    }
    
    var icon: String {
        switch self {
        case .overview: return "info.circle.fill"
        case .education: return "graduationcap.fill"
        case .skills: return "star.fill"
        case .salary: return "dollarsign.circle.fill"
        case .path: return "chart.line.uptrend.xyaxis"
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .regular)
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
        }
        .padding(.horizontal)
    }
}

struct InfoChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct FamousPersonCard: View {
    let person: FamousPerson
    
    var body: some View {
        HStack(spacing: 12) {
            // Placeholder для фото
            Circle()
                .fill(Color.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.headline)
                Text(person.achievement)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ExtendedInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct UniversityCard: View {
    let university: University
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(university.name)
                .font(.headline)
            Text("\(university.city), \(university.country)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(university.specialty)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SkillCard: View {
    let skill: Skill
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(skill.name)
                        .font(.headline)
                    Spacer()
                    Text(skill.importance.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(skill.importance.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(skill.importance.color.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Text(skill.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let description = skill.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SalaryCard: View {
    let level: String
    let salary: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(level)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(salary)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CareerLevelCard: View {
    let level: CareerLevel
    let timeline: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(level.title)
                    .font(.headline)
                    .foregroundColor(color)
                Spacer()
                if let age = level.typicalAge {
                    Text(age)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ForEach(level.responsibilities, id: \.self) { responsibility in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                        .font(.caption)
                    Text(responsibility)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        CareerDetailViewExtended(
            career: CareerExtended(
                id: "programmer",
                title: "Програміст",
                shortDescription: "Створює додатки та веб-сайти",
                fullDescription: "Програміст - це спеціаліст, який пише код для створення програмного забезпечення. Вони працюють над різноманітними проектами від мобільних додатків до складних корпоративних систем.",
                icon: "laptopcomputer",
                colorName: "blue",
                category: .technology,
                subcategory: "Розробка",
                education: Education(
                    requiredLevel: .bachelor,
                    duration: "4 роки",
                    subjects: ["Математика", "Інформатика", "Англійська"],
                    universities: [],
                    onlineCourses: [],
                    certifications: []
                ),
                salary: SalaryRange(
                    currency: "грн",
                    period: .month,
                    juniorMin: 20000,
                    juniorMax: 40000,
                    middleMin: 60000,
                    middleMax: 120000,
                    seniorMin: 150000,
                    seniorMax: 300000,
                    region: "Україна"
                ),
                skills: [],
                workEnvironment: WorkEnvironment(
                    locations: [.office, .home],
                    schedule: .flexible,
                    remoteWork: .yes,
                    physicalDemand: .low,
                    travelRequired: false,
                    teamSize: .medium
                ),
                careerPath: CareerPath(
                    entry: CareerLevel(
                        title: "Junior Developer",
                        responsibilities: ["Написання простого коду", "Навчання"],
                        typicalAge: "18-22 роки"
                    ),
                    middle: CareerLevel(
                        title: "Middle Developer",
                        responsibilities: ["Самостійна розробка", "Код рев'ю"],
                        typicalAge: "23-28 років"
                    ),
                    senior: CareerLevel(
                        title: "Senior Developer",
                        responsibilities: ["Архітектура", "Менторство"],
                        typicalAge: "29+ років"
                    ),
                    timeToMiddle: "2-3 роки",
                    timeToSenior: "5-7 років"
                ),
                famousPeople: [],
                videoURLs: [],
                relatedCareers: []
            )
        )
    }
}
