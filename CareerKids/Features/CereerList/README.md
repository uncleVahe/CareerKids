# 🎯 CareerKids - Додаток для вибору професії

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2016%2B-blue" />
  <img src="https://img.shields.io/badge/Language-Swift%205.9-orange" />
  <img src="https://img.shields.io/badge/Framework-SwiftUI-green" />
  <img src="https://img.shields.io/badge/Architecture-MVVM-purple" />
</p>

## 📱 Про проект

**CareerKids** — це iOS додаток, який допомагає дітям та підліткам (6-18 років) визначитись з вибором майбутньої професії через інтерактивні тести та детальний огляд різних кар'єрних шляхів.

### ✨ Основні фічі

- 🎯 **Інтерактивний тест** - 20 питань для визначення схильностей
- 📚 **40+ професій** - детальний опис кожної професії
- 👤 **Профіль користувача** - статистика, обрані професії
- ❤️ **Обрані** - збереження цікавих професій
- 📊 **Статистика** - відстеження прогресу тестів
- 🎨 **Гарний дизайн** - сучасний UI з анімаціями

---

## 🏗 Архітектура

```
CareerKids/
├── App/                    # Точка входу
├── Views/                  # SwiftUI екрани
│   ├── Onboarding/        # Привітання
│   ├── Quiz/              # Тести
│   ├── Career/            # Професії
│   └── Profile/           # Профіль
├── ViewModels/            # Бізнес-логіка
├── Models/                # Дані
├── Services/              # Сервіси
└── Resources/             # JSON, Assets
```

**Паттерн:** MVVM (Model-View-ViewModel)

---

## 🚀 Технології

- **SwiftUI** - сучасний декларативний UI
- **Combine** - реактивне програмування
- **Codable** - парсинг JSON
- **UserDefaults** - збереження даних
- **Swift 5.9+** - остання версія Swift

---

## 📦 Встановлення

1. Клонуйте репозиторій:
```bash
git clone https://github.com/your-username/CareerKids.git
cd CareerKids
```

2. Відкрийте проект в Xcode:
```bash
open CareerKids.xcodeproj
```

3. Переконайтесь що JSON файли додані в проект:
   - `quiz_questions.json`
   - `careers_data.json`

4. Запустіть проект: `Cmd + R`

---

## 📚 Структура даних

### Quiz Questions (`quiz_questions.json`)

```json
{
  "questions": [
    {
      "id": "1",
      "question": "Що тобі найбільше подобається робити?",
      "emoji": "🎮",
      "answers": [...]
    }
  ]
}
```

### Careers (`careers_data.json`)

```json
{
  "careers": [
    {
      "id": "programmer",
      "title": "Програміст",
      "shortDescription": "Створює додатки",
      "icon": "laptopcomputer",
      "color": "blue",
      "category": "technology"
    }
  ]
}
```

---

## 🎨 Features

### 1. Onboarding
- Привітання користувача
- Збір базової інформації (ім'я, вік)
- Гарні анімації

### 2. Тести
- 20 різноманітних питань
- 8 категорій професій
- Детальні результати з рекомендаціями

### 3. Список професій
- 40+ професій
- Фільтр по обраним
- Пошук (TODO)
- Категорії (TODO)

### 4. Деталі професії
- Повний опис
- Необхідна освіта (TODO: extended version)
- Зарплати (TODO: extended version)
- Кар'єрний шлях (TODO: extended version)

### 5. Профіль
- Персональні дані
- Статистика тестів
- Обрані професії
- Редагування профілю

---

## 🔧 Сервіси

### UserProfileService
Управління профілем користувача:
- Збереження даних
- Перевірка onboarding
- Отримання профілю

### FavoritesService
Управління обраними професіями:
- Додавання/видалення
- Перевірка статусу
- Отримання списку

### DataLoaderService
Завантаження даних з JSON:
- Професії
- Питання тестів
- Обробка помилок

---

## 📱 Скріншоти

> TODO: Додати скріншоти додатку

---

## 🎯 Roadmap

### v1.0 (MVP) - поточна версія ✅
- [x] Onboarding
- [x] Базовий тест (20 питань)
- [x] Список професій (40+)
- [x] Профіль користувача
- [x] Обрані професії

### v1.5 - наступна версія
- [ ] Розширена інформація про професії
- [ ] Ієрархічна навігація категорій
- [ ] Пошук професій
- [ ] Історія тестів
- [ ] Графіки прогресу

### v2.0
- [ ] AI персоналізація
- [ ] Локалізація (EN, RU)
- [ ] Відео контент
- [ ] Соціальні features

### v2.5
- [ ] Premium підписка
- [ ] B2B панель для шкіл
- [ ] Експорт звітів

---

## 🧪 Тестування

```bash
# Unit tests
Cmd + U

# UI tests
TODO: Додати UI тести
```

---

## 📝 Документація

- [PROJECT_ANALYSIS.md](PROJECT_ANALYSIS.md) - Повний аналіз проекту
- [RESTRUCTURE_GUIDE.md](RESTRUCTURE_GUIDE.md) - Гайд з реорганізації
- [WORK_COMPLETED.md](WORK_COMPLETED.md) - Звіт про виконану роботу

---

## 👥 Команда

- **Vahe Bazikyan** - iOS Developer
- **AI Assistant** - Code Architecture & Documentation

---

## 📄 Ліцензія

TODO: Додати ліцензію

---

## 🤝 Контрибуція

1. Fork проект
2. Створіть feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit зміни (`git commit -m 'Add some AmazingFeature'`)
4. Push в branch (`git push origin feature/AmazingFeature`)
5. Відкрийте Pull Request

### Code Style

- Використовуйте `MARK:` коментарі
- Додавайте docstring до public методів
- Дотримуйтесь Swift naming conventions
- Тести для нової логіки

---

## 🐛 Відомі проблеми

- Потрібно перейменувати файли `CereerListView` → `CareerListView`
- JSON файли треба додати в проект
- Розширена інформація про професії ще не заповнена

---

## 💡 Ідеї для покращення

- [ ] Додати Dark Mode
- [ ] Анімовані переходи між екранами
- [ ] Haptic feedback
- [ ] Widgets для iOS
- [ ] watchOS версія
- [ ] macOS версія (Catalyst)

---

## 📞 Контакти

Якщо у вас є питання або пропозиції:

- Email: your-email@example.com
- GitHub: [@your-username](https://github.com/your-username)

---

**Made with ❤️ in Ukraine 🇺🇦**
