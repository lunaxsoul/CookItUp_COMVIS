import 'package:flutter/material.dart';

import 'profile_screen.dart';
import 'history_screen.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildDailySummary(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      title: 'Nutrient Breakdown',
                      action: 'Details',
                    ),
                    const SizedBox(height: 12),
                    _buildNutrientBreakdown(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      title: 'Your Nutrition Goals',
                      action: 'Edit',
                    ),
                    const SizedBox(height: 12),
                    _buildNutritionGoals(),
                    const SizedBox(height: 12),
                    _buildGoodJobCard(),
                    const SizedBox(height: 20),
                  ],
                ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nutrition',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF183B32),
                  height: 1.1,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Know what you eat. Fuel your body.',
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
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E6DF)),
          ),
          child: const Icon(
            Icons.calendar_today_outlined,
            size: 21,
            color: Color(0xFF183B32),
          ),
        ),
      ],
    );
  }

  Widget _buildDailySummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1E5DE)),
      ),
      child: Row(
        children: [
          Expanded(flex: 5, child: _buildCaloriesCircle()),
          const SizedBox(width: 12),
          Expanded(
            flex: 7,
            child: Column(
              children: [
                _buildMacroRow(
                  icon: Icons.local_fire_department_outlined,
                  iconColor: const Color(0xFFE77858),
                  name: 'Carbs',
                  amount: '148g',
                  percentage: '53%',
                  progress: 0.53,
                ),
                const SizedBox(height: 13),
                _buildMacroRow(
                  icon: Icons.spa_outlined,
                  iconColor: const Color(0xFF4D806F),
                  name: 'Protein',
                  amount: '72g',
                  percentage: '25%',
                  progress: 0.72,
                ),
                const SizedBox(height: 13),
                _buildMacroRow(
                  icon: Icons.local_fire_department_outlined,
                  iconColor: const Color(0xFFD69B2D),
                  name: 'Fat',
                  amount: '38g',
                  percentage: '22%',
                  progress: 0.38,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCircle() {
    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 132,
              height: 132,
              child: CircularProgressIndicator(
                value: 0.62,
                strokeWidth: 9,
                backgroundColor: const Color(0xFFE4E9E4),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF4E876F),
                ),
              ),
            ),
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF78928B),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '1,240',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF183B32),
                  ),
                ),
                Text(
                  'kcal',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF78928B),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '/ 2,000 kcal',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF607970),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow({
    required IconData icon,
    required Color iconColor,
    required String name,
    required String amount,
    required String percentage,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF38564E),
                ),
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF607970),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              percentage,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF78928B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const LinearProgressIndicator(
            value: 0.53,
            minHeight: 8,
            backgroundColor: Color(0xFFE7EAE6),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B907C)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String action,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF183B32),
          ),
        ),
        const Spacer(),
        Text(
          action,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF82928B),
          ),
        ),
        const SizedBox(width: 3),
        const Icon(
          Icons.chevron_right_rounded,
          size: 19,
          color: Color(0xFF9BA8A2),
        ),
      ],
    );
  }

  Widget _buildNutrientBreakdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E5DE)),
      ),
      child: Column(
        children: [
          _buildNutrientRow(
            icon: Icons.eco_outlined,
            iconBackground: const Color(0xFFE4F0E5),
            iconColor: const Color(0xFF4B8666),
            name: 'Fiber',
            amount: '8g',
            percentage: '32%',
            progress: 0.32,
          ),
          _buildDivider(),
          _buildNutrientRow(
            icon: Icons.inventory_2_outlined,
            iconBackground: const Color(0xFFF5EBD2),
            iconColor: const Color(0xFFD49C40),
            name: 'Sugar',
            amount: '18g',
            percentage: '12%',
            progress: 0.12,
          ),
          _buildDivider(),
          _buildNutrientRow(
            icon: Icons.water_drop_outlined,
            iconBackground: const Color(0xFFE1ECF5),
            iconColor: const Color(0xFF668DAE),
            name: 'Sodium',
            amount: '1,240mg',
            percentage: '54%',
            progress: 0.54,
          ),
          _buildDivider(),
          _buildNutrientRow(
            icon: Icons.local_fire_department_outlined,
            iconBackground: const Color(0xFFF5E0DB),
            iconColor: const Color(0xFFE77858),
            name: 'Cholesterol',
            amount: '120mg',
            percentage: '40%',
            progress: 0.40,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String name,
    required String amount,
    required String percentage,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 60,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF536960),
              ),
            ),
          ),
          SizedBox(
            width: 55,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF607970),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: const Color(0xFFE8EBE7),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF659484),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 30,
            child: Text(
              percentage,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF8A9891),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE8EAE5),
      indent: 58,
      endIndent: 12,
    );
  }

  Widget _buildNutritionGoals() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E5DE)),
      ),
      child: Column(
        children: [
          _buildGoalRow(
            icon: Icons.local_fire_department_outlined,
            iconBackground: const Color(0xFFF5E0DB),
            iconColor: const Color(0xFFE77858),
            title: 'Calories',
            value: '2,000 kcal',
            current: '1,240 / 2,000',
            progress: 0.62,
          ),
          _buildDivider(),
          _buildGoalRow(
            icon: Icons.spa_outlined,
            iconBackground: const Color(0xFFE3EFE4),
            iconColor: const Color(0xFF4D866C),
            title: 'Protein',
            value: '100 g',
            current: '72 / 100',
            progress: 0.72,
          ),
          _buildDivider(),
          _buildGoalRow(
            icon: Icons.eco_outlined,
            iconBackground: const Color(0xFFE3EFE4),
            iconColor: const Color(0xFF4D866C),
            title: 'Fiber',
            value: '25 g',
            current: '8 / 25',
            progress: 0.32,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalRow({
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String value,
    required String current,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6A7A73),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF38564E),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  current,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF7A8A83),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE8EBE7),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF659484),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoodJobCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2E7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE7D8)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF6F8F2),
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFF476B5B),
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good job!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF38564E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You’re on track with your protein intake\n'
                  'today. Keep it up!',
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: Color(0xFF71857E),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.eco_outlined,
            size: 54,
            color: Color(0x66A8C3A0),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home'),
      (Icons.history_rounded, 'History'),
      (Icons.eco_rounded, 'Nutrition'),
      (Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 11),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F7F2),
        border: Border(
          top: BorderSide(color: Color(0xFFE7E9E4)),
        ),
      ),
      child: Row(
        children: List.generate(
          items.length,
          (index) {
            final selected = index == 2;
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
                  if (index == 1) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HistoryScreen(),
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
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
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
}
