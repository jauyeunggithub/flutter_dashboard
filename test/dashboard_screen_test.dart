import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dashboard/models/item.dart';
import 'package:flutter_dashboard/helpers/api_helper.dart';
import 'package:flutter_dashboard/helpers/database_helper.dart';
import 'package:mocktail/mocktail.dart';

class MockApiHelper extends Mock implements ApiHelper {}

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class TestDashboardScreen extends StatefulWidget {
  final MockApiHelper apiHelper;
  final MockDatabaseHelper dbHelper;

  const TestDashboardScreen({
    super.key,
    required this.apiHelper,
    required this.dbHelper,
  });

  @override
  State<TestDashboardScreen> createState() => _TestDashboardScreenState();
}

class _TestDashboardScreenState extends State<TestDashboardScreen> {
  List<Item> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final fetchedItems = await widget.apiHelper.fetchItems();
      for (var item in fetchedItems) {
        await widget.dbHelper.insertItem(item);
      }
      final dbItems = await widget.dbHelper.getItems();
      setState(() {
        items = dbItems;
        loading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard (Test)')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: items
                    .map((item) => Card(child: Text(item.name)))
                    .toList(),
              ),
            ),
    );
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(Item(id: 0, name: 'fallback'));
  });

  testWidgets('Displays items after load', (WidgetTester tester) async {
    final mockApiHelper = MockApiHelper();
    final mockDbHelper = MockDatabaseHelper();

    when(() => mockApiHelper.fetchItems()).thenAnswer(
      (_) async => [Item(id: 1, name: 'Item 1'), Item(id: 2, name: 'Item 2')],
    );

    when(() => mockDbHelper.insertItem(any())).thenAnswer((_) async => 1);
    when(() => mockDbHelper.getItems()).thenAnswer(
      (_) async => [Item(id: 1, name: 'Item 1'), Item(id: 2, name: 'Item 2')],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: TestDashboardScreen(
          apiHelper: mockApiHelper,
          dbHelper: mockDbHelper,
        ),
      ),
    );

    // Loading indicator shows first
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    // ItemCards appear
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);

    // Loading disappears
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
