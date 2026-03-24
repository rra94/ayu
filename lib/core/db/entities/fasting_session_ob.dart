import 'package:objectbox/objectbox.dart';

@Entity()
class FastingSessionOB {
  @Id()
  int id = 0;

  @Property(type: PropertyType.date)
  DateTime startTime;

  @Property(type: PropertyType.date)
  DateTime? endTime;

  double targetHours;

  /// 0=sixteen_eight, 1=eighteen_six, 2=twenty_four, 3=omad, 4=custom
  int type;

  FastingSessionOB({
    this.id = 0,
    required this.startTime,
    this.endTime,
    required this.targetHours,
    this.type = 0,
  });

  bool get isActive => endTime == null;

  double get elapsedHours {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inMinutes / 60.0;
  }

  double get progress => (elapsedHours / targetHours).clamp(0.0, 1.0);

  static const protocolNames = ['16:8', '18:6', '20:4', 'OMAD', 'Custom'];
  static const protocolHours = [16.0, 18.0, 20.0, 23.0, 0.0];

  String get protocolName =>
      type >= 0 && type < protocolNames.length ? protocolNames[type] : 'Custom';
}
