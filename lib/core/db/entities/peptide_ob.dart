import 'package:objectbox/objectbox.dart';

@Entity()
class PeptideOB {
  @Id()
  int id = 0;

  String name;
  String? brand;

  /// Reconstitution: total mg in vial
  double peptideMg;

  /// ml of BAC water added
  double bacWaterMl;

  /// units per injection on insulin syringe
  double doseUnits;

  /// daily, eod, mon_wed_fri, 5on2off, weekly
  String frequency;
  int cycleDays;
  int restDays;

  @Property(type: PropertyType.date)
  DateTime startDate;

  @Property(type: PropertyType.date)
  DateTime? endDate;

  bool isActive;

  /// subq, im
  String route;

  String? notes;

  PeptideOB({
    this.id = 0,
    required this.name,
    this.brand,
    required this.peptideMg,
    required this.bacWaterMl,
    required this.doseUnits,
    this.frequency = 'daily',
    this.cycleDays = 60,
    this.restDays = 30,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.route = 'subq',
    this.notes,
  });

  double get mcgPerUnit => (peptideMg * 1000) / (bacWaterMl * 100);
  double get doseMcg => mcgPerUnit * doseUnits;

  int get cycleDayNumber {
    final elapsed = DateTime.now().difference(startDate).inDays;
    final totalCycle = cycleDays + restDays;
    return totalCycle > 0 ? (elapsed % totalCycle) + 1 : 1;
  }

  bool get isInActiveCyclePhase => cycleDayNumber <= cycleDays;

  bool get isDoseDay {
    if (!isInActiveCyclePhase) return false;
    final dow = DateTime.now().weekday;
    switch (frequency) {
      case 'daily':
        return true;
      case 'eod':
        return DateTime.now().difference(startDate).inDays.isEven;
      case 'mon_wed_fri':
        return dow == 1 || dow == 3 || dow == 5;
      case '5on2off':
        final dayInWeek = cycleDayNumber % 7;
        return dayInWeek >= 1 && dayInWeek <= 5;
      case 'weekly':
        return dow == startDate.weekday;
      default:
        return true;
    }
  }

  int get dosesPerVial {
    final doseMl = doseUnits / 100;
    return doseMl > 0 ? (bacWaterMl / doseMl).floor() : 0;
  }
}
