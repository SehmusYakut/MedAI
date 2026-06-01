import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medway/main.dart';
import 'package:medway/services/theme_and_locale_service.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Mock initial SharedPreferences values
    SharedPreferences.setMockInitialValues({});

    final prefs = await SharedPreferences.getInstance();
    final settingsService = ThemeAndLocaleService(prefs);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(
        prefs: prefs,
        settingsService: settingsService,
      ),
    );

    // Verify that the app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
