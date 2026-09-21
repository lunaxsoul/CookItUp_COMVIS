import 'package:flutter/material.dart';

import 'nutrition_screen.dart';
import 'profile_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';

  final List<_HistoryItem> _historyItems = const [
    _HistoryItem(
      name: 'Grilled Chicken Bowl',
      confidence: 0.92,
      date: 'Today, 09:14 AM',
      calories: '420 kcal',
      protein: '42g protein',
      type: 'Food',
      icon: Icons.ramen_dining_outlined,
    ),
    _HistoryItem(
      name: 'Grilled Salmon',
      confidence: 0.88,
      date: 'Yesterday, 07:32 PM',
      calories: '520 kcal',
      protein: '38g protein',
      type: 'Food',
      icon: Icons.set_meal_outlined,
    ),
    _HistoryItem(
      name: 'Açaí Bowl',
      confidence: 0.95,
      date: '27 Aug 2025, 12:15 PM',
      calories: '320 kcal',
      protein: '12g protein',
      type: 'Food',
      icon: Icons.breakfast_dining_outlined,
    ),
    _HistoryItem(
      name: 'Fried Rice',
      confidence: 0.87,
      date: '26 Aug 2025, 01:03 PM',
      calories: '410 kcal',
      protein: '10g protein',
      type: 'Food',
      icon: Icons.rice_bowl_outlined,
    ),
    _HistoryItem(
      name: 'Chicken Wrap',
      confidence: 0.90,
      date: '25 Aug 2025, 06:42 PM',
      calories: '360 kcal',
      protein: '28g protein',
      type: 'Food',
      icon: Icons.lunch_dining_outlined,
    ),
    _HistoryItem(
      name: 'Fruit Salad',
      confidence: 0.93,
      date: '24 Aug 2025, 11:20 AM',
      calories: '210 kcal',
      protein: '4g protein',
      type: 'Food',
      icon: Icons.apple_outlined,
    ),
  ];

  List<_HistoryItem> get _filteredItems {
    if (_selectedFilter == 'All') {
      return _historyItems;
    }

    return _historyItems
        .where((item) => item.type == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildBottomDecoration(),

                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 18),
                        _buildFilters(),
                        const SizedBox(height: 18),
                        _buildHistoryList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildBottomNavigation(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF183B32),
                  height: 1.1,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Your food scans and nutrition records.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF78928B),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFFBFAF6),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE1E5DE),
            ),
          ),
          child: const Icon(
            Icons.search_rounded,
            size: 23,
            color: Color(0xFF183B32),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    const filters = [
      'All',
      'Food',
      'Nutrition',
      'Date',
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = filter == _selectedFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF285F53)
                    : const Color(0xFFFBFAF6),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF285F53)
                      : const Color(0xFFE0E5DF),
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : const Color(0xFF6D8179),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList() {
    final items = _filteredItems;

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: items
          .map(
            (item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildHistoryCard(item),
        ),
      )
          .toList(),
    );
  }

  Widget _buildHistoryCard(_HistoryItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          // Coming soon History detail
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFAF6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE0E5DF),
            ),
          ),
          child: Row(
            children: [
              _buildFoodThumbnail(item),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF38564E),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${(item.confidence * 100).round()}% confidence',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF5F8A7C),
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      item.date,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF8B9892),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_outlined,
                          size: 17,
                          color: Color(0xFFE77858),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.calories,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF667A72),
                          ),
                        ),

                        const SizedBox(width: 15),

                        const Icon(
                          Icons.eco_outlined,
                          size: 17,
                          color: Color(0xFF4D866C),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.protein,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF667A72),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              const Icon(
                Icons.chevron_right_rounded,
                size: 25,
                color: Color(0xFF8BA198),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodThumbnail(_HistoryItem item) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFE9EFE7),
        border: Border.all(
          color: const Color(0xFFDCE4DB),
        ),
      ),
      child: Center(
        child: Icon(
          item.icon,
          size: 38,
          color: const Color(0xFF5D8976),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 48,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE0E5DF),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 52,
            color: Color(0xFF9CB4AA),
          ),
          SizedBox(height: 14),
          Text(
            'No records found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF38564E),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your food scans and nutrition records\n'
                'will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: Color(0xFF82928B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home'),
      (Icons.history_rounded, 'History'),
      (Icons.eco_outlined, 'Nutrition'),
      (Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 11),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F7F2),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE7E9E4),
          ),
        ),
      ),
      child: Row(
        children: List.generate(
          items.length,
              (index) {
            final selected = index == 1;
            final item = items[index];

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  if (index == 0) {
                    Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                    );
                    return;
                  }

                  if (index == 2) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NutritionScreen(),
                      ),
                    );
                    return;
                  }

                  if (index == 3) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                    return;
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.$1,
                      size: 25,
                      color: selected
                          ? const Color(0xFF17483F)
                          : const Color(0xFFAEB7B1),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.$2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? const Color(0xFF17483F)
                            : const Color(0xFFA2ACA6),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomDecoration() {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(
            right: 18,
            bottom: 4,
          ),
          child: Opacity(
            opacity: 0.22,
            child: Icon(
              Icons.eco_outlined,
              size: 82,
              color: const Color(0xFFA8C3A0),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryItem {
  const _HistoryItem({
    required this.name,
    required this.confidence,
    required this.date,
    required this.calories,
    required this.protein,
    required this.type,
    required this.icon,
  });

  final String name;
  final double confidence;
  final String date;
  final String calories;
  final String protein;
  final String type;
  final IconData icon;
}