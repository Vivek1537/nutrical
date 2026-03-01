# Architecture

## Overview

NutriCal follows a clean, layered architecture designed for offline-first operation with future cloud sync capability.

```
┌─────────────────────────────┐
│         UI Layer            │  Screens, Widgets, Navigation
├─────────────────────────────┤
│       State Layer           │  Provider (AppState)
├─────────────────────────────┤
│      Service Layer          │  Business logic, API calls
├─────────────────────────────┤
│       Data Layer            │  SharedPreferences, Models
└─────────────────────────────┘
```

## State Management

**Provider** pattern with a single `AppState` ChangeNotifier:
- Holds today's meals, water intake, user profile
- Auto-loads on `init()` from SharedPreferences
- Notifies UI on any data change

## Data Flow

```
User Action → Screen → AppState.method() → StorageService → SharedPreferences
                                         → Notify Listeners → UI Rebuild
```

## Storage Strategy

| Data | Storage | Format |
|------|---------|--------|
| User Profile | SharedPreferences | JSON |
| Meal Entries | SharedPreferences | JSON (keyed by date) |
| Water Intake | SharedPreferences | JSON (keyed by date) |
| Meal Plans | SharedPreferences | JSON |
| Grocery List | SharedPreferences | JSON |
| Challenges | SharedPreferences | JSON |

### Future: Firebase Migration
The architecture is designed for easy migration:
1. `StorageService` → `FirestoreService` (same interface)
2. `AuthService` already has Firebase-compatible API
3. Models all have `toJson()`/`fromJson()` for Firestore

## External APIs

| API | Purpose | Auth |
|-----|---------|------|
| Open Food Facts | Barcode lookup + food search | None (free) |

## Nutrition Engine

### BMR Calculation (Mifflin-St Jeor)
- Male: `10 × weight(kg) + 6.25 × height(cm) - 5 × age - 161 + 166`
- Female: `10 × weight(kg) + 6.25 × height(cm) - 5 × age - 161`

### Macro Distribution
- Protein: 30% of daily calories ÷ 4 cal/g
- Carbs: 45% of daily calories ÷ 4 cal/g
- Fat: 25% of daily calories ÷ 9 cal/g

### Water Target
- 35ml × body weight (kg)

## Navigation

5-tab bottom navigation:
1. **Home** — Dashboard with calorie ring, macros, water
2. **Diary** — Meal log + Add Food (search/scan/recipe)
3. **Planner** — 7-day meal plan + grocery list
4. **Insights** — Charts, analytics, micro-nutrients
5. **Profile** — Personal info, targets, settings, features
