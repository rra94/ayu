import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/db/entities/grocery_item_ob.dart';

void main() {
  group('GroceryItemOB', () {
    test('classifyCategory detects produce', () {
      expect(GroceryItemOB.classifyCategory('Organic Bananas'), 'produce');
      expect(GroceryItemOB.classifyCategory('Baby Spinach'), 'produce');
      expect(GroceryItemOB.classifyCategory('Avocado'), 'produce');
    });

    test('classifyCategory detects dairy', () {
      expect(GroceryItemOB.classifyCategory('Whole Milk'), 'dairy');
      expect(GroceryItemOB.classifyCategory('Greek Yogurt'), 'dairy');
      expect(GroceryItemOB.classifyCategory('Cheddar Cheese'), 'dairy');
    });

    test('classifyCategory detects meat', () {
      expect(GroceryItemOB.classifyCategory('Chicken Breast'), 'meat');
      expect(GroceryItemOB.classifyCategory('Ground Beef'), 'meat');
      expect(GroceryItemOB.classifyCategory('Atlantic Salmon'), 'meat');
    });

    test('classifyCategory detects pantry', () {
      expect(GroceryItemOB.classifyCategory('Basmati Rice'), 'pantry');
      expect(GroceryItemOB.classifyCategory('Olive Oil'), 'pantry');
      expect(GroceryItemOB.classifyCategory('Rolled Oats'), 'pantry');
    });

    test('classifyCategory detects beverages', () {
      expect(GroceryItemOB.classifyCategory('Orange Juice'), 'beverage');
      expect(GroceryItemOB.classifyCategory('Green Tea'), 'beverage');
      expect(GroceryItemOB.classifyCategory('Sparkling Water 12pk'), 'beverage');
    });

    test('classifyCategory returns other for unknown', () {
      expect(GroceryItemOB.classifyCategory('Random Item XYZ'), 'other');
    });

    test('estimateShelfLife returns correct days', () {
      expect(GroceryItemOB.estimateShelfLife('produce'), 7);
      expect(GroceryItemOB.estimateShelfLife('dairy'), 14);
      expect(GroceryItemOB.estimateShelfLife('meat'), 5);
      expect(GroceryItemOB.estimateShelfLife('frozen'), 90);
      expect(GroceryItemOB.estimateShelfLife('pantry'), 180);
    });

    test('isExpiringSoon works correctly', () {
      final item = GroceryItemOB(
        name: 'Milk',
        purchaseDate: DateTime.now().subtract(const Duration(days: 12)),
        shelfLifeDays: 14,
      );
      expect(item.isExpiringSoon, isTrue); // 2 days left
      expect(item.isExpired, isFalse);
    });

    test('isExpired works correctly', () {
      final item = GroceryItemOB(
        name: 'Old Milk',
        purchaseDate: DateTime.now().subtract(const Duration(days: 20)),
        shelfLifeDays: 14,
      );
      expect(item.isExpired, isTrue);
    });
  });
}
