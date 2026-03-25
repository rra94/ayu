import 'package:opennutritracker/core/db/entities/peptide_ob.dart';
import 'package:opennutritracker/core/db/entities/peptide_log_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class PeptideDataSource {
  final Box<PeptideOB> _peptideBox;
  final Box<PeptideLogOB> _logBox;

  PeptideDataSource(this._peptideBox, this._logBox);

  Future<void> addPeptide(PeptideOB peptide) async {
    _peptideBox.put(peptide);
  }

  Future<void> updatePeptide(PeptideOB peptide) async {
    _peptideBox.put(peptide);
  }

  Future<void> deletePeptide(int id) async {
    _peptideBox.remove(id);
  }

  Future<List<PeptideOB>> getAllActive() async {
    final query = _peptideBox
        .query(PeptideOB_.isActive.equals(true))
        .order(PeptideOB_.name)
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<int> addLog(PeptideLogOB log) async {
    return _logBox.put(log);
  }

  Future<void> deleteLog(int id) async {
    _logBox.remove(id);
  }

  Future<List<PeptideLogOB>> getLogsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _logBox
        .query(PeptideLogOB_.dateTime.betweenDate(startOfDay, endOfDay))
        .build();
    final results = query.find();
    query.close();
    return results;
  }

  Future<Set<int>> getTodayLoggedIds() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _logBox
        .query(PeptideLogOB_.dateTime.betweenDate(startOfDay, endOfDay))
        .build();
    final results = query.find();
    query.close();
    return results.map((l) => l.peptideId).toSet();
  }

  Future<PeptideLogOB?> getLastInjectionSite(int peptideId) async {
    final query = _logBox
        .query(PeptideLogOB_.peptideId.equals(peptideId))
        .order(PeptideLogOB_.dateTime, flags: Order.descending)
        .build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  Future<List<PeptideLogOB>> getInjectionSiteHistory(int peptideId,
      {int count = 10}) async {
    final query = _logBox
        .query(PeptideLogOB_.peptideId.equals(peptideId))
        .order(PeptideLogOB_.dateTime, flags: Order.descending)
        .build()
      ..limit = count;
    final results = query.find();
    query.close();
    return results;
  }
}
