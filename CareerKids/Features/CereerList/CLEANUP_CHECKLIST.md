# ✅ Cleanup Checklist - Швидкий список дій

## 🚨 КРИТИЧНО - Зроби зараз!

### **1. Видали дублікат TestHistoryService**
```
☐ Знайди в Xcode: "TestHistoryService 2.swift"
☐ Right-click → Delete
☐ Вибери "Move to Trash"
☐ Build проект (Cmd + B)
☐ Якщо компілюється - OK!
```

---

## ⚡ Швидке видалення (після перевірки що все працює)

### **2. Видали файли з typo в назвах**
```
☐ CereerListView.swift → Delete
☐ CereerListViewModel.swift → Delete (якщо є)
☐ Build (Cmd + B)
☐ Test (Cmd + R)
```

### **3. Видали застарілі View файли**
```
☐ TestHistoryView.swift → Delete
☐ Build & Test

☐ ProfileView.swift → Delete  
☐ Build & Test
```

---

## 📋 Детальний план (якщо хочеш обережно)

### **Фаза 1: Підготовка**
```
☐ Git commit поточного стану
   git add .
   git commit -m "Before cleanup"

☐ Build проект (Cmd + B)
☐ Run додаток (Cmd + R)
☐ Перевір що всі таби працюють
```

### **Фаза 2: Видалення дубліката (ОБОВ'ЯЗКОВО)**
```
☐ Видали "TestHistoryService 2.swift"
☐ Build (Cmd + B)
☐ Run (Cmd + R)
☐ Пройди тест → перевір чи зберігається в історію
☐ Git commit
   git commit -m "Remove TestHistoryService duplicate"
```

### **Фаза 3: Видалення Cereer* файлів**
```
☐ Find in Project (Cmd + Shift + F): "CareerListView"
☐ Подивись скільки результатів (має бути мінімум)
☐ Видали CereerListView.swift
☐ Видали CereerListViewModel.swift (якщо є)
☐ Build (Cmd + B)
☐ Run (Cmd + R)
☐ Перевір CareersTab
☐ Git commit
```

### **Фаза 4: Видалення TestHistoryView**
```
☐ Find: "TestHistoryView"
☐ Видали TestHistoryView.swift
☐ Build (Cmd + B)
☐ Run (Cmd + R)
☐ Перевір HistoryTab
☐ Git commit
```

### **Фаза 5: Видалення ProfileView**
```
☐ Find: "ProfileView"
☐ Видали ProfileView.swift
☐ Build (Cmd + B)
☐ Run (Cmd + R)
☐ Перевір ProfileTab
☐ Git commit
```

### **Фаза 6: Перевірка SavedPlansView**
```
☐ Find: "SavedPlansView"
☐ Якщо використовується - залиш
☐ Якщо ні - видали
☐ Build & Test
☐ Git commit (якщо видалив)
```

---

## ✅ Final Check після всього

```
☐ Build проект без помилок
☐ Додаток запускається
☐ Всі 5 табів відкриваються:
   ☐ CareersTab
   ☐ QuizzesTab
   ☐ HistoryTab
   ☐ PlansTab
   ☐ ProfileTab

☐ Функціональність:
   ☐ Можна переглядати професії
   ☐ Можна пройти тест
   ☐ Тест зберігається в історію
   ☐ Історію можна переглянути
   ☐ Історію можна видалити
   ☐ План можна зберегти
   ☐ План можна експортувати в PDF
   ☐ Профіль можна редагувати

☐ Git final commit:
   git add .
   git commit -m "Cleanup complete: Removed all duplicates and obsolete files"
```

---

## 🚨 Якщо щось зламалось

### **Compile Error?**
```
1. Прочитай помилку в Xcode
2. Подивись який файл не знайдено
3. Поверни файл: git checkout HEAD -- filename.swift
4. Виправ код який використовує цей файл
```

### **Runtime Crash?**
```
1. Подивись Console log
2. Знайди який View/ViewModel не знайдено
3. Поверни останній commit: git reset --hard HEAD~1
4. Питай мене!
```

---

## 📊 Прогрес

Відмічай по мірі виконання:

```
☐ Дублікат TestHistoryService видалено
☐ Cereer* файли видалено
☐ TestHistoryView видалено
☐ ProfileView видалено
☐ SavedPlansView перевірено
☐ Все працює
☐ Git commits зроблено
```

---

## 💡 Швидкі команди

```bash
# Build
Cmd + B

# Run
Cmd + R

# Clean
Cmd + Shift + K

# Find in Project
Cmd + Shift + F

# Git status
git status

# Git commit
git add .
git commit -m "Your message"
```

---

## 📚 Документація

Детальна інформація:
- **CLEANUP_GUIDE.md** - Повна інструкція
- **CLEANUP_SUMMARY.md** - Що зроблено

---

**Мінімум**: Видали TestHistoryService 2.swift  
**Оптимально**: Видали всі застарілі файли  
**Ідеально**: Cleanup + Git commits + Все працює

Вперед! 💪
