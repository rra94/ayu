import 'package:objectbox/objectbox.dart';

@Entity()
class SupplementOB {
  @Id()
  int id = 0;

  String name;
  String dosage; // e.g. "5000"
  String unit; // mg, mcg, IU, g, drops
  String category; // vitamin, mineral, amino_acid, herbal, probiotic, other
  bool isActive;
  int sortOrder;
  String? sourceBarcode;

  SupplementOB({
    this.id = 0,
    required this.name,
    required this.dosage,
    required this.unit,
    this.category = 'other',
    this.isActive = true,
    this.sortOrder = 0,
    this.sourceBarcode,
  });
}

@Entity()
class SupplementLogOB {
  @Id()
  int id = 0;

  int supplementId;
  bool taken;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  SupplementLogOB({
    this.id = 0,
    required this.supplementId,
    required this.taken,
    required this.dateTime,
  });
}
