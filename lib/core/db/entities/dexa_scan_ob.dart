import 'package:objectbox/objectbox.dart';

@Entity()
class DexaScanOB {
  @Id()
  int id = 0;

  @Property(type: PropertyType.date)
  DateTime scanDate;

  double? totalBodyFatPercent;
  double? leanMassKG;
  double? fatMassKG;
  double? boneMineralDensity;
  double? visceralFatArea;
  double? tScore;

  DexaScanOB({
    this.id = 0,
    required this.scanDate,
    this.totalBodyFatPercent,
    this.leanMassKG,
    this.fatMassKG,
    this.boneMineralDensity,
    this.visceralFatArea,
    this.tScore,
  });
}
