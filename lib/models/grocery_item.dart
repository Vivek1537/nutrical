class GroceryItem {
  final String name;
  final double quantity;
  final String unit;
  bool checked;

  GroceryItem({required this.name, required this.quantity, required this.unit, this.checked = false});

  Map<String, dynamic> toJson() => {'name': name, 'quantity': quantity, 'unit': unit, 'checked': checked};

  factory GroceryItem.fromJson(Map<String, dynamic> j) => GroceryItem(
    name: j['name'], quantity: (j['quantity'] as num).toDouble(),
    unit: j['unit'], checked: j['checked'] ?? false,
  );
}
