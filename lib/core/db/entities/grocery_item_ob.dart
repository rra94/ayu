import 'package:objectbox/objectbox.dart';

@Entity()
class GroceryItemOB {
  @Id()
  int id = 0;

  String name;
  String? brand;
  String? category; // produce, dairy, meat, pantry, frozen, beverage, snack, other
  double? price;
  String? store;
  String? barcode;

  @Property(type: PropertyType.date)
  DateTime purchaseDate;

  /// Whether this item has been consumed/logged as food
  bool consumed;

  /// Estimated days until expiry (from purchase date)
  int? shelfLifeDays;

  GroceryItemOB({
    this.id = 0,
    required this.name,
    this.brand,
    this.category,
    this.price,
    this.store,
    this.barcode,
    required this.purchaseDate,
    this.consumed = false,
    this.shelfLifeDays,
  });

  bool get isExpiringSoon {
    if (shelfLifeDays == null) return false;
    final expiryDate = purchaseDate.add(Duration(days: shelfLifeDays!));
    return expiryDate.difference(DateTime.now()).inDays <= 2;
  }

  bool get isExpired {
    if (shelfLifeDays == null) return false;
    final expiryDate = purchaseDate.add(Duration(days: shelfLifeDays!));
    return DateTime.now().isAfter(expiryDate);
  }

  /// Auto-classify food category from name
  static String classifyCategory(String name) {
    final lower = name.toLowerCase();
    // Check beverage FIRST (before produce, since "orange juice" is a beverage)
    if (_matchesAny(lower, ['juice', 'soda', 'coffee', 'tea',
        'kombucha', 'sparkling water', 'wine', 'beer', 'drink'])) return 'beverage';
    if (_matchesAny(lower, ['apple', 'banana', 'orange', 'berr', 'grape', 'mango',
        'avocado', 'tomato', 'lettuce', 'spinach', 'kale', 'broccoli', 'carrot',
        'onion', 'potato', 'pepper', 'cucumber', 'celery', 'mushroom',
        'fruit', 'vegetable', 'organic', 'salad'])) return 'produce';
    if (_matchesAny(lower, ['milk', 'yogurt', 'cheese', 'cream', 'butter',
        'egg', 'cottage'])) return 'dairy';
    if (_matchesAny(lower, ['chicken', 'beef', 'pork', 'turkey', 'salmon',
        'fish', 'shrimp', 'steak', 'ground', 'sausage', 'bacon'])) return 'meat';
    if (_matchesAny(lower, ['frozen', 'ice cream', 'pizza'])) return 'frozen';
    if (_matchesAny(lower, ['chip', 'cookie', 'cracker', 'candy', 'chocolate',
        'snack', 'pretzel', 'popcorn', 'bar'])) return 'snack';
    if (_matchesAny(lower, ['rice', 'pasta', 'bread', 'flour', 'oil', 'sauce',
        'can', 'bean', 'lentil', 'oat', 'cereal', 'nut', 'seed',
        'honey', 'sugar', 'salt', 'spice'])) return 'pantry';
    return 'other';
  }

  /// Estimate shelf life in days based on category
  static int estimateShelfLife(String category) {
    switch (category) {
      case 'produce': return 7;
      case 'dairy': return 14;
      case 'meat': return 5;
      case 'frozen': return 90;
      case 'beverage': return 30;
      case 'snack': return 60;
      case 'pantry': return 180;
      default: return 30;
    }
  }

  static bool _matchesAny(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));
}
