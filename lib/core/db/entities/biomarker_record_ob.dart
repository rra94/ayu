import 'package:objectbox/objectbox.dart';

@Entity()
class BiomarkerRecordOB {
  @Id()
  int id = 0;

  /// Biomarker type key (e.g. "fasting_glucose", "hba1c", "crp")
  String type;

  double value;

  /// Unit (e.g. "mg/dL", "mmol/L", "%")
  String unit;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  /// 0=manual, 1=auto_computed
  int source;

  /// Optional notes (e.g. glucose timing: "Fasting", "1h after meal")
  String? notes;

  BiomarkerRecordOB({
    this.id = 0,
    required this.type,
    required this.value,
    required this.unit,
    required this.dateTime,
    this.source = 0,
    this.notes,
  });
}
