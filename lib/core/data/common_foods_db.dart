import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';

/// Built-in database of common generic foods that aren't in OFF/FDC.
/// Returns MealEntity with typical nutrition per 100g/100ml.
class CommonFoodsDB {
  static List<MealEntity> search(String query) {
    if (query.isEmpty) return [];
    final lower = query.toLowerCase().trim();
    return _foods.where((f) {
      final name = f.name!.toLowerCase();
      return name.contains(lower) || lower.contains(name);
    }).toList();
  }

  static final _foods = [
    // ── Coffee & Tea ──
    _f('Americano', 2, 0, 0.3, 0, coffee: true),
    _f('Espresso', 2, 0, 0.1, 0, coffee: true),
    _f('Black Coffee', 2, 0, 0.3, 0, coffee: true),
    _f('Latte', 67, 3.5, 3.4, 5, coffee: true),
    _f('Cappuccino', 45, 2.3, 2.5, 3.5, coffee: true),
    _f('Flat White', 54, 3, 2.8, 4, coffee: true),
    _f('Mocha', 80, 3.5, 3, 10, coffee: true),
    _f('Iced Coffee', 2, 0, 0.3, 0, coffee: true),
    _f('Cold Brew', 3, 0, 0.3, 0, coffee: true),
    _f('Chai Latte', 75, 2, 2, 12, coffee: true),
    _f('Matcha Latte', 60, 2.5, 3, 7, coffee: true),
    _f('Green Tea', 1, 0, 0.2, 0),
    _f('Black Tea', 1, 0, 0.1, 0),
    _f('Herbal Tea', 1, 0, 0, 0),

    // ── Breakfast ──
    _f('Oatmeal', 68, 1.4, 2.4, 12),
    _f('Scrambled Eggs', 149, 11, 10, 1),
    _f('Fried Egg', 196, 15, 14, 0.6),
    _f('Boiled Egg', 155, 11, 13, 1.1),
    _f('Poached Egg', 143, 10, 12, 0.7),
    _f('Toast with Butter', 313, 14, 7, 42),
    _f('Pancakes', 227, 10, 6, 28),
    _f('French Toast', 229, 10, 8, 26),
    _f('Granola', 471, 20, 10, 61),
    _f('Yogurt Bowl', 59, 0.5, 10, 3.6),
    _f('Avocado Toast', 220, 14, 5, 20),
    _f('Smoothie Bowl', 80, 1, 2, 16),
    _f('Bagel with Cream Cheese', 280, 10, 8, 38),

    // ── Basics ──
    _f('White Rice', 130, 0.3, 2.7, 28),
    _f('Brown Rice', 123, 1, 2.6, 26),
    _f('Pasta', 131, 1.1, 5, 25),
    _f('Bread', 265, 3.2, 9, 49),
    _f('Tortilla', 237, 5, 6, 41),
    _f('Quinoa', 120, 1.9, 4.4, 21),
    _f('Couscous', 112, 0.2, 3.8, 23),

    // ── Proteins ──
    _f('Grilled Chicken Breast', 165, 3.6, 31, 0),
    _f('Chicken Thigh', 209, 11, 26, 0),
    _f('Salmon Fillet', 208, 13, 20, 0),
    _f('Tuna Steak', 144, 5, 23, 0),
    _f('Ground Beef', 250, 17, 26, 0),
    _f('Steak', 271, 19, 26, 0),
    _f('Pork Chop', 231, 13, 27, 0),
    _f('Turkey Breast', 135, 1, 30, 0),
    _f('Shrimp', 99, 0.3, 24, 0.2),
    _f('Tofu', 76, 4.8, 8, 1.9),
    _f('Tempeh', 192, 11, 20, 8),
    _f('Lentils', 116, 0.4, 9, 20),
    _f('Chickpeas', 164, 2.6, 9, 27),
    _f('Black Beans', 132, 0.5, 9, 24),

    // ── Vegetables ──
    _f('Broccoli', 34, 0.4, 2.8, 7),
    _f('Spinach', 23, 0.4, 2.9, 3.6),
    _f('Kale', 49, 0.9, 4.3, 9),
    _f('Sweet Potato', 86, 0.1, 1.6, 20),
    _f('Baked Potato', 93, 0.1, 2.5, 21),
    _f('Mixed Salad', 20, 0.2, 1.5, 3.6),
    _f('Caesar Salad', 127, 8, 6, 8),
    _f('Steamed Vegetables', 35, 0.3, 2, 7),

    // ── Fruits ──
    _f('Banana', 89, 0.3, 1.1, 23),
    _f('Apple', 52, 0.2, 0.3, 14),
    _f('Orange', 47, 0.1, 0.9, 12),
    _f('Berries', 57, 0.3, 0.7, 14),
    _f('Mango', 60, 0.4, 0.8, 15),
    _f('Watermelon', 30, 0.2, 0.6, 8),

    // ── Dairy ──
    _f('Whole Milk', 61, 3.3, 3.2, 4.8),
    _f('Skim Milk', 34, 0.1, 3.4, 5),
    _f('Almond Milk', 17, 1.1, 0.6, 0.8),
    _f('Oat Milk', 43, 1.5, 1, 7),
    _f('Greek Yogurt', 97, 5, 9, 3.6),
    _f('Cottage Cheese', 98, 4.3, 11, 3.4),
    _f('Cheese', 402, 33, 25, 1.3),
    _f('Butter', 717, 81, 0.9, 0.1),

    // ── Snacks ──
    _f('Almonds', 579, 50, 21, 22),
    _f('Peanut Butter', 588, 50, 25, 20),
    _f('Trail Mix', 462, 29, 13, 45),
    _f('Dark Chocolate', 546, 31, 5, 60),
    _f('Hummus', 166, 10, 8, 14),
    _f('Protein Bar', 350, 12, 20, 40),
    _f('Rice Cake', 387, 2.8, 8, 81),
    _f('Popcorn', 387, 4.5, 13, 78),

    // ── Common Meals ──
    _f('Burger', 295, 14, 17, 24),
    _f('Cheeseburger', 303, 15, 17, 25),
    _f('Pizza Slice', 266, 10, 11, 33),
    _f('Burrito', 206, 8, 9, 25),
    _f('Taco', 210, 10, 9, 21),
    _f('Sandwich', 250, 10, 12, 28),
    _f('Wrap', 200, 8, 10, 24),
    _f('Sushi Roll', 140, 2, 5, 26),
    _f('Fried Rice', 163, 5, 4, 25),
    _f('Pad Thai', 155, 5, 6, 22),
    _f('Ramen', 106, 5, 4, 13),
    _f('Curry with Rice', 142, 5, 5, 20),
    _f('Fish and Chips', 230, 12, 13, 18),
    _f('Grilled Cheese', 366, 21, 14, 29),
    _f('Chicken Soup', 36, 1, 3, 3),
    _f('Tomato Soup', 30, 0.4, 1, 6),
    _f('French Fries', 312, 15, 3.4, 41),
    _f('Onion Rings', 332, 18, 4, 39),
    _f('Mac and Cheese', 164, 8, 6, 17),
    _f('Mashed Potatoes', 83, 3, 1.5, 13),

    // ── Drinks ──
    _f('Orange Juice', 45, 0.2, 0.7, 10),
    _f('Apple Juice', 46, 0.1, 0.1, 11),
    _f('Coca Cola', 42, 0, 0, 11),
    _f('Sparkling Water', 0, 0, 0, 0),
    _f('Kombucha', 17, 0, 0.5, 3),
    _f('Protein Shake', 80, 1.5, 15, 3),
    _f('Milkshake', 112, 3, 3.5, 18),
    _f('Smoothie', 50, 0.3, 0.8, 12),
    _f('Coconut Water', 19, 0.2, 0.7, 3.7),
    _f('Beer', 43, 0, 0.5, 3.6),
    _f('Red Wine', 85, 0, 0.1, 2.6),
    _f('White Wine', 82, 0, 0.1, 2.6),
  ];

  static MealEntity _f(String name, double kcal, double fat, double protein,
      double carbs, {bool coffee = false}) {
    return MealEntity(
      code: null,
      name: name,
      url: null,
      mealQuantity: coffee ? '240' : '100',
      mealUnit: coffee ? 'ml' : 'g',
      servingQuantity: coffee ? 240 : null,
      servingUnit: coffee ? 'ml' : null,
      servingSize: coffee ? '1 cup (240ml)' : null,
      source: MealSourceEntity.custom,
      nutriments: MealNutrimentsEntity(
        energyKcal100: kcal,
        carbohydrates100: carbs,
        fat100: fat,
        proteins100: protein,
        sugars100: null,
        saturatedFat100: null,
        fiber100: null,
        sodium100: null,
      ),
    );
  }
}
