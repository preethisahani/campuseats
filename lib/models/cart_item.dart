import 'food_item.dart';

class CartItem {
  final FoodItem item;
  int quantity;
  String? specialInstructions;

  CartItem({
    required this.item,
    this.quantity = 1,
    this.specialInstructions,
  });

  double get totalPrice => item.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'itemId': item.id,
      'name': item.name,
      'price': item.price,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'imageUrl': item.imageUrl,
      'isVeg': item.isVeg,
      'specialInstructions': specialInstructions,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      item: FoodItem(
        id: map['itemId'] ?? '',
        name: map['name'] ?? '',
        description: '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        category: '',
        isVeg: map['isVeg'] ?? true,
        imageUrl: map['imageUrl'] ?? '',
      ),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      specialInstructions: map['specialInstructions'],
    );
  }
}
