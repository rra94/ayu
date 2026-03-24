import 'package:objectbox/objectbox.dart';

@Entity()
class SymptomLogOB {
  @Id()
  int id = 0;

  /// Symptom type index: 0=brain_fog, 1=bloating, 2=gas, 3=energy_crash,
  /// 4=headache, 5=heartburn, 6=skin_breakout, 7=joint_pain,
  /// 8=mood_low, 9=anxiety, 10=insomnia
  int symptom;

  /// Severity 1-5
  int severity;

  @Property(type: PropertyType.date)
  DateTime dateTime;

  String? notes;

  SymptomLogOB({
    this.id = 0,
    required this.symptom,
    required this.severity,
    required this.dateTime,
    this.notes,
  });

  static const symptomNames = [
    'Brain fog',
    'Bloating',
    'Gas',
    'Energy crash',
    'Headache',
    'Heartburn',
    'Skin breakout',
    'Joint pain',
    'Low mood',
    'Anxiety',
    'Insomnia',
  ];

  static const symptomIcons = [
    '🧠', '🫄', '💨', '⚡', '🤕', '🔥', '😣', '🦴', '😞', '😰', '😵‍💫',
  ];

  String get symptomName =>
      symptom >= 0 && symptom < symptomNames.length
          ? symptomNames[symptom]
          : 'Unknown';

  String get symptomIcon =>
      symptom >= 0 && symptom < symptomIcons.length
          ? symptomIcons[symptom]
          : '?';
}
