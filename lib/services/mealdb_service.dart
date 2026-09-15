import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal.dart';

class MealDbService {
  static const _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<Meal?> searchByName(String name) async {
    final uri = Uri.parse('$_baseUrl/search.php').replace(
      queryParameters: {'s': name},
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('MealDB API error: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final meals = body['meals'] as List?;
    if (meals == null || meals.isEmpty) return null;

    return Meal.fromJson(meals.first as Map<String, dynamic>);
  }
}
