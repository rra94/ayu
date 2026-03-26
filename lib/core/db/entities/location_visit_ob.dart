import 'package:objectbox/objectbox.dart';

@Entity()
class LocationVisitOB {
  @Id()
  int id = 0;

  double lat;
  double lon;

  @Property(type: PropertyType.date)
  DateTime arrivalTime;

  @Property(type: PropertyType.date)
  DateTime? departureTime;

  /// gym, home, work, other
  String label;

  /// FK to SavedLocationOB (0 if unmatched)
  int savedLocationId;

  LocationVisitOB({
    this.id = 0,
    required this.lat,
    required this.lon,
    required this.arrivalTime,
    this.departureTime,
    this.label = 'other',
    this.savedLocationId = 0,
  });

  double get durationMinutes => departureTime != null
      ? departureTime!.difference(arrivalTime).inMinutes.toDouble()
      : DateTime.now().difference(arrivalTime).inMinutes.toDouble();
}
