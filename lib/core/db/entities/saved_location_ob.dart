import 'package:objectbox/objectbox.dart';

@Entity()
class SavedLocationOB {
  @Id()
  int id = 0;

  double lat;
  double lon;
  double radiusMeters;

  /// User-confirmed label: gym, office, home, etc.
  String label;

  int visitCount;

  SavedLocationOB({
    this.id = 0,
    required this.lat,
    required this.lon,
    this.radiusMeters = 100,
    required this.label,
    this.visitCount = 0,
  });
}
