import 'package:objectbox/objectbox.dart';

@Entity()
class GutHealthItemOB {
  @Id()
  int id = 0;

  String name;
  String category; // high_sugar, low_fiber, artificial_sweeteners, alcohol, etc.

  @Property(type: PropertyType.date)
  DateTime dateTime;

  bool isAutoFlagged;
  String? sourceIntakeId;

  GutHealthItemOB({
    this.id = 0,
    required this.name,
    required this.category,
    required this.dateTime,
    this.isAutoFlagged = false,
    this.sourceIntakeId,
  });
}
