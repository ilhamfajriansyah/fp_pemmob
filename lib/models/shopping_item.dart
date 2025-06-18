class ShoppingItem {
  int? id;
  String name;
  int quantity;
  double price;
  DateTime createdAt;

  ShoppingItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.createdAt,
  });

  double get totalPrice => quantity * price;

  // Convert ShoppingItem to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create ShoppingItem from Map
  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      quantity: map['quantity']?.toInt() ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  ShoppingItem copyWith({
    int? id,
    String? name,
    int? quantity,
    double? price,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ShoppingItem{id: $id, name: $name, quantity: $quantity, price: $price, createdAt: $createdAt}';
  }
}