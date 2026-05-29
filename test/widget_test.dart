import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vital_fitness/main.dart';

void main() {
  testWidgets('VitalFitnessApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VitalFitnessApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}