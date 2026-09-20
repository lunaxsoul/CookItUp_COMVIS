# Recipe Database Migration - MealDB → Local Database

## What changed and why

MealDB only had a ~10% hit rate against our classifier's 2024 food labels
(most misses were Indonesian dishes MealDB simply doesn't have). To hit our
professor's 1000-2000 recipe requirement and fix the coverage gap, we built
our own recipe database: 23 hand-curated Indonesian recipes plus ~2140
scraped from Cookpad Indonesia, cleaned and deduplicated. MealDB is now
fully replaced, not just supplemented.

**Total: 2164 recipes**, all Indonesian dishes (plus a few correctly-labeled
foreign/fusion dishes home cooks posted), covering the specific gaps MealDB
couldn't fill.

## Files added

- `assets/data/local_recipes.json` - the recipe database (2164 recipes,
  same field shape MealDB's API used - idMeal, strMeal, strCategory,
  strArea, strInstructions, strMealThumb, strIngredientN/strMeasureN - so
  the existing `Meal.fromJson` needed zero changes)
- `lib/services/local_recipe_service.dart` - drop-in replacement for
  `MealDbService`, same `searchByName(String)` interface, reads from the
  bundled JSON asset instead of a network call. Also includes a small
  alias table translating generic English classifier labels (e.g. "Fried
  rice", "Satay", "Meatball") to the Indonesian search term that actually
  matches our data - the raw English label has zero text overlap with our
  Indonesian-named recipes otherwise. **If a scan comes back with no
  recipe found and the label looks like a generic English food term, that's
  probably a missing alias - add one line to `_labelAliases` in this
  file.**

## Files changed

- `pubspec.yaml` - added `assets/data/local_recipes.json` under `assets:`
- `lib/screens/recipe_screen.dart` - swapped `MealDbService` for
  `LocalRecipeService` (imports, service field, initState call). Also
  rewrote `_loadMoreIdeas()`: it used to hit MealDB's `filter.php` live for
  the "More Ideas" section; now it filters the local data by category
  instead, so this no longer needs `dart:convert` or `package:http`.

## Two unrelated environment fixes bundled into this same work

These aren't part of the recipe migration itself, but came up while getting
this running and are worth calling out so they don't look like mystery
changes in the diff:

### `android/gradle.properties`
Had a line `org.gradle.java.home=C:/Program Files/Java/jdk-25.0.2`
hardcoded to a specific JDK path that doesn't exist on other machines (it
broke the build entirely for me). This was almost certainly someone's local
machine-specific path that got committed by accident - it should never have
been checked in. **Removed the line.** Gradle now auto-detects a valid JDK
instead. If your build was somehow relying on that exact path, let me know,
but this is very unlikely to be intentional.

### `android/app/src/main/AndroidManifest.xml`
Was missing `<uses-permission android:name="android.permission.INTERNET" />`
entirely. Without it, Android silently blocks all network requests -
**this means recipe photos (and possibly MealDB data itself, before this
migration) may never have actually loaded in the live app**, even though
everything looked fine in code. **Added the permission.** This is a real
bug fix, not a personal workaround - it affects networking app-wide, not
just the recipe feature.

## Known limitations (not blocking, documented for later)

- 23 of the 2164 recipes (the original hand-curated set) have no photo -
  the app falls back to a placeholder icon for these, which is expected.
- ~31 recipes have nested/multi-section step numbering (a sub-procedure
  restarting its own 1-2-3 count mid-recipe) that wasn't safe to
  auto-reformat without risking corrupting the steps. These will display
  with the original raw numbering until reviewed individually.
- A near-duplicate review list exists from the cleanup pass (dishes with
  similar names/ingredients that might be the same recipe posted twice, or
  might be genuinely different home-cooks' variants of the same dish - not
  auto-resolved since that's a judgment call, not something to decide
  automatically).
- The `_labelAliases` map in `local_recipe_service.dart` only covers a
  handful of confirmed English-label mismatches found so far (Fried rice,
  Satay, Meatball, Fried chicken, Chicken curry, Mutton curry, Omelette,
  Dumpling, Pancake, Oxtail soup). The classifier has 2024 labels total: if
  testing turns up more "no recipe found" results that look like generic
  English food terms, add more entries to that map.

## Data source / attribution

Recipes were scraped from Cookpad Indonesia (cookpad.com/id), a
user-generated recipe platform - individual recipes remain the intellectual
property of the home cooks who posted them. Used here for non-commercial
university coursework. If this project is ever taken beyond coursework
(published, monetized), this data source needs a fresh look - scraping is
fine for a class project, but isn't the same as having a redistribution
license for something you'd actually ship.
