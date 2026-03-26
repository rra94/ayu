import 'package:logging/logging.dart';
import 'package:opennutritracker/core/data/data_source/user_activity_dbo.dart';
import 'package:opennutritracker/core/data/dbo/physical_activity_dbo.dart';
import 'package:opennutritracker/core/db/entities/user_activity_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class UserActivityDataSourceOB {
  final log = Logger('UserActivityDataSourceOB');
  final Box<UserActivityOB> _userActivityBox;

  UserActivityDataSourceOB(this._userActivityBox);

  Future<void> addUserActivity(UserActivityDBO userActivityDBO) async {
    log.fine('Adding new user activity to db');
    _userActivityBox.put(_userActivityDBOToOB(userActivityDBO));
  }

  Future<void> addAllUserActivities(
      List<UserActivityDBO> userActivityDBOList) async {
    log.fine('Adding new user activities to db');
    _userActivityBox
        .putMany(userActivityDBOList.map(_userActivityDBOToOB).toList());
  }

  Future<void> deleteIntakeFromId(String activityId) async {
    log.fine('Deleting activity item from db');
    final query = _userActivityBox
        .query(UserActivityOB_.activityId.equals(activityId))
        .build();
    final results = query.find();
    query.close();
    for (final ob in results) {
      _userActivityBox.remove(ob.id);
    }
  }

  Future<List<UserActivityDBO>> getAllUserActivities() async {
    return _userActivityBox.getAll().map(_userActivityOBToDBO).toList();
  }

  Future<List<UserActivityDBO>> getAllUserActivitiesByDate(
      DateTime dateTime) async {
    final startOfDay =
        DateTime(dateTime.year, dateTime.month, dateTime.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _userActivityBox
        .query(UserActivityOB_.date.greaterOrEqualDate(startOfDay).and(
            UserActivityOB_.date.lessThanDate(endOfDay)))
        .build();
    final results = query.find();
    query.close();
    return results.map(_userActivityOBToDBO).toList();
  }

  Future<List<UserActivityDBO>> getRecentlyAddedUserActivity(
      {int number = 20}) async {
    final allOB = _userActivityBox.getAll();
    final userActivities =
        allOB.map(_userActivityOBToDBO).toList().reversed.toList();

    //  sort list by date and filter unique activities
    userActivities
        .sort((a, b) => a.date.toString().compareTo(b.date.toString()));

    final filterActivityCodes = <String>{};
    final uniqueUserActivities = userActivities
        .where((activity) =>
            filterActivityCodes.add(activity.physicalActivityDBO.code))
        .toList();

    // return range or full list
    try {
      return uniqueUserActivities.getRange(0, number).toList();
    } on RangeError catch (_) {
      return uniqueUserActivities.toList();
    }
  }
}

// ---------------------------------------------------------------------------
// DBO <-> OB converters
// ---------------------------------------------------------------------------

UserActivityOB _userActivityDBOToOB(UserActivityDBO dbo) {
  return UserActivityOB(
    activityId: dbo.id,
    duration: dbo.duration,
    burnedKcal: dbo.burnedKcal,
    date: dbo.date,
    activityCode: dbo.physicalActivityDBO.code,
    specificActivity: dbo.physicalActivityDBO.specificActivity,
    description: dbo.physicalActivityDBO.description,
    mets: dbo.physicalActivityDBO.mets,
    tags: dbo.physicalActivityDBO.tags,
    activityType: dbo.physicalActivityDBO.type.index,
  );
}

UserActivityDBO _userActivityOBToDBO(UserActivityOB ob) {
  return UserActivityDBO(
    ob.activityId,
    ob.duration,
    ob.burnedKcal,
    ob.date,
    PhysicalActivityDBO(
      ob.activityCode,
      ob.specificActivity,
      ob.description,
      ob.mets,
      ob.tags,
      PhysicalActivityTypeDBO.values[ob.activityType],
    ),
  );
}
