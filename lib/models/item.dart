class Item {
  final int? id;
  final String name;

  Item({this.id, required this.name});

  factory Item.fromMap(Map<String, dynamic> json) =>
      Item(id: json['id'], name: json['name']);

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
}
