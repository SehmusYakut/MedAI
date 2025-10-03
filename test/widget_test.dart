import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:medway/main.dart';
import 'package:medway/viewmodels/medicine_program_view_model.dart';
import 'package:medway/viewmodels/ocr_view_model.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MedicineProgramViewModel()),
          ChangeNotifierProvider(create: (_) => OCRViewModel()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app loads without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
