import 'package:objectbox/objectbox.dart';

@Entity()
class CaffeineLogOB {
  @Id()
  int id = 0;

  /// Caffeine amount in mg
  double amountMg;

  /// Source: coffee, tea, energy_drink, soda, supplement, other
  String source;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  CaffeineLogOB({
    this.id = 0,
    required this.amountMg,
    required this.source,
    required this.dateTime,
  });

  /// Common caffeine amounts
  static const presets = {
    'Coffee (8oz)': 95.0,
    'Espresso (1 shot)': 63.0,
    'Black tea': 47.0,
    'Green tea': 28.0,
    'Energy drink': 160.0,
    'Cola (12oz)': 34.0,
    'Pre-workout': 200.0,
    'Dark chocolate (1oz)': 12.0,
  };
}
