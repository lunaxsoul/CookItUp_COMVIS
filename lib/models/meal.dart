class Meal {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String instructions;
  final String? category;
  final String? area;
  final List<MealIngredient> ingredients;

  const Meal({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.instructions,
    required this.ingredients,
    this.category,
    this.area,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['idMeal']?.toString() ?? '',
      name: json['strMeal']?.toString() ?? '-',
      thumbnailUrl: json['strMealThumb']?.toString() ?? '',
      instructions: json['strInstructions']?.toString() ?? '',
      category: json['strCategory']?.toString(),
      area: json['strArea']?.toString(),
      ingredients: _parseIngredients(json),
    );
  }

  static List<MealIngredient> _parseIngredients(Map<String, dynamic> json) {
    final result = <MealIngredient>[];
    for (var i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i']?.toString().trim();
      final measure = json['strMeasure$i']?.toString().trim();
      if (ingredient == null || ingredient.isEmpty) continue;
      result.add(MealIngredient(name: ingredient, measure: measure ?? ''));
    }
    return result;
  }
}

class MealIngredient {
  final String name;
  final String measure;

  const MealIngredient({required this.name, required this.measure});
}
