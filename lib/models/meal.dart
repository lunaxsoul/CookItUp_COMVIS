class Meal {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String instructions;
  final String? category;
  final String? area;
  final List<MealIngredient> ingredients;
  final Nutrition? nutrition;

  const Meal({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.instructions,
    required this.ingredients,
    this.category,
    this.area,
    this.nutrition,
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
      nutrition: Nutrition.fromJson(json),
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

/// Estimated nutrition per typical serving (dish-level estimate, not measured).
class Nutrition {
  final int kcal;
  final double protein; // g
  final double carbs; // g
  final double fat; // g
  final double fiber; // g
  final double sugar; // g
  final double sodium; // mg
  final double cholesterol; // mg
  final String serving;

  const Nutrition({
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.cholesterol,
    required this.serving,
  });

  static Nutrition? fromJson(Map<String, dynamic> json) {
    if (json['nutKcal'] == null) return null;
    double d(String k) => (json[k] as num?)?.toDouble() ?? 0;
    return Nutrition(
      kcal: (json['nutKcal'] as num).toInt(),
      protein: d('nutProtein'),
      carbs: d('nutCarbs'),
      fat: d('nutFat'),
      fiber: d('nutFiber'),
      sugar: d('nutSugar'),
      sodium: d('nutSodium'),
      cholesterol: d('nutCholesterol'),
      serving: json['nutServing']?.toString() ?? '1 porsi',
    );
  }

  Map<String, dynamic> toJson() => {
        'kcal': kcal, 'protein': protein, 'carbs': carbs, 'fat': fat,
        'fiber': fiber, 'sugar': sugar, 'sodium': sodium,
        'cholesterol': cholesterol, 'serving': serving,
      };
}
