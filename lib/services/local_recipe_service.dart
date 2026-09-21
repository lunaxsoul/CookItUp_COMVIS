import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/meal.dart';

/// Replaces MealDbService: same searchByName(String) -> Future<Meal?>
/// interface, but reads from the bundled local_recipes.json asset instead
/// of making a network call to themealdb.com.
///
/// The JSON file must be listed under `assets:` in pubspec.yaml, e.g.:
///   flutter:
///     assets:
///       - assets/data/local_recipes.json
class LocalRecipeService {
  static const _assetPath = 'assets/data/local_recipes.json';

  // The classifier's labels are a mix of Indonesian dish names ("Rendang")
  // and generic English food terms ("Fried rice", "Satay", "Meatball").
  // The English ones have zero text overlap with our Indonesian-named
  // recipes, so they'd never match on their own. This maps known English
  // labels to a search term that actually finds the right dish.
  //
  // Only add an entry here once you've confirmed it actually matches a
  // real recipe - a wrong/forced translation (e.g. mapping something to
  // an unrelated dish just to avoid "no recipe found") is worse than
  // showing nothing, since it actively misleads the user.
  static const Map<String, String> _labelAliases = {
    'fried rice': 'nasi goreng',
    'satay': 'sate',
    'meatball': 'bakso',
    'fried chicken': 'ayam goreng',
    'chicken curry': 'gulai ayam',
    'mutton curry': 'gulai kambing',
    'omelette': 'dadar telur',
    'dumpling': 'pangsit',
    'pancake': 'dadar gulung',
    'oxtail soup': 'sop buntut',
  };

  // Cached after first load so the 2000+ recipe file is only parsed once,
  // not on every recipe screen open.
  static List<Map<String, dynamic>>? _cache;

  Future<List<Map<String, dynamic>>> _loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as List;
    _cache = decoded.cast<Map<String, dynamic>>();
    return _cache!;
  }

  /// Same signature as MealDbService.searchByName - looks for an exact
  /// name match first, then falls back to a loose substring match.
  ///
  /// When multiple substring matches exist (e.g. searching "Rendang" could
  /// match "Rendang", "Ayam Rendang", "Rendang Daging", "Rendang Jengkol"...),
  /// this prefers the SHORTEST matching title - the one closest to the bare
  /// search term - rather than whichever happens to appear first in the
  /// file. A generic classifier label like "Rendang" (with no protein
  /// qualifier) should resolve to the generic "Rendang" entry, not an
  /// arbitrary specific variant picked by scrape order.
  Future<Meal?> searchByName(String name) async {
    final all = await _loadAll();
    final query = name.trim().toLowerCase();
    if (query.isEmpty) return null;

    final result = await _search(all, query);
    if (result != null) return result;

    // Raw label found nothing - try the Indonesian translation, if we
    // have one for this label.
    final alias = _labelAliases[query];
    if (alias != null) {
      return _search(all, alias);
    }

    return null;
  }

  Future<Meal?> _search(List<Map<String, dynamic>> all, String query) async {
    for (final item in all) {
      final title = (item['strMeal'] as String? ?? '').toLowerCase();
      if (title == query) return Meal.fromJson(item);
    }

    Map<String, dynamic>? bestMatch;
    int bestLength = 1 << 30;
    for (final item in all) {
      final title = (item['strMeal'] as String? ?? '').toLowerCase();
      if (title.contains(query) || query.contains(title)) {
        if (title.length < bestLength) {
          bestLength = title.length;
          bestMatch = item;
        }
      }
    }

    return bestMatch != null ? Meal.fromJson(bestMatch) : null;
  }

  /// Replaces the MealDB filter.php call in recipe_screen.dart's
  /// _loadMoreIdeas(). Returns other recipes in the same category,
  /// excluding the one currently being shown, shuffled so "More Ideas"
  /// doesn't show the exact same 4 recipes every time.
  Future<List<Meal>> findByCategory(String category, {String? excludeName}) async {
    final all = await _loadAll();
    final normalizedCategory = category.trim().toLowerCase();
    if (normalizedCategory.isEmpty) return [];

    final matches = all
        .where((item) => (item['strCategory'] as String? ?? '').toLowerCase() == normalizedCategory)
        .map((item) => Meal.fromJson(item))
        .toList();

    if (excludeName != null) {
      final excludeLower = excludeName.toLowerCase();
      matches.removeWhere((m) => m.name.toLowerCase() == excludeLower);
    }

    matches.shuffle();
    return matches;
  }
}
