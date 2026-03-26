import 'package:objectbox/objectbox.dart';

@Entity()
class EcoScoreOB {
  @Id()
  int id = 0;

  /// Product barcode or unique key (e.g., OFF code, custom name hash)
  String productKey;

  /// Product name for display
  String productName;

  /// a, b, c, d, e
  String grade;

  /// 0-100
  double score;

  /// "off" (from Open Food Facts), "user" (manually entered)
  String source;

  /// OFF data quality: true if ecoscore_data quality tags indicate reliable data
  bool highQuality;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  EcoScoreOB({
    this.id = 0,
    required this.productKey,
    required this.productName,
    required this.grade,
    required this.score,
    this.source = 'off',
    this.highQuality = false,
    required this.updatedAt,
  });
}
