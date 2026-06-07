# Полный путеводитель по коду проекта "Складской учет"

Этот файл поможет вам понять каждую строчку кода, даже если вы раньше не писали на Dart.

## 1. Архитектура (Где что лежит)

*   **`lib/models/`**: "Чертежи" данных. Здесь мы описываем, что такое Товар или Пользователь.
*   **`lib/services/`**: "Работяги". Здесь код для работы с базой данных SQLite.
*   **`lib/state/`**: "Мозг" приложения. Тут принимаются решения: пускать пользователя или нет, как изменить список товаров.
*   **`lib/screens/`**: "Лицо" приложения. То, что видит пользователь на экране.

---

## 2. Полный справочник по синтаксису Dart

### 2.1. Объявление переменных
*   **`String name`**: Обычная строка.
*   **`final`**: Значение устанавливается один раз и больше не меняется. В Flutter почти все поля в виджетах `final`.
*   **`static`**: Переменная общая для всего класса. Например, `DatabaseService.instance`.
*   **`_` (нижнее подчеркивание)**: Делает переменную приватной. `_database` видна только внутри своего файла.

### 2.2. Работа с NULL (Null Safety)
Dart защищает вас от ошибок "пустого значения":
*   **`String?`**: Знак вопроса значит "может быть null".
*   **`??`**: "Если слева пусто, возьми то, что справа". Пример: `database ?? DatabaseService.instance`.
*   **`?.`**: "Выполни метод, только если объект не null". Пример: `takenAt?.toIso8601String()`.
*   **`required`**: Обязательный параметр. Если его не передать, программа не скомпилируется.

### 2.3. Конструкторы и параметры
В проекте часто встречается такой стиль:
```dart
const Product({
  required this.id,
  required this.name,
  this.holderName, // Необязательный
});
```
*   **`{}` (Фигурные скобки)**: Означают, что параметры **именованные**. При вызове вы пишете `Product(id: 1, name: "Болт")`. Это исключает путаницу с порядком аргументов.
*   **`this.id`**: Автоматически записывает переданное значение в поле класса `id`.

### 2.4. Функции и методы
*   **`=>` (Стрелка)**: Сокращение для функций из одной строки.
    `bool get isAdmin => role == UserRole.admin;`
    это то же самое, что:
    `bool get isAdmin { return role == UserRole.admin; }`
*   **`Future<...>`**: Обещание. Значит функция выполняется асинхронно (например, запрос к БД) и результат будет готов чуть позже.
*   **`async / await`**: Используются вместе с `Future`. `await` заставляет программу подождать ответа от базы данных, не "замораживая" при этом экран.

### 2.5. Продвинутые фишки
*   **`factory`**: Специальный конструктор, который может вернуть "готовый" объект или даже объект другого типа. Часто используется для создания моделей из JSON или таблиц БД (`fromMap`).
*   **`enum`**: Список вариантов. В Dart `enum` может иметь свои методы (см. `UserRole` в `app_user.dart`).
*   **`..` (Каскад)**: Позволяет вызвать метод и продолжить работу с тем же объектом. `WarehouseState()..initialize()` создаст объект и тут же запустит его загрузку.
*   **`copyWith`**: Метод для создания копии объекта с небольшими изменениями. Полезно, когда сам объект менять нельзя (он `const` или `final`).

---

## 3. Как работает Слой Состояния (`WarehouseState`)

Это самый важный файл. Он использует пакет `provider`:
1.  Когда что-то меняется (например, добавили товар), вызывается `notifyListeners()`.
2.  Flutter видит это и автоматически перерисовывает нужные части экрана.
3.  **`context.watch<WarehouseState>()`**: Позволяет экрану "следить" за изменениями.
4.  **`context.read<WarehouseState>()`**: Позволяет вызвать метод (например, `login`), не подписываясь на обновления.

## 4. База данных (SQLite)

В `database_service.dart` используются обычные SQL-запросы:
*   `CREATE TABLE ...`: Создание таблиц при первом запуске.
*   `INSERT`, `UPDATE`, `QUERY`: Стандартные операции.
*   Все данные хранятся в файле на телефоне, поэтому они не пропадают при закрытии приложения.

---

## 5. Как приложение запускается

Стартовая точка проекта находится в `lib/main.dart`:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WarehouseApp());
}
```

*   **`main()`**: первая функция, которую запускает Dart.
*   **`WidgetsFlutterBinding.ensureInitialized()`**: подготавливает Flutter перед работой с плагинами и платформой.
*   **`runApp(...)`**: отдает Flutter главный виджет приложения.
*   **`const WarehouseApp()`**: создает неизменяемый виджет. `const` помогает Flutter не пересоздавать объект без необходимости.

Дальше `WarehouseApp` создает `ChangeNotifierProvider`. Он кладет `WarehouseState` выше всех экранов, чтобы любой экран мог получить состояние через `context.watch` или `context.read`.

```dart
create: (_) => WarehouseState()..initialize(),
```

Здесь `_` означает: "параметр есть, но он нам не нужен". А `..initialize()` сразу вызывает загрузку товаров после создания `WarehouseState`.

---

## 6. Главный поток данных проекта

Проект устроен так:

1.  Пользователь нажимает кнопку на экране.
2.  Экран вызывает метод из `WarehouseState`.
3.  `WarehouseState` проверяет данные и обращается к `DatabaseService`.
4.  `DatabaseService` читает или меняет SQLite.
5.  `WarehouseState` обновляет поля `currentUser` или `products`.
6.  `notifyListeners()` сообщает Flutter: "данные изменились".
7.  Экраны, где есть `context.watch<WarehouseState>()`, перерисовываются.

Пример входа:

```dart
await context.read<WarehouseState>().login(
  _emailController.text,
  _passwordController.text,
);
```

Экран входа не проверяет пользователя сам. Он только берет текст из полей и передает его в состояние. Это хорошее разделение: экран отвечает за интерфейс, `WarehouseState` — за правила приложения.

---

## 7. Синтаксис Flutter-виджетов

Во Flutter интерфейс собирается из вложенных объектов:

```dart
return Scaffold(
  appBar: AppBar(title: const Text('Товары на складе')),
  body: ListView(
    children: [
      Text('Пример'),
    ],
  ),
);
```

*   **`Scaffold`**: базовая структура экрана: верхняя панель, тело, плавающая кнопка.
*   **`AppBar`**: верхняя панель.
*   **`body`**: основная часть экрана.
*   **`children: [...]`**: список дочерних виджетов.
*   **`,` после последнего параметра**: в Dart это нормально и даже полезно. Форматтер красивее переносит код.
*   **`Theme.of(context)`**: берет цвета и стили из общей темы приложения.
*   **`BuildContext context`**: "адрес" виджета в дереве Flutter. Через него виджет находит тему, навигацию, состояние и другие вещи выше по дереву.

---

## 8. `StatelessWidget` и `StatefulWidget`

В проекте есть оба типа экранов.

**`StatelessWidget`** используется, когда сам виджет не хранит временное состояние:

```dart
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});
}
```

Список товаров меняется, но хранится он не внутри `ProductListScreen`, а в `WarehouseState`. Поэтому экран может быть `StatelessWidget`.

**`StatefulWidget`** используется, когда экрану нужны временные локальные значения:

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
```

В `LoginScreen` есть `_isSubmitting`, `_obscurePassword`, `TextEditingController`. Это состояние относится только к экрану входа, поэтому оно лежит внутри `_LoginScreenState`.

Важная пара:

```dart
setState(() => _obscurePassword = !_obscurePassword);
```

`setState` говорит Flutter: "локальное состояние экрана поменялось, перерисуй этот экран".

---

## 9. Формы, контроллеры и `dispose`

В формах используются `TextEditingController`:

```dart
final _emailController = TextEditingController(text: 'admin@sklad.ru');
```

Контроллер хранит текст поля ввода. Потом текст можно прочитать:

```dart
_emailController.text
```

Когда экран закрывается, контроллеры нужно освобождать:

```dart
@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

`dispose()` нужен, чтобы Flutter освободил ресурсы, которые больше не используются.

---

## 10. Навигация между экранами

Переход на новый экран делается через `Navigator`:

```dart
Navigator.of(context).push(
  MaterialPageRoute(builder: (_) => const RegisterScreen()),
);
```

*   **`push`**: открыть новый экран поверх текущего.
*   **`pop`**: закрыть текущий экран и вернуться назад.
*   **`MaterialPageRoute`**: стандартный переход в стиле Material Design.
*   **`builder: (_) => ...`**: функция, которая создает экран. `_` снова означает, что параметр не используется.

В `ScannerScreen` после успешного сканирования вызывается:

```dart
Navigator.of(context).pop();
```

Так приложение возвращается со сканера обратно к списку товаров.

---

## 11. Полезный синтаксис внутри списков виджетов

В `ProductListScreen` есть выразительный Dart-синтаксис:

```dart
children: [
  _UserHeader(name: user.name, role: user.role.title),
  const SizedBox(height: 14),
  if (state.products.isEmpty)
    const _EmptyCatalog()
  else
    ...state.products.map(
      (product) => _ProductTile(product: product),
    ),
],
```

*   **`if (...) ... else ...` внутри списка**: можно добавить разные виджеты в зависимости от условия.
*   **`state.products.map(...)`**: превращает каждый `Product` в `_ProductTile`.
*   **`...` (spread-оператор)**: раскрывает список виджетов внутрь другого списка.
*   **`(product) => ...`**: короткая функция. Для каждого товара возвращает виджет карточки.

Без `...` получился бы список внутри списка, а Flutter ожидает обычный список виджетов.

---

## 12. Преобразование данных: `Map`, `fromMap`, `toMap`

SQLite возвращает строки таблицы как `Map<String, Object?>`. Поэтому модели умеют превращаться из карты и обратно.

```dart
factory Product.fromMap(Map<String, Object?> map) {
  return Product(
    id: map['id'] as int,
    name: map['name'] as String,
    isAvailable: (map['is_available'] as int) == 1,
  );
}
```

*   **`Map<String, Object?>`**: словарь, где ключ — строка, а значение может быть разного типа или `null`.
*   **`map['id']`**: достать значение по ключу.
*   **`as int`**: явно сказать Dart, что это число.
*   **`is_available`** хранится в SQLite как `0` или `1`, потому что в SQLite нет отдельного типа `bool`.

Обратное преобразование:

```dart
Map<String, Object?> toMapForInsert() {
  return {
    'name': name,
    'is_available': isAvailable ? 1 : 0,
  };
}
```

Тернарный оператор `условие ? если_да : если_нет` здесь превращает `true/false` в `1/0`.

---

## 13. Ошибки и защита от неправильных действий

В `WarehouseState` проверки выбрасывают исключения:

```dart
if (password.trim().isEmpty) {
  throw FormatException('Введите пароль.');
}
```

Экран ловит ошибку:

```dart
try {
  await context.read<WarehouseState>().login(email, password);
} on Object catch (error) {
  _showError(context, error);
}
```

*   **`throw`**: остановить выполнение и сообщить об ошибке.
*   **`try/catch`**: попробовать выполнить код и обработать ошибку, если она случилась.
*   **`finally`**: выполнить код в любом случае — и при успехе, и при ошибке.
*   **`mounted`**: проверка, что экран еще открыт. После `await` пользователь мог уже уйти со страницы, и тогда вызывать `setState` нельзя.

---

## 14. QR-коды в проекте

Каждый товар умеет создать строку для QR:

```dart
String get qrPayload => 'warehouse-product:$id';
```

На экране товара эта строка превращается в QR-код через пакет `qr_flutter`:

```dart
QrImageView(
  data: product.qrPayload,
  size: 220,
)
```

Сканер читает строку через пакет `mobile_scanner`, а `WarehouseState` вытаскивает из нее id:

```dart
static int? _extractProductId(String rawCode) {
  final trimmed = rawCode.trim();
  if (trimmed.startsWith('warehouse-product:')) {
    return int.tryParse(trimmed.replaceFirst('warehouse-product:', ''));
  }

  return int.tryParse(trimmed);
}
```

`int.tryParse` удобен тем, что не падает с ошибкой, если строка не является числом. Он просто возвращает `null`.

---

## 15. Роли пользователей

Роли описаны через `enum`:

```dart
enum UserRole {
  admin,
  user;
}
```

Администратор может добавлять товары, обычный пользователь — нет:

```dart
bool get canCreateProducts => this == UserRole.admin;
```

Потом `WarehouseState` использует это правило:

```dart
bool get canCreateProducts => currentUser?.role.canCreateProducts ?? false;
```

Если пользователя нет (`currentUser == null`), результат будет `false`. Если пользователь есть, проверяется его роль.

---

## 16. Зависимости проекта

Главные пакеты перечислены в `pubspec.yaml`:

*   **`provider`**: передает `WarehouseState` экранам и обновляет интерфейс.
*   **`sqflite`**: работает с локальной базой SQLite.
*   **`path`**: помогает собрать путь к файлу базы данных.
*   **`qr_flutter`**: рисует QR-код товара.
*   **`mobile_scanner`**: сканирует QR-код камерой.
*   **`flutter_test`**: запускает тесты.

После изменения зависимостей обычно выполняют:

```bash
flutter pub get
```

---

## 17. Тесты

В проекте уже есть тест `test/product_test.dart`:

```dart
test('product QR payload contains warehouse prefix and id', () {
  const product = Product(id: 42, ...);

  expect(product.qrPayload, 'warehouse-product:42');
});
```

Он проверяет, что товар правильно создает строку для QR-кода. Это маленький тест, но он защищает важный договор проекта: сканер ожидает строку формата `warehouse-product:id`.

Запуск тестов:

```bash
flutter test
```
