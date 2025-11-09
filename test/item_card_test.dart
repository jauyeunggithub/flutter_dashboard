import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dashboard/widgets/item_card.dart';
import 'package:flutter_dashboard/models/item.dart';

void main() {
  testWidgets('ItemCard displays item name', (WidgetTester tester) async {
    final item = Item(id: 1, name: 'Test Item');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ItemCard(item: item)),
      ),
    );

    // Verify item name is displayed
    expect(find.text('Test Item'), findsOneWidget);
    // Verify that a Card widget is present
    expect(find.byType(Card), findsOneWidget);
  });
}
