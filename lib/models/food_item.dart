class FoodItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isVeg;
  final String imageUrl;
  final int prepTimeMinutes;
  final int calories;
  final bool isPopular;

  FoodItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isVeg,
    required this.imageUrl,
    this.prepTimeMinutes = 8,
    this.calories = 300,
    this.isPopular = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'isVeg': isVeg,
      'imageUrl': imageUrl,
      'prepTimeMinutes': prepTimeMinutes,
      'calories': calories,
      'isPopular': isPopular,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    return FoodItem(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? 'General',
      isVeg: map['isVeg'] ?? true,
      imageUrl: map['imageUrl'] ?? '',
      prepTimeMinutes: map['prepTimeMinutes'] ?? 8,
      calories: map['calories'] ?? 300,
      isPopular: map['isPopular'] ?? false,
    );
  }
}
