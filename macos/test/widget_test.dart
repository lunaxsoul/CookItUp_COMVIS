import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_classifier_app/main.dart';

void main() {
  testWidgets('App shows loading indicator while model is loading', (WidgetTester tester) async {
    await tester.pumpWidget(const FoodClassifierApp());

    // Sebelum model TFLite selesai dimuat, aplikasi menampilkan loading spinner.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
