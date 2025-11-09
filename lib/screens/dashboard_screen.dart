import 'package:flutter/material.dart';
import 'package:flutter_dashboard/helpers/api_helper.dart';
import 'package:flutter_dashboard/helpers/database_helper.dart';
import 'package:flutter_dashboard/models/item.dart';
import 'package:flutter_dashboard/widgets/item_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DashboardScreen extends StatefulWidget {
  final ApiHelper? apiHelper;
  final DatabaseHelper? dbHelper;

  const DashboardScreen({super.key, this.apiHelper, this.dbHelper});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ApiHelper apiHelper;
  late final DatabaseHelper dbHelper;

  List<Item> items = [];
  bool loading = true;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiHelper = widget.apiHelper ?? ApiHelper();
    dbHelper = widget.dbHelper ?? DatabaseHelper();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => loading = true);
    try {
      final fetchedItems = await apiHelper.fetchItems();
      for (var item in fetchedItems) {
        await dbHelper.insertItem(item);
      }
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

  Future<void> addItem() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final newItem = Item(id: DateTime.now().millisecondsSinceEpoch, name: text);
    await dbHelper.insertItem(newItem);
    _controller.clear();
    await loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Column(
        children: [
          // Input row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'New Item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: addItem, child: Text('Add')),
              ],
            ),
          ),
          // Items grid
          Expanded(
            child: loading
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
          ),
        ],
      ),
    );
  }
}
