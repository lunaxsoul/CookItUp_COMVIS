import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';

/// One saved scan. Nutrition is an ESTIMATE per typical serving.
class ScanEntry {
  final String id;
  final String label; // classifier label, e.g. "nasi_goreng"
  final String mealName; // matched recipe name, or label if no match
  final double confidence; // 0..1
  final DateTime scannedAt;
  final Nutrition? nutrition; // null if no recipe matched

  const ScanEntry({
    required this.id,
    required this.label,
    required this.mealName,
    required this.confidence,
    required this.scannedAt,
    this.nutrition,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'mealName': mealName,
        'confidence': confidence,
        'scannedAt': scannedAt.toIso8601String(),
        'nutrition': nutrition?.toJson(),
      };

  factory ScanEntry.fromJson(Map<String, dynamic> j) {
    Nutrition? n;
    final raw = j['nutrition'];
    if (raw is Map) {
      double d(String k) => (raw[k] as num?)?.toDouble() ?? 0;
      n = Nutrition(
        kcal: (raw['kcal'] as num?)?.toInt() ?? 0,
        protein: d('protein'),
        carbs: d('carbs'),
        fat: d('fat'),
        fiber: d('fiber'),
        sugar: d('sugar'),
        sodium: d('sodium'),
        cholesterol: d('cholesterol'),
        serving: raw['serving']?.toString() ?? '1 porsi',
      );
    }
    return ScanEntry(
      id: j['id']?.toString() ?? '',
      label: j['label']?.toString() ?? '',
      mealName: j['mealName']?.toString() ?? '',
      confidence: (j['confidence'] as num?)?.toDouble() ?? 0,
      scannedAt: DateTime.tryParse(j['scannedAt']?.toString() ?? '') ??
          DateTime.now(),
      nutrition: n,
    );
  }
}

/// Sum of nutrition for one day.
class DailyTotals {
  final int scans;
  final int kcal;
  final double protein, carbs, fat, fiber, sugar, sodium, cholesterol;

  const DailyTotals({
    this.scans = 0,
    this.kcal = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    this.cholesterol = 0,
  });
}

/// Daily goals (editable from the Profile > My Nutrition Goals screen).
class NutritionGoals {
  final int kcal;
  final double protein, carbs, fat, fiber, sugar, sodium, cholesterol;

  const NutritionGoals({
    this.kcal = 2000,
    this.protein = 60,
    this.carbs = 250,
    this.fat = 65,
    this.fiber = 25,
    this.sugar = 50,
    this.sodium = 2300,
    this.cholesterol = 300,
  });

  Map<String, dynamic> toJson() => {
        'kcal': kcal, 'protein': protein, 'carbs': carbs, 'fat': fat,
        'fiber': fiber, 'sugar': sugar, 'sodium': sodium,
        'cholesterol': cholesterol,
      };

  factory NutritionGoals.fromJson(Map<String, dynamic> j) {
    const d = NutritionGoals();
    double v(String k, double def) => (j[k] as num?)?.toDouble() ?? def;
    return NutritionGoals(
      kcal: (j['kcal'] as num?)?.toInt() ?? d.kcal,
      protein: v('protein', d.protein),
      carbs: v('carbs', d.carbs),
      fat: v('fat', d.fat),
      fiber: v('fiber', d.fiber),
      sugar: v('sugar', d.sugar),
      sodium: v('sodium', d.sodium),
      cholesterol: v('cholesterol', d.cholesterol),
    );
  }
}

/// Local storage for scans, daily totals, streak and goals.
class ScanHistoryService {
  static const _scansKey = 'scan_history_v1';
  static const _goalsKey = 'nutrition_goals_v1';

  /// Save a scan. Pass the matched [meal] (or null if no recipe matched).
  Future<void> addScan({
    required String label,
    required double confidence,
    Meal? meal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    final now = DateTime.now();
    all.add(ScanEntry(
      id: now.microsecondsSinceEpoch.toString(),
      label: label,
      mealName: meal?.name ?? label,
      confidence: confidence,
      scannedAt: now,
      nutrition: meal?.nutrition,
    ));
    await prefs.setString(
      _scansKey,
      jsonEncode(all.map((e) => e.toJson()).toList()),
    );
  }

  /// All scans, newest first.
  Future<List<ScanEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scansKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => ScanEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      list.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteScan(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.removeWhere((e) => e.id == id);
    await prefs.setString(
      _scansKey,
      jsonEncode(all.map((e) => e.toJson()).toList()),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<List<ScanEntry>> entriesForDay(DateTime day) async {
    final all = await getAll();
    return all.where((e) => _sameDay(e.scannedAt, day)).toList();
  }

  /// Totals for one day (defaults to today). Scans without nutrition are
  /// counted in [scans] but add nothing to the sums.
  Future<DailyTotals> totalsForDay([DateTime? day]) async {
    final entries = await entriesForDay(day ?? DateTime.now());
    int kcal = 0;
    double p = 0, c = 0, f = 0, fi = 0, su = 0, so = 0, ch = 0;
    for (final e in entries) {
      final n = e.nutrition;
      if (n == null) continue;
      kcal += n.kcal;
      p += n.protein;
      c += n.carbs;
      f += n.fat;
      fi += n.fiber;
      su += n.sugar;
      so += n.sodium;
      ch += n.cholesterol;
    }
    return DailyTotals(
      scans: entries.length,
      kcal: kcal,
      protein: p,
      carbs: c,
      fat: f,
      fiber: fi,
      sugar: su,
      sodium: so,
      cholesterol: ch,
    );
  }

  Future<int> totalScans() async => (await getAll()).length;

  /// Consecutive days with at least one scan. Counts back from today, or from
  /// yesterday if nothing has been scanned yet today.
  Future<int> currentStreak() async {
    final all = await getAll();
    if (all.isEmpty) return 0;
    final days = all
        .map((e) => DateTime(e.scannedAt.year, e.scannedAt.month, e.scannedAt.day))
        .toSet();
    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return streak;
  }

  Future<NutritionGoals> getGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_goalsKey);
    if (raw == null) return const NutritionGoals();
    try {
      return NutritionGoals.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return const NutritionGoals();
    }
  }

  Future<void> saveGoals(NutritionGoals goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalsKey, jsonEncode(goals.toJson()));
  }
}
