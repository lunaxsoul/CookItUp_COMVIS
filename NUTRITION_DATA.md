# Nutrition data (estimates)

## Where it lives
- `assets/data/local_recipes.json` - each recipe has `nutKcal`, `nutProtein`, `nutCarbs`, `nutFat`,
  `nutFiber`, `nutSugar` (g), `nutSodium`, `nutCholesterol` (mg), `nutServing`, `nutBasis`.
- `assets/data/label_nutrition.json` - estimates keyed by lower-cased classifier label, for labels
  that have no recipe (e.g. "ramen", "pound cake"). Only ~250 of 2023 labels are covered.

## How the numbers were made
Keyword rules on the dish name (nasi goreng, rendang, soto, sate, kue, ...) give a typical value
PER SERVING. They are ESTIMATES, not measured data and not lab values. A photo cannot reveal portion
size, so every scan gets the same per-serving value. Show them as "approx." in the UI.

## Code
- `lib/models/meal.dart` - `Nutrition` class, `Meal.nutrition` (nullable).
- `lib/services/local_recipe_service.dart` - `nutritionForLabel(label, meal:)` returns recipe values,
  else label-table values, else null. Recipe matching is now whole-word ("bing" no longer matches "kambing").
- `lib/services/scan_history_service.dart` - saves scans (shared_preferences), daily totals, streak, goals.
- pubspec.yaml: `shared_preferences` dependency; `assets/data/label_nutrition.json` must be listed under assets.

## Known limits
- ~16% of classifier labels have any nutrition; the rest show "-".
- Rule-based estimates can be off for unusual dishes; fix by editing the rule table or adding recipes.
