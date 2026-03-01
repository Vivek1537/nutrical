# NutriCal 🍎

AI-Powered Meal & Calorie Tracker built with Flutter.

Track your nutrition, plan meals, scan barcodes, build recipes, and achieve your health goals — all in one app.

## Features

| Feature | Description |
|---------|-------------|
| 🏠 **Dashboard** | Calorie ring, macro progress bars, water tracker |
| 🍽️ **Food Database** | 65+ Indian & international foods with full nutrition data |
| 🔍 **AI Food Search** | Smart search across local DB + Open Food Facts (millions of products) |
| 📷 **Barcode Scanner** | Scan packaged food barcodes for instant nutrition info |
| 🍳 **Recipe Builder** | Combine ingredients, set servings, auto-calculate per-serving macros |
| 📖 **Diary** | Daily meal log grouped by meal type, swipe-to-delete |
| 📅 **Meal Planner** | 7-day weekly plan (Mon–Sun), add foods per meal type |
| 🛒 **Grocery List** | Auto-generated from meal plan, checkable items |
| 📊 **Insights** | Macro pie chart, weekly calorie bar chart, smart tips |
| 🔬 **Micro-Nutrients** | Track 10 vitamins & minerals with progress bars |
| 🏆 **Challenges** | 6 health challenges to keep you motivated |
| 📄 **PDF Reports** | Export weekly progress reports as PDF |
| 👤 **Profile** | BMR/TDEE auto-calculation, daily targets, settings |
| 🔐 **Auth** | Local auth (Firebase-ready architecture) |

## Screenshots

> _Coming soon_

## Quick Start

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.10+
- Windows / macOS / Linux / Chrome for development
- Android SDK (for Android builds)

### Run

```bash
# Clone
git clone https://github.com/Vivek1537/nutrical.git
cd nutrical

# Install dependencies
flutter pub get

# Run on Windows
flutter run -d windows

# Run on Chrome
flutter run -d chrome

# Run on connected Android device
flutter run

# Build APK
flutter build apk

# Build Windows exe
flutter build windows
```

## Project Structure

```
nutrical/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── app.dart                     # App widget + routing
│   ├── config/
│   │   └── theme.dart               # Material 3 theme + colors
│   ├── models/
│   │   ├── food_item.dart           # Food item with full nutrition
│   │   ├── meal_entry.dart          # Logged meal entry
│   │   ├── meal_plan.dart           # Weekly meal plan + day plan
│   │   ├── user_profile.dart        # User profile + targets
│   │   ├── water_entry.dart         # Water intake tracking
│   │   ├── recipe.dart              # Recipe with ingredients
│   │   ├── grocery_item.dart        # Grocery list item
│   │   ├── challenge.dart           # Health challenge
│   │   └── micro_nutrient.dart      # Vitamin/mineral tracking
│   ├── providers/
│   │   └── app_state.dart           # Global state (Provider)
│   ├── services/
│   │   ├── auth_service.dart        # Authentication
│   │   ├── barcode_service.dart     # Open Food Facts barcode lookup
│   │   ├── calorie_calculator.dart  # BMR/TDEE (Mifflin-St Jeor)
│   │   ├── food_database.dart       # 65+ food items database
│   │   ├── food_recognition_service.dart  # AI smart search
│   │   ├── meal_plan_service.dart   # Meal plan CRUD + grocery gen
│   │   ├── report_service.dart      # PDF report generation
│   │   ├── share_service.dart       # Export/share data
│   │   └── storage_service.dart     # SharedPreferences persistence
│   ├── screens/
│   │   ├── auth/                    # Login + Signup
│   │   ├── onboarding/             # 4-page setup wizard
│   │   ├── home/                    # Dashboard
│   │   ├── diary/                   # Diary, Add Food, Barcode, Recipe, AI Search
│   │   ├── planner/                # Weekly meal planner
│   │   ├── grocery/                # Grocery list
│   │   ├── insights/               # Charts + micro-nutrients
│   │   ├── profile/                # Profile + settings access
│   │   ├── settings/               # Settings hub + premium
│   │   └── social/                 # Challenges
│   ├── navigation/
│   │   └── main_shell.dart          # Bottom nav (5 tabs)
│   └── utils/
│       └── constants.dart           # App-wide constants
├── docs/
│   ├── ARCHITECTURE.md              # Technical architecture
│   ├── SECURITY.md                  # Security practices
│   ├── API_REFERENCE.md             # External APIs used
│   └── CONTRIBUTING.md              # Contribution guidelines
├── .github/
│   └── workflows/
│       └── ci.yaml                  # CI pipeline
├── .gitignore
├── LICENSE                          # MIT
├── README.md
├── CHANGELOG.md
└── pubspec.yaml
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.x (Dart) |
| **State** | Provider |
| **Storage** | SharedPreferences (offline-first) |
| **Charts** | fl_chart |
| **PDF** | pdf + printing |
| **Barcode** | mobile_scanner |
| **Food API** | Open Food Facts (free, no key) |
| **Fonts** | Google Fonts |
| **Design** | Material 3 |

## Nutrition Calculation

- **BMR**: Mifflin-St Jeor equation
- **TDEE**: BMR × activity multiplier (1.2–1.9)
- **Macros**: Protein 30%, Carbs 45%, Fat 25% of target
- **Water**: 35ml per kg body weight

## Roadmap

- [ ] Firebase Cloud Sync (Auth + Firestore)
- [ ] AI photo food recognition (TFLite/Google Vision)
- [ ] Social features (friends, leaderboards)
- [ ] Wearable integration (Google Fit / Apple Health)
- [ ] Multi-language support (Hindi, Tamil, Telugu)
- [ ] Dark mode
- [ ] iOS & macOS builds

## Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

## License

[MIT](LICENSE) © 2026 Vivek Boora
