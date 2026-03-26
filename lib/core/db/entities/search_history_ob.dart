import 'package:objectbox/objectbox.dart';

/// Records which search result the user chose for a given query.
/// Used to learn preferences and surface top picks on repeat searches.
@Entity()
class SearchHistoryOB {
  @Id()
  int id = 0;

  /// The search term the user typed (lowercased)
  String searchTerm;

  /// The meal name they selected
  String chosenMealName;

  /// Product code (barcode) if available, for exact matching
  String? chosenMealCode;

  /// How many times this term → meal mapping was chosen
  int count;

  @Property(type: PropertyType.date)
  DateTime lastUsed;

  SearchHistoryOB({
    this.id = 0,
    required this.searchTerm,
    required this.chosenMealName,
    this.chosenMealCode,
    this.count = 1,
    required this.lastUsed,
  });
}
