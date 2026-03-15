# Функціональність фото профілю

## Огляд

Додано можливість користувачам вибирати та змінювати фото профілю в додатку CareerKids.

## Зміни

### 1. UserProfileService.swift
- ✅ Додано методи `saveProfileImage(_ imageData: Data?)` та `getProfileImage() -> Data?`
- ✅ Додано ключ `profileImageData` для збереження в UserDefaults
- ✅ Оновлено протокол `UserProfileProviding`
- ✅ Оновлено метод `clearProfile()` для видалення фото

### 2. ProfileTab.swift
- ✅ Додано імпорт `PhotosUI`
- ✅ Додано `@Published var profileImageData: Data?` в `ProfileTabViewModel`
- ✅ Оновлено `profileHeader` для відображення фото або ініціалів
- ✅ Додано метод `updateProfileImage(_ imageData: Data?)`
- ✅ Оновлено `loadProfile()` для завантаження фото

### 3. ProfileEditView.swift
- ✅ Додано імпорт `PhotosUI`
- ✅ Додано `var profileImageData: Data?` в протокол `ProfileEditableViewModel`
- ✅ Додано `func updateProfileImage(_ imageData: Data?)` в протокол
- ✅ Додано state змінні для вибору фото:
  - `@State private var selectedPhotoItem: PhotosPickerItem?`
  - `@State private var selectedImageData: Data?`
  - `@State private var showImageOptions = false`
- ✅ Додано секцію з фото профілю
- ✅ Додано `confirmationDialog` для вибору дії з фото
- ✅ Додано `PhotosPicker` для вибору фото з галереї
- ✅ Додано можливість видалення фото

### 4. ProfileViewModel.swift
- ✅ Додано `@Published var profileImageData: Data?`
- ✅ Додано метод `updateProfileImage(_ imageData: Data?)`
- ✅ Оновлено `loadProfile()` для завантаження фото

## Використання

### Вибір фото
1. Перейти до екрану "Профіль"
2. Натиснути "Редагувати профіль"
3. Натиснути "Додати фото" або "Змінити фото"
4. Вибрати "Вибрати з галереї"
5. Обрати фото
6. Натиснути "Зберегти"

### Видалення фото
1. Перейти до екрану редагування профілю
2. Натиснути "Змінити фото"
3. Вибрати "Видалити фото"
4. Натиснути "Зберегти"

## Технічні деталі

### Збереження даних
- Фото зберігається як `Data` в UserDefaults з ключем `profileImageData`
- При видаленні фото, ключ видаляється з UserDefaults

### Відображення
- Якщо є фото: показується фото в Circle з frame 100x100
- Якщо немає фото: показується градієнт з ініціалами користувача

### Підтримка протоколів
- Обидва ViewModel (`ProfileViewModel` та `ProfileTabViewModel`) підтримують протокол `ProfileEditableViewModel`
- Це дозволяє використовувати один і той самий `ProfileEditView` для різних екранів

## Майбутні покращення

- [ ] Додати можливість робити фото з камери
- [ ] Додати обрізання та редагування фото
- [ ] Оптимізувати розмір збережених фото (compression)
- [ ] Розглянути зберігання фото у файловій системі замість UserDefaults для великих зображень
