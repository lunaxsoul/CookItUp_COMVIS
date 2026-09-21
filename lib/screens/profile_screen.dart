import 'package:flutter/material.dart';

import 'nutrition_screen.dart';
import 'history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildProfileIdentity(),
                    const SizedBox(height: 24),
                    _buildStats(),
                    const SizedBox(height: 16),
                    _buildSection([
                      _buildMenuItem(
                        icon: Icons.auto_graph_rounded,
                        title: 'My Nutrition Goals',
                        subtitle: 'Set your calorie & macro goals',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.eco_outlined,
                        title: 'Diet Preferences',
                        subtitle: 'Allergy, diet type, and more',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Health Profile',
                        subtitle: 'Age, weight, height, activity level',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection([
                      _buildMenuItem(
                        icon: Icons.bookmark_border_rounded,
                        title: 'Saved Recipes',
                        subtitle: 'Your favorite recipes',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.photo_library_outlined,
                        title: 'Scan History',
                        subtitle: 'View all past scans',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        subtitle: 'Reminders & updates',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSection([
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        subtitle: 'FAQs and contact us',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.lightbulb_outline_rounded,
                        title: 'About the App',
                        subtitle: 'Version 1.0.0',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildLogoutButton(),
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F2ED),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE1E5DE)),
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: Color(0xFF183B32),
            size: 23,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileIdentity() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE7EDDF),
              ),
              child: const Center(
                child: Icon(
                  Icons.eco_rounded,
                  size: 52,
                  color: Color(0xFF6B8F71),
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF285F53),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Healthy You',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF183B32),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Better food choices, brighter days.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF78928B),
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E6DF)),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _StatItem(value: '12', label: 'Scans'),
          ),
          _StatDivider(),
          Expanded(
            child: _StatItem(value: '🔥 7', label: 'Day Streak'),
          ),
          _StatDivider(),
          Expanded(
            child: _StatItem(value: '⭐ Lv.2', label: 'Food Explorer'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFAF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E6DF)),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE7E9E3), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFDCE8DE),
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: const Color(0xFF285F53),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF38564E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF8B9892),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: Color(0xFF8BA198),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text(
          'Log Out',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF285F53),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    const items = [
      (Icons.home_outlined, 'Home'),
      (Icons.history_rounded, 'History'),
      (Icons.eco_outlined, 'Nutrition'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F7F2),
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7E1)),
        ),
      ),
      child: Row(
        children: List.generate(
          items.length,
          (index) {
            final selected = index == 3;
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

                  if (index == 2) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NutritionScreen(),
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
                          ? const Color(0xFF285F53)
                          : const Color(0xFFB0B8B2),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.$2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected
                            ? const Color(0xFF285F53)
                            : const Color(0xFFA8B0AB),
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

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF183B32),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF78928B),
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      color: const Color(0xFFDDE1DA),
    );
  }
}
