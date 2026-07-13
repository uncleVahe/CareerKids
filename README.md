# CareerKids

A SwiftUI iOS app that helps teens explore career paths through an interactive quiz, rule-based recommendations, and a personal development plan.

---

## 🇬🇧 English

### Overview

CareerKids guides a young user through an onboarding flow, a career-interest quiz, and a recommendation engine that suggests career paths, training resources, and a short/medium/long-term development plan based on the quiz results and the user's age group. Users can save favorite careers, review their test history, and export a personalized plan as a PDF.

### Features

- **Onboarding** — collects name and age, drives age-aware content further down the funnel.
- **Quiz engine** — multi-question quiz across 8 career categories (Technology, Creative, Science, Business, Social, Sports, Art, Nature), with support for free-text ("custom") answers alongside multiple-choice ones.
- **Recommendation engine** — scores quiz answers, computes category percentages, and generates age-appropriate career suggestions, a development plan (short/medium/long-term goals), and recommended courses/trainings.
- **Careers catalog** — browsable list of careers loaded from bundled JSON, filterable by favorites and by the user's recommended category.
- **Favorites** — thread-safe favoriting backed by `UserDefaults`, broadcast via `NotificationCenter` so any screen stays in sync.
- **Test history** — every completed quiz is saved locally (capped at the last 50 runs) and browsable later.
- **Profile** — name, age, profile photo (via `PhotosUI`), and quick stats (tests completed, favorites count).
- **PDF export** — generates a shareable PDF of the recommended development plan.

### Architecture

- **Pattern**: MVVM with `ObservableObject` view models, one per feature (`QuizViewModel`, `ProfileTabViewModel`, `CareersTabViewModel`, `OnboardingViewModel`).
- **Dependency injection**: every stateful service (`UserProfileService`, `FavoritesService`, `TestHistoryService`, `DataLoaderService`) sits behind a protocol (`UserProfileProviding`, `FavoritesManaging`, `TestHistoryManaging`, `CareerDataLoading`). View models take these as constructor parameters with `.shared` as the default, so production call sites are unaffected while unit tests inject fakes.
- **Concurrency**: `async/await` for timed UI transitions (`Task` + `Task.sleep`, with explicit cancellation on `deinit`) instead of nested `DispatchQueue.asyncAfter` chains.
- **Persistence**: `UserDefaults` for profile/favorites/history (JSON-encoded where structured data is involved), bundled JSON for static catalog data (careers, quiz questions).

### Tech Stack

Swift, SwiftUI, Combine, async/await, PhotosUI, XCTest.

### Testing

The `CareerKidsTests` target covers the quiz scoring logic and the recommendation engine with 23 unit tests, using protocol-based mocks (`MockTestHistoryService`, `MockCareerDataLoader`) instead of hitting real `UserDefaults` or bundled JSON. A test-driven pass over `QuizViewModel.calculateResult()` caught and fixed a real bug where category percentages didn't sum to 100% when answers spanned multiple categories or included free-text answers.

### Requirements

- Xcode 16+, iOS 26 SDK
- Open `CareerKids.xcodeproj`, run the `CareerKids` scheme
- Run tests with `⌘U` (`CareerKidsTests` target, host application `CareerKids`)

---

## 🇺🇦 Українська

### Опис

CareerKids — це iOS-застосунок на SwiftUI, який допомагає підліткам визначитись з напрямком кар'єри через інтерактивний тест, рекомендації на основі результатів і персональний план розвитку. Користувач проходить onboarding, тест на профорієнтацію, отримує рекомендації професій, навчальні ресурси та план розвитку (короткостроковий/середньостроковий/довгостроковий) з урахуванням вікової групи. Можна зберігати улюблені професії, переглядати історію пройдених тестів і експортувати план розвитку в PDF.

### Функціонал

- **Onboarding** — збирає ім'я та вік, далі контент підлаштовується під вікову групу.
- **Квіз-движок** — багатопитальний тест на 8 категорій кар'єри (Технології, Творчість, Наука, Бізнес, Люди, Спорт, Мистецтво, Природа), з підтримкою як варіантів відповіді, так і власного тексту ("custom answer").
- **Рекомендаційний движок** — рахує результати тесту, відсотки по категоріях, і генерує рекомендації професій з урахуванням віку, план розвитку (короткі/середні/довгі цілі) та рекомендовані курси й тренінги.
- **Каталог професій** — список професій із вбудованого JSON, з фільтрацією по обраному і по рекомендованій категорії.
- **Обране** — thread-safe робота з улюбленими професіями на `UserDefaults`, синхронізація екранів через `NotificationCenter`.
- **Історія тестів** — кожен пройдений тест зберігається локально (ліміт — останні 50), доступна для перегляду пізніше.
- **Профіль** — ім'я, вік, фото профілю (через `PhotosUI`), швидка статистика (пройдено тестів, кількість обраного).
- **PDF-експорт** — генерація PDF з персональним планом розвитку для збереження чи пересилання.

### Архітектура

- **Патерн**: MVVM з `ObservableObject` view model-ами, окремо на кожен фіча-модуль (`QuizViewModel`, `ProfileTabViewModel`, `CareersTabViewModel`, `OnboardingViewModel`).
- **Dependency Injection**: кожен стейтфул-сервіс (`UserProfileService`, `FavoritesService`, `TestHistoryService`, `DataLoaderService`) прихований за протоколом (`UserProfileProviding`, `FavoritesManaging`, `TestHistoryManaging`, `CareerDataLoading`). View model-и приймають їх через конструктор з дефолтом `.shared` — прод-виклики не змінюються, а юніт-тести підставляють моки.
- **Concurrency**: `async/await` для таймінгових UI-переходів (`Task` + `Task.sleep`, з явним cancellation в `deinit`) замість вкладених ланцюжків `DispatchQueue.asyncAfter`.
- **Persistence**: `UserDefaults` для профілю/обраного/історії (JSON-encoded там, де дані структуровані), вбудований JSON для статичних каталожних даних (професії, питання тесту).

### Технології

Swift, SwiftUI, Combine, async/await, PhotosUI, XCTest.

### Тестування

Target `CareerKidsTests` покриває логіку підрахунку результатів тесту і рекомендаційний движок 23 юніт-тестами, з мок-реалізаціями протоколів (`MockTestHistoryService`, `MockCareerDataLoader`) замість звернень до реального `UserDefaults` чи JSON-бандла. Test-driven прохід по `QuizViewModel.calculateResult()` знайшов і виправив реальний баг: відсотки по категоріях не сумувались у 100%, коли відповідь голосувала за кілька категорій одразу або серед відповідей були власні (custom) тексти.

### Вимоги

- Xcode 16+, iOS 26 SDK
- Відкрити `CareerKids.xcodeproj`, запустити схему `CareerKids`
- Тести — `⌘U` (target `CareerKidsTests`, host application `CareerKids`)
