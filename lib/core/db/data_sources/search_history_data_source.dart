import 'package:opennutritracker/core/db/entities/search_history_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class SearchHistoryDataSource {
  final Box<SearchHistoryOB> _box;

  SearchHistoryDataSource(this._box);

  /// Record that user searched [term] and chose [mealName].
  /// If the same term→meal pair exists, increment count.
  Future<void> recordChoice({
    required String searchTerm,
    required String mealName,
    String? mealCode,
  }) async {
    final normalized = searchTerm.toLowerCase().trim();
    final query = _box
        .query(SearchHistoryOB_.searchTerm.equals(normalized) &
            SearchHistoryOB_.chosenMealName.equals(mealName))
        .build();
    final existing = query.findFirst();
    query.close();

    if (existing != null) {
      existing.count++;
      existing.lastUsed = DateTime.now();
      if (mealCode != null) existing.chosenMealCode = mealCode;
      _box.put(existing);
    } else {
      _box.put(SearchHistoryOB(
        searchTerm: normalized,
        chosenMealName: mealName,
        chosenMealCode: mealCode,
        lastUsed: DateTime.now(),
      ));
    }
  }

  /// Get top choices for a search term, ordered by frequency.
  Future<List<SearchHistoryOB>> getTopChoices(String searchTerm,
      {int limit = 5}) async {
    final normalized = searchTerm.toLowerCase().trim();
    final query = _box
        .query(SearchHistoryOB_.searchTerm.equals(normalized))
        .order(SearchHistoryOB_.count, flags: Order.descending)
        .build();
    final results = query.find();
    query.close();
    return results.take(limit).toList();
  }

  /// Get all history entries matching a partial term (for autocomplete).
  Future<List<SearchHistoryOB>> getMatchingTerms(String partial,
      {int limit = 10}) async {
    if (partial.length < 2) return [];
    final normalized = partial.toLowerCase().trim();

    // ObjectBox doesn't have LIKE — load recent, filter in Dart
    final query = _box
        .query()
        .order(SearchHistoryOB_.count, flags: Order.descending)
        .build();
    final all = query.find();
    query.close();

    final seen = <String>{};
    return all.where((h) {
      if (!h.searchTerm.contains(normalized) && !h.chosenMealName.toLowerCase().contains(normalized)) {
        return false;
      }
      // Deduplicate by meal name
      if (seen.contains(h.chosenMealName.toLowerCase())) return false;
      seen.add(h.chosenMealName.toLowerCase());
      return true;
    }).take(limit).toList();
  }

  /// Get globally most-chosen meals across all searches (for the "Recent
  /// favorites" empty-state section).
  Future<List<SearchHistoryOB>> getTopOverall({int limit = 5}) async {
    final query = _box
        .query()
        .order(SearchHistoryOB_.count, flags: Order.descending)
        .build();
    final all = query.find();
    query.close();

    // Deduplicate by meal name
    final seen = <String>{};
    final deduped = <SearchHistoryOB>[];
    for (final h in all) {
      final key = h.chosenMealName.toLowerCase();
      if (seen.contains(key)) continue;
      seen.add(key);
      deduped.add(h);
      if (deduped.length >= limit) break;
    }
    return deduped;
  }

  /// Prune old entries (keep top 500 by count)
  Future<void> prune({int keepTop = 500}) async {
    final query = _box
        .query()
        .order(SearchHistoryOB_.count, flags: Order.descending)
        .build();
    final all = query.find();
    query.close();

    if (all.length > keepTop) {
      final toRemove = all.sublist(keepTop).map((e) => e.id).toList();
      _box.removeMany(toRemove);
    }
  }
}
