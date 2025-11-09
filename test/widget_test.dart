import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dashboard/main.dart';
import 'package:flutter_dashboard/screens/dashboard_screen.dart';

void main() {
  testWidgets('App builds and shows DashboardScreen', (
    WidgetTester tester,
  ) async {
    // Build the app
    await tester.pumpWidget(MyApp());

    // Check for AppBar title
    expect(find.text('Dashboard'), findsOneWidget);

    // DashboardScreen should be present
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('Shows loading indicator initially', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // CircularProgressIndicator should appear while loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Displays items after load', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Let async operations complete
    await tester.pumpAndSettle();

    // There should be at least one item card
    expect(find.byType(Card), findsWidgets);
  });
}
