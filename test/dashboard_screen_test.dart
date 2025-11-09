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
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final fetchedItems = await widget.apiHelper.fetchItems();

      // Insert only items that are not already in dbItems
      final existingItems = await widget.dbHelper.getItems();
      for (var item in fetchedItems) {
        if (!existingItems.any((e) => e.id == item.id)) {
          await widget.dbHelper.insertItem(item);
        }
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

  Future<void> addItem() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final newItem = Item(id: DateTime.now().millisecondsSinceEpoch, name: text);
    await widget.dbHelper.insertItem(newItem);
    _controller.clear();
    await loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard (Test)')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('itemInput'),
                          controller: _controller,
                          decoration: const InputDecoration(
                            labelText: 'New Item',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        key: const Key('addButton'),
                        onPressed: addItem,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: items
                        .map((item) => Card(child: Text(item.name)))
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(Item(id: 0, name: 'fallback'));
  });

  testWidgets('Displays items after load and allows adding new item', (
    WidgetTester tester,
  ) async {
    final mockApiHelper = MockApiHelper();
    final mockDbHelper = MockDatabaseHelper();

    // Simulate a local database storage
    final List<Item> dbItems = [];

    // API returns two initial items
    when(() => mockApiHelper.fetchItems()).thenAnswer(
      (_) async => [Item(id: 1, name: 'Item 1'), Item(id: 2, name: 'Item 2')],
    );

    // DB insert mock adds items to local list
    when(() => mockDbHelper.insertItem(any())).thenAnswer((invocation) async {
      final item = invocation.positionalArguments[0] as Item;
      dbItems.add(item);
      return 1;
    });

    // DB getItems mock returns a fresh copy of the local list
    when(
      () => mockDbHelper.getItems(),
    ).thenAnswer((_) async => List.from(dbItems));

    await tester.pumpWidget(
      MaterialApp(
        home: TestDashboardScreen(
          apiHelper: mockApiHelper,
          dbHelper: mockDbHelper,
        ),
      ),
    );

    // Wait for initial load
    await tester.pumpAndSettle();

    // Verify API items are loaded
    expect(find.text('Item 1'), findsOneWidget);
    expect(find.text('Item 2'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));

    // Add a new item via input
    await tester.enterText(find.byKey(const Key('itemInput')), 'Item 3');
    await tester.tap(find.byKey(const Key('addButton')));
    await tester.pumpAndSettle();

    // Verify the new item appears
    expect(find.text('Item 3'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(3));
  });
}
