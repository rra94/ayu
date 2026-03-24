import 'package:objectbox/objectbox.dart';

@Entity()
class ProductInventoryOB {
  @Id()
  int id = 0;

  String name;
  String? brand;
  String category; // supplement, skincare, dental, other

  /// Total uses in a full bottle/package (e.g., 60 capsules, 30 washes)
  int totalUses;

  /// Uses remaining
  int usesRemaining;

  @Property(type: PropertyType.date)
  DateTime startedDate;

  /// Barcode if scanned
  String? barcode;

  ProductInventoryOB({
    this.id = 0,
    required this.name,
    this.brand,
    this.category = 'other',
    required this.totalUses,
    required this.usesRemaining,
    required this.startedDate,
    this.barcode,
  });

  double get percentRemaining =>
      totalUses > 0 ? usesRemaining / totalUses : 0;

  bool get isLow => percentRemaining <= 0.2;
  bool get isEmpty => usesRemaining <= 0;

  /// Estimated days until empty based on usage rate
  int? get estimatedDaysLeft {
    final daysUsed = DateTime.now().difference(startedDate).inDays;
    if (daysUsed <= 0) return null;
    final usedSoFar = totalUses - usesRemaining;
    if (usedSoFar <= 0) return null;
    final dailyRate = usedSoFar / daysUsed;
    if (dailyRate <= 0) return null;
    return (usesRemaining / dailyRate).round();
  }
}
