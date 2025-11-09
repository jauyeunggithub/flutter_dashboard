import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';

class ApiHelper {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Item>> fetchItems() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data
          .map((json) => Item(name: json['title'] ?? 'No Name'))
          .toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}
