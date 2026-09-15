import 'package:flutter/material.dart';

import '../models/food_prediction.dart';
import '../models/meal.dart';
import '../services/mealdb_service.dart';
import 'recipe_screen.dart';
import 'nutrition_detail_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.prediction});

  final FoodPrediction prediction;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _mealDbService = MealDbService();
  late final Future<Meal?> _mealFuture;

  @override
  void initState() {
    super.initState();
    _mealFuture = widget.prediction.isRecognized
        ? _mealDbService.searchByName(widget.prediction.label)
        : Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    final prediction = widget.prediction;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                children: [
                  _buildFoodImage(prediction),
                  const SizedBox(height: 24),
                  _buildFoodTitle(prediction),
                  const SizedBox(height: 22),
                  _buildNutritionSection(),
                  const SizedBox(height: 22),
                  _buildConfidenceCard(prediction),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: prediction.isRecognized
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecipeScreen(
                                    prediction: prediction,
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF285F53),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFD8DED9),
                        disabledForegroundColor: const Color(0xFF8B9892),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Recipe Ideas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            icon: const Icon(
              Icons.arrow_back,
              size: 28,
              color: Color(0xFF183B32),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Food Result',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF183B32),
              height: 1.1,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              size: 27,
              color: Color(0xFF183B32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(FoodPrediction prediction) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.file(
        prediction.image,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFoodTitle(FoodPrediction prediction) {
    final title = prediction.isRecognized
        ? _prettyFoodName(prediction.label)
        : 'Food Not Recognized';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF183B32),
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9EFE9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _confidenceLabel(prediction.confidence),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF617A70),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (prediction.isRecognized)
          Container(
            margin: const EdgeInsets.only(top: 3),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFE7F0E7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '${(prediction.confidence * 100).round()}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF285F53),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNutritionSection() {
    // FoodPrediction is still dummy
    // Find and change with backend later
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Nutrition Facts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF183B32),
              ),
            ),
            const Spacer(),
            Material(
              color: const Color(0xFFE7F0E7),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NutritionDetailScreen(
                        prediction: widget.prediction,
                      ),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Color(0xFF285F53),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _nutritionCard(
                icon: Icons.local_fire_department_outlined,
                value: '420',
                unit: 'kcal',
                label: 'Calories',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _nutritionCard(
                icon: Icons.spa_outlined,
                value: '35g',
                unit: '',
                label: 'Protein',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _nutritionCard(
                icon: Icons.water_drop_outlined,
                value: '42g',
                unit: '',
                label: 'Carbs',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _nutritionCard(
                icon: Icons.set_meal_outlined,
                value: '14g',
                unit: '',
                label: 'Fat',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _nutritionCard({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) {
    return Container(
      height: 132,
      padding: const EdgeInsets.fromLTRB(8, 13, 8, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE5E7DF),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 25,
            color: const Color(0xFF285F53),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Color(0xFF183B32),
            ),
          ),
          if (unit.isNotEmpty)
            Text(
              unit,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF71857E),
              ),
            ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF71857E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(FoodPrediction prediction) {
    final recognized = prediction.isRecognized;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: recognized
            ? const Color(0xFFE7F1E4)
            : const Color(0xFFF1E8E4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            recognized
                ? Icons.check_circle_outline
                : Icons.info_outline,
            size: 28,
            color: recognized
                ? const Color(0xFF285F53)
                : const Color(0xFF9A5C4C),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recognized
                      ? _confidenceLabel(prediction.confidence)
                      : 'Low confidence',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF285F53),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  recognized
                      ? 'This food was identified with ${_confidenceLabel(prediction.confidence).toLowerCase()}.'
                      : 'The food could not be identified with enough confidence.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: Color(0xFF6D8179),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _confidenceLabel(double confidence) {
    if (confidence >= 0.85) return 'High confidence';
    if (confidence >= 0.65) return 'Medium confidence';
    return 'Low confidence';
  }

  String _prettyFoodName(String value) {
    if (value.trim().isEmpty) return 'Unknown Food';

    return value
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) => word.length == 1
              ? word.toUpperCase()
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}
