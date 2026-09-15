import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'services/classifier_service.dart';

// ---------------------------------------------------------------------
// color: deep green, ivory, sage, green
// ---------------------------------------------------------------------
const _forestGreen = Color(0xFF1B4332);
const _mutedGreen = Color(0xFF6B8F71);
const _softSage = Color(0xFFCFDCC6);
const _ivory = Color(0xFFFBF7F1);
const _peachDeep = Color(0xFFE8A876);
const _errorMuted = Color(0xFFB5654B);

void main() {
  runApp(const FoodClassifierApp());
}

class FoodClassifierApp extends StatelessWidget {
  const FoodClassifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _forestGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: _forestGreen,
      secondary: _mutedGreen,
      tertiary: _peachDeep,
      surface: Colors.white,
      error: _errorMuted,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme();

    return MaterialApp(
      title: 'Food Classifier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: _ivory,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: _ivory,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          foregroundColor: _forestGreen,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: _forestGreen,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: _softSage.withValues(alpha: 0.6)),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: _softSage.withValues(alpha: 0.45),
          labelStyle: const TextStyle(color: _forestGreen, fontWeight: FontWeight.w600),
          side: BorderSide.none,
          shape: const StadiumBorder(),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _forestGreen,
            side: const BorderSide(color: _softSage, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: const StadiumBorder(),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _forestGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: _mutedGreen,
        ),
      ),
      home: const _AppLoader(),
    );
  }
}

class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  final _classifier = ClassifierService();
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _classifier.loadModel();
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load ML model: ${snapshot.error}'),
              ),
            ),
          );
        }
        return HomeScreen(classifier: _classifier);
      },
    );
  }
}
