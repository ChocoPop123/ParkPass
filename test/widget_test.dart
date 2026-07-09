// This is a basic Flutter widget test for ParkPass.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parkpass/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Welcome to ParkPass'), findsOneWidget);
  });
}
