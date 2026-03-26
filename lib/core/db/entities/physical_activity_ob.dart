import 'package:objectbox/objectbox.dart';

@Entity()
class PhysicalActivityOB {
  @Id()
  int id = 0;

  String code;
  String specificActivity;
  String description;
  double mets;
  List<String> tags;

  /// 0=bicycling, 1=conditioning, 2=dancing, 3=running, 4=sport, 5=water, 6=winter
  int activityType;

  PhysicalActivityOB({
    this.id = 0,
    required this.code,
    required this.specificActivity,
    this.description = '',
    required this.mets,
    this.tags = const [],
    required this.activityType,
  });
}
