import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_dashboard/screens/dashboard_screen.dart';
import 'package:flutter_dashboard/models/item.dart';
import 'package:flutter_dashboard/helpers/api_helper.dart';
import 'package:flutter_dashboard/helpers/database_helper.dart';
import 'package:flutter_dashboard/widgets/item_card.dart';

// Mock classes using mocktail
class MockApiHelper extends Mock implements ApiHelper {}

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

void main() {
  late MockApiHelper mockApiHelper;
  late MockDatabaseHelper mockDbHelper;

  setUp(() {
    mockApiHelper = MockApiHelper();
    mockDbHelper = MockDatabaseHelper();

    // Mock API fetchItems
    when(() => mockApiHelper.fetchItems()).thenAnswer(
      (_) async => [Item(id: 1, name: 'Item 1'), Item(id: 2, name: 'Item 2')],
    );

    // Mock DB insertItem
    when(() => mockDbHelper.insertItem(any())).thenAnswer((_) async => 1);

    // Mock DB getItems
    when(() => mockDbHelper.getItems()).thenAnswer(
      (_) async => [Item(id: 1, name: 'Item 1'), Item(id: 2, name: 'Item 2')],
    );
  });

  testWidgets('DashboardScreen shows loading and then items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(apiHelper: mockApiHelper, dbHelper: mockDbHelper),
      ),
    );

    // Loading indicator should appear first
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for all async tasks to complete
    await tester.pumpAndSettle();

    // Items should be displayed
    expect(find.byType(ItemCard), findsNWidgets(2));
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);

    // Loading indicator should disappear
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
