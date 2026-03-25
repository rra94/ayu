import 'package:objectbox/objectbox.dart';

@Entity()
class PeptideLogOB {
  @Id()
  int id = 0;

  int peptideId;
  double doseUnits;
  double doseMcg;

  /// abdomen_left, abdomen_right, thigh_left, thigh_right,
  /// deltoid_left, deltoid_right, glute_left, glute_right
  String injectionSite;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  String? notes;

  PeptideLogOB({
    this.id = 0,
    required this.peptideId,
    required this.doseUnits,
    required this.doseMcg,
    required this.injectionSite,
    required this.dateTime,
    this.notes,
  });
}
