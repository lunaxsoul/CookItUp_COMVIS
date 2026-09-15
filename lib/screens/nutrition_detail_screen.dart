import 'package:flutter/material.dart';

import '../models/food_prediction.dart';
import '../models/meal.dart';
import '../services/mealdb_service.dart';

class NutritionDetailScreen extends StatefulWidget {
  const NutritionDetailScreen({
    super.key,
    required this.prediction,
  });

  final FoodPrediction prediction;

  @override
  State<NutritionDetailScreen> createState() => _NutritionDetailScreenState();
}

class _NutritionDetailScreenState extends State<NutritionDetailScreen> {
  final _mealDbService = MealDbService();

  late final Future<Meal?> _mealFuture;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();

    _mealFuture = widget.prediction.isRecognized
        ? _mealDbService.searchByName(widget.prediction.label)
        : Future.value(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      body: SafeArea(
        child: Stack(
          children: [
            const _BottomLeafDecoration(),
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 35),
                    children: [
                      _buildFoodSummary(),
                      const SizedBox(height: 24),
                      _buildTabs(),
                      const SizedBox(height: 24),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _selectedTab == 0
                            ? _buildNutritionTab()
                            : _buildIngredientsTab(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
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
            'Nutrition Details',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Color(0xFF183B32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodSummary() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            widget.prediction.image,
            width: 104,
            height: 104,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _prettyFoodName(widget.prediction.label),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: Color(0xFF183B32),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _confidencePill(
                    _confidenceLabel(widget.prediction.confidence),
                  ),
                  _confidencePill(
                    '${(widget.prediction.confidence * 100).round()}%',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _confidencePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F0E7),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF285F53),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF6),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFE3E5DE),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton(
              title: 'Nutrition',
              selected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          Expanded(
            child: _tabButton(
              title: 'Ingredients',
              selected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF285F53)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(27),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected
                ? FontWeight.w700
                : FontWeight.w500,
            color: selected
                ? Colors.white
                : const Color(0xFF81908A),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionTab() {
    return Column(
      key: const ValueKey('nutrition'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.25,
          children: [
            _nutritionCard(
              icon: Icons.local_fire_department_outlined,
              iconColor: const Color(0xFFD96C63),
              value: '420',
              label: 'Calories',
            ),
            _nutritionCard(
              icon: Icons.spa_outlined,
              iconColor: const Color(0xFF285F53),
              value: '35g',
              label: 'Protein',
            ),
            _nutritionCard(
              icon: Icons.water_drop_outlined,
              iconColor: const Color(0xFF637A87),
              value: '42g',
              label: 'Carbs',
            ),
            _nutritionCard(
              icon: Icons.local_fire_department_outlined,
              iconColor: const Color(0xFFE3A05C),
              value: '14g',
              label: 'Fat',
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Text(
          'More Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF183B32),
          ),
        ),
        const SizedBox(height: 13),
        _detailRow('Fiber', '7g'),
        _detailRow('Sugar', '6g'),
        _detailRow('Sodium', '320mg'),
      ],
    );
  }

  Widget _nutritionCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE9EAE4),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 26,
            color: iconColor,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF183B32),
                  ),
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF788780),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF6),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE8E9E3),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF66766F),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF384F47),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsTab() {
    return FutureBuilder<Meal?>(
      key: const ValueKey('ingredients'),
      future: _mealFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.only(top: 35),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF285F53),
              ),
            ),
          );
        }

        final meal = snapshot.data;

        if (meal == null || meal.ingredients.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2EA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'No ingredient details are available for this food yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF647A72),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2EA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: meal.ingredients.map((ingredient) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF35584E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      ingredient.measure,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF617A70),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _confidenceLabel(double confidence) {
    if (confidence >= 0.85) return 'High confidence';
    if (confidence >= 0.65) return 'Medium confidence';
    return 'Low confidence';
  }

  String _prettyFoodName(String value) {
    if (value.trim().isEmpty || value == '__background__') {
      return 'Unknown Food';
    }

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

class _BottomLeafDecoration extends StatelessWidget {
  const _BottomLeafDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 10,
            bottom: 0,
          ),
          child: Opacity(
            opacity: 0.24,
            child: Transform.rotate(
              angle: -0.18,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 42,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFA8C3A0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(45),
                        bottomRight: Radius.circular(45),
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(-12, 18),
                    child: Container(
                      width: 38,
                      height: 65,
                      decoration: const BoxDecoration(
                        color: Color(0xFFBDD0B6),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(45),
                          topRight: Radius.circular(45),
                          bottomLeft: Radius.circular(45),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
