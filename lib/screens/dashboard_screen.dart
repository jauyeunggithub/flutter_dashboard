import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../helpers/api_helper.dart';
import '../helpers/database_helper.dart';
import '../models/item.dart';
import '../widgets/item_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final dbHelper = DatabaseHelper();
  final apiHelper = ApiHelper();

  List<Item> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      // Fetch from API
      final fetchedItems = await apiHelper.fetchItems();

      // Save to DB
      for (var item in fetchedItems) {
        await dbHelper.insertItem(item);
      }

      // Load from DB
      final dbItems = await dbHelper.getItems();

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
      appBar: AppBar(title: Text('Dashboard')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ItemCard(item: items[index]);
                },
              ),
            ),
    );
  }
}
