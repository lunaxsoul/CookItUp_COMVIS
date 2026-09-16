import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/classifier_service.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.classifier});

  final ClassifierService classifier;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNav = 0;

  void _openScanner({ImageSource? source}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodScanScreen(
          classifier: widget.classifier,
          initialSource: source,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 22, 28, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    const SizedBox(height: 30),
                    _buildScanCard(),
                    const SizedBox(height: 30),
                    const Text(
                      'Quick Access',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF183B32),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickCard(
                            icon: Icons.camera_alt_outlined,
                            title: 'Take a Photo',
                            subtitle: 'Use your camera',
                            onTap: () => _openScanner(source: ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _buildQuickCard(
                            icon: Icons.image_outlined,
                            title: 'Choose from Gallery',
                            subtitle: 'Pick from your photos',
                            onTap: () => _openScanner(source: ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good evening.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF78928B),
                ),
              ),
              SizedBox(height: 3),
              Text(
                "Let's eat better 🌱",
                style: TextStyle(
                  fontSize: 28,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF183B32),
                ),
              ),
              SizedBox(height: 14),
              Text(
                'Scan your food to discover\nits nutrition and get healthier\nfood choices.',
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF78928B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildProfileButton(),
      ],
    );
  }

  Widget _buildProfileButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F3EF),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E5DF)),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            size: 27,
            color: Color(0xFF183B32),
          ),
        ),
      ),
    );
  }

  Widget _buildScanCard() {
    return Container(
      height: 405,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFAEC1A7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Opacity(
                opacity: 0.42,
                child: Image.network(
                  'https://www.themealdb.com/images/media/meals/1549546037.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFAEC1A7),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x665C765E),
                    const Color(0x665C765E),
                    const Color(0xAA345449),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: const Color(0x55728D72),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.42),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.center_focus_weak_rounded,
                      size: 62,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Scan your food',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Get nutrition insights\nin seconds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () => _openScanner(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17483F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.55),
                            width: 1,
                          ),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Scan Food',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded, size: 21),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 142,
          padding: const EdgeInsets.fromLTRB(17, 17, 14, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFAF6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE6E7E1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 31, color: const Color(0xFF183B32)),
              const Spacer(),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF183B32),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF8A9891),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.history_rounded, 'History'),
      (Icons.favorite_border_rounded, 'Nutrition'),
      (Icons.person_outline_rounded, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F7F2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final selected = index == _selectedNav;
          final item = items[index];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedNav = index);
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.$1,
                    size: 27,
                    color: selected
                        ? const Color(0xFF17483F)
                        : const Color(0xFFB0B8B2),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.$2,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected
                          ? const Color(0xFF17483F)
                          : const Color(0xFFA8B0AB),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

