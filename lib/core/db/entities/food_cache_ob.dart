import 'package:objectbox/objectbox.dart';

/// Caches food nutrition results from API calls (CalorieNinjas, OFF, FDC)
/// and user receipt preferences.
/// Avoids repeat network calls for the same query.
@Entity()
class FoodCacheOB {
  @Id()
  int id = 0;

  /// The search query (lowercased, trimmed)
  String query;

  /// Source: "calorie_ninja", "off", "fdc"
  String source;

  /// JSON-encoded list of food results
  String resultsJson;

  /// Number of results cached
  int resultCount;

  @Property(type: PropertyType.date)
  DateTime cachedAt;

  /// How many times this cache entry was hit
  int hitCount;

  FoodCacheOB({
    this.id = 0,
    required this.query,
    required this.source,
    required this.resultsJson,
    required this.resultCount,
    required this.cachedAt,
    this.hitCount = 0,
  });
}
