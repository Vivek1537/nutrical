# Contributing to NutriCal

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/nutrical.git`
3. Install Flutter: https://flutter.dev/docs/get-started/install
4. Run `flutter pub get`
5. Run `flutter analyze` (must show 0 issues)
6. Create a feature branch: `git checkout -b feature/your-feature`

## Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before committing — **zero issues required**
- Use `const` constructors where possible
- Keep widgets small and composable
- Use meaningful variable names

## Pull Request Process

1. Ensure `flutter analyze` passes with 0 issues
2. Test on at least one platform (Windows/Chrome/Android)
3. Update documentation if adding new features
4. Write clear commit messages
5. Reference any related issues

## Commit Messages

Format: `type: short description`

Types:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Formatting (no logic change)
- `refactor:` Code restructuring
- `test:` Adding tests
- `chore:` Build/tooling changes

## Architecture Guidelines

- **Models** → `lib/models/` (data classes with toJson/fromJson)
- **Services** → `lib/services/` (business logic, static methods)
- **Providers** → `lib/providers/` (state management)
- **Screens** → `lib/screens/{feature}/` (UI)
- **Config** → `lib/config/` (theme, constants)

## Adding New Foods

Edit `lib/services/food_database.dart`:

```dart
FoodItem(
  id: 'unique_id',
  name: 'Food Name',
  category: 'Category',
  servingSize: 100,     // grams
  servingUnit: 'g',
  calories: 200,        // per serving
  protein: 10,          // grams
  carbs: 25,            // grams
  fat: 8,               // grams
),
```

## Questions?

Open an issue or email: vivekboora11@gmail.com
