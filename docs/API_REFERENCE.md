# API Reference

## External APIs

### Open Food Facts

Free, open-source food product database.

**Base URL**: `https://world.openfoodfacts.org`

#### Barcode Lookup
```
GET /api/v2/product/{barcode}.json
```

**Response fields used:**
- `product.product_name` — Food name
- `product.brands` — Brand name
- `product.nutriments.energy-kcal_100g` — Calories per 100g
- `product.nutriments.proteins_100g` — Protein per 100g
- `product.nutriments.carbohydrates_100g` — Carbs per 100g
- `product.nutriments.fat_100g` — Fat per 100g
- `product.serving_quantity` — Serving size

#### Product Search
```
GET /cgi/search.pl?search_terms={query}&json=1&page_size=10
```

**No authentication required.** Rate limit: ~100 requests/minute (be respectful).

**Documentation**: https://wiki.openfoodfacts.org/API

## Internal Services

### CalorieCalculator
- `calculateBMR(weight, height, age, gender)` — Mifflin-St Jeor
- `calculateTDEE(bmr, activityLevel)` — Activity multiplier
- `calculateMacros(tdee, goal)` — Protein/Carbs/Fat targets
- `calculateWater(weight)` — Daily water target

### StorageService
- `getMealsForDate(date)` → `List<MealEntry>`
- `saveMeal(entry)` → void
- `deleteMeal(id, date)` → void
- `getWaterForDate(date)` → `double` (ml)
- `addWater(date, ml)` → void
- `getProfile()` → `UserProfile?`
- `saveProfile(profile)` → void

### FoodDatabase
- `search(query)` → `List<FoodItem>` (searches name, category, brand)
- `getAll()` → `List<FoodItem>` (65 items)
- `getById(id)` → `FoodItem?`
