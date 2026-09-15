import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/food_prediction.dart';
import '../models/meal.dart';
import '../services/mealdb_service.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({
    super.key,
    required this.prediction,
  });

  final FoodPrediction prediction;

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final _mealDbService = MealDbService();

  late final Future<Meal?> _mealFuture;
  late final Future<List<Meal>> _moreIdeasFuture;

  @override
  void initState() {
    super.initState();

    _mealFuture = _mealDbService.searchByName(widget.prediction.label);
    _moreIdeasFuture = _loadMoreIdeas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: FutureBuilder<Meal?>(
                future: _mealFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF285F53),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildError(
                      'Gagal memuat resep. Periksa koneksi internet kamu.',
                    );
                  }

                  final meal = snapshot.data;

                  if (meal == null) {
                    return _buildError(
                      'Belum ada resep yang cocok untuk "${_prettyFoodName(widget.prediction.label)}".',
                    );
                  }

                  return _buildRecipeContent(meal);
                },
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
            'Recipe Ideas',
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

  Widget _buildRecipeContent(Meal meal) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
      children: [
        _buildHeroImage(meal),
        const SizedBox(height: 20),
        Text(
          _recipeTitle(meal),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF183B32),
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        _buildMetaRow(meal),
        const SizedBox(height: 18),
        Text(
          _description(meal),
          style: const TextStyle(
            fontSize: 15,
            height: 1.55,
            color: Color(0xFF647A72),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FullRecipeScreen(meal: meal),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF285F53),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View Full Recipe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 9),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'More Ideas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF183B32),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<Meal>>(
          future: _moreIdeasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF285F53),
                    ),
                  ),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return _moreIdeasFallback(meal);
            }

            final ideas = snapshot.data!;

            if (ideas.isEmpty) {
              return _moreIdeasFallback(meal);
            }

            return Column(
              children: ideas
                  .take(4)
                  .map(
                    (idea) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildIdeaCard(idea),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeroImage(Meal meal) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 1.42,
            child: meal.thumbnailUrl.isEmpty
                ? Container(
                    color: const Color(0xFFE8EDE7),
                    child: const Icon(
                      Icons.restaurant,
                      size: 60,
                      color: Color(0xFF285F53),
                    ),
                  )
                : Image.network(
                    meal.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: const Color(0xFFE8EDE7),
                        child: const Icon(
                          Icons.restaurant,
                          size: 60,
                          color: Color(0xFF285F53),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFFE8EDE7),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF285F53),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: Material(
            color: const Color(0xCC285F53),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.all(11),
                child: Icon(
                  Icons.bookmark_border,
                  size: 23,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(Meal meal) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _metaPill(
          Icons.access_time,
          _estimatedTime(meal),
        ),
        _metaPill(
          Icons.sentiment_satisfied_alt_outlined,
          'Easy',
        ),
        _metaPill(
          Icons.local_fire_department_outlined,
          '420 kcal',
        ),
      ],
    );
  }

  Widget _metaPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2EC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF285F53),
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5D736B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdeaCard(Meal meal) {
    return Material(
      color: const Color(0xFFFBFAF5),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FullRecipeScreen(meal: meal),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 82,
                  height: 70,
                  child: meal.thumbnailUrl.isEmpty
                      ? Container(
                          color: const Color(0xFFE8EDE7),
                          child: const Icon(
                            Icons.restaurant,
                            color: Color(0xFF285F53),
                          ),
                        )
                      : Image.network(
                          meal.thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: const Color(0xFFE8EDE7),
                              child: const Icon(
                                Icons.restaurant,
                                color: Color(0xFF285F53),
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF183B32),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${_estimatedTime(meal)}  ·  Easy  ·  380 kcal',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF71827C),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                size: 24,
                color: Color(0xFF8A9892),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _moreIdeasFallback(Meal meal) {
    return _buildIdeaCard(meal);
  }

  Future<List<Meal>> _loadMoreIdeas() async {
    final meal = await _mealFuture;

    if (meal == null) return [];

    final category = meal.category;

    if (category == null || category.trim().isEmpty) {
      return [];
    }

    final uri = Uri.parse(
      'https://www.themealdb.com/api/json/v1/1/filter.php',
    ).replace(
      queryParameters: {'c': category},
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('MealDB error: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final rawMeals = body['meals'] as List?;

    if (rawMeals == null) return [];

    return rawMeals
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => Meal(
            id: item['idMeal']?.toString() ?? '',
            name: item['strMeal']?.toString() ?? '-',
            thumbnailUrl: item['strMealThumb']?.toString() ?? '',
            instructions: '',
            ingredients: const [],
          ),
        )
        .where(
          (item) =>
              item.name.toLowerCase() !=
              _recipeTitle(meal).toLowerCase(),
        )
        .toList();
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant_menu_outlined,
              size: 52,
              color: Color(0xFF285F53),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF647A72),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF285F53),
                side: const BorderSide(
                  color: Color(0xFFAFC4BE),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }

  String _recipeTitle(Meal meal) {
    final name = meal.name.trim();
    if (name.isEmpty || name == '-') {
      return _prettyFoodName(widget.prediction.label);
    }

    return name;
  }

  String _description(Meal meal) {
    final instruction = meal.instructions.trim();

    if (instruction.isEmpty) {
      return 'A fresh and balanced recipe made with simple ingredients. '
          'Perfect for a healthy meal!';
    }

    final cleaned = instruction.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (cleaned.length <= 150) return cleaned;

    return '${cleaned.substring(0, 147)}...';
  }

  String _estimatedTime(Meal meal) {
    // TheMealDB does not provide cooking time in the current model.
    // Keep the visual format consistent with the mockup. Might delete it later
    return '15 min';
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

class FullRecipeScreen extends StatefulWidget {
  const FullRecipeScreen({
    super.key,
    required this.meal,
  });

  final Meal meal;

  @override
  State<FullRecipeScreen> createState() => _FullRecipeScreenState();
}

class _FullRecipeScreenState extends State<FullRecipeScreen> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
                    'Full Recipe',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF183B32),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 30),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 1.42,
                      child: meal.thumbnailUrl.isEmpty
                          ? Container(
                              color: const Color(0xFFE8EDE7),
                              child: const Icon(
                                Icons.restaurant,
                                size: 60,
                                color: Color(0xFF285F53),
                              ),
                            )
                          : Image.network(
                              meal.thumbnailUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  color: const Color(0xFFE8EDE7),
                                  child: const Icon(
                                    Icons.restaurant,
                                    size: 60,
                                    color: Color(0xFF285F53),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF183B32),
                    ),
                  ),
                  if (meal.category != null || meal.area != null) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (meal.category != null)
                          _tag(meal.category!),
                        if (meal.area != null) _tag(meal.area!),
                      ],
                    ),
                  ],
                  const SizedBox(height: 26),
                  _sectionTitle(
                    icon: Icons.shopping_basket_outlined,
                    title: 'Ingredients',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2EA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: meal.ingredients
                          .map(
                            (ingredient) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 9,
                              ),
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
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      ingredient.measure,
                                      textAlign: TextAlign.right,
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
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Instructions',
                  ),
                  const SizedBox(height: 14),
                  ..._instructionSteps(meal.instructions).asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFFDCE8DE),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF285F53),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.45,
                                color: Color(0xFF4F6B62),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _saved = !_saved);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF285F53),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _saved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 21,
                          ),
                          const SizedBox(width: 9),
                          Text(
                            _saved ? 'Recipe Saved' : 'Save Recipe',
                            style: const TextStyle(
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

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2EC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF5D736B),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 23,
          color: const Color(0xFF285F53),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF183B32),
          ),
        ),
      ],
    );
  }

  List<String> _instructionSteps(String instructions) {
    final cleaned = instructions
        .replaceAll('\r', '')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .trim();

    if (cleaned.isEmpty) {
      return const [
        'Prepare all ingredients before cooking.',
        'Follow the recipe preparation and cooking process.',
        'Serve immediately and enjoy your meal.',
      ];
    }

    final paragraphs = cleaned
        .split(RegExp(r'\n+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (paragraphs.length > 1) {
      return paragraphs;
    }

    final sentences = cleaned
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (sentences.length <= 1) {
      return [cleaned];
    }

    return sentences;
  }
}
