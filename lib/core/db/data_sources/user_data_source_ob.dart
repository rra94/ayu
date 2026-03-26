import 'package:logging/logging.dart';
import 'package:objectbox/objectbox.dart';
import 'package:opennutritracker/core/data/dbo/user_dbo.dart';
import 'package:opennutritracker/core/data/dbo/user_gender_dbo.dart';
import 'package:opennutritracker/core/data/dbo/user_pal_dbo.dart';
import 'package:opennutritracker/core/data/dbo/user_weight_goal_dbo.dart';
import 'package:opennutritracker/core/db/entities/user_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class UserDataSourceOB {
  final log = Logger('UserDataSourceOB');
  final Box<UserOB> _userBox;

  UserDataSourceOB(this._userBox);

  UserOB? _getUser() {
    final all = _userBox.getAll();
    if (all.isEmpty) return null;
    if (all.length > 1) {
      for (int i = 1; i < all.length; i++) {
        _userBox.remove(all[i].id);
      }
    }
    return all.first;
  }

  Future<void> saveUserData(UserDBO userDBO) async {
    log.fine('Updating user in db');
    final ob = _userDBOToOB(userDBO);
    final existing = _getUser();
    if (existing != null) ob.id = existing.id;
    _userBox.put(ob);
  }

  Future<bool> hasUserData() async => _getUser() != null;

  Future<UserDBO> getUserData() async {
    final ob = _getUser();
    return ob != null
        ? _userOBToDBO(ob)
        : UserDBO(
            birthday: DateTime(2000, 1, 1),
            heightCM: 180,
            weightKG: 80,
            gender: UserGenderDBO.male,
            goal: UserWeightGoalDBO.maintainWeight,
            pal: UserPALDBO.active);
  }
}

// ---------------------------------------------------------------------------
// DBO <-> OB converters
// ---------------------------------------------------------------------------

UserOB _userDBOToOB(UserDBO dbo) {
  return UserOB(
    birthday: dbo.birthday,
    heightCM: dbo.heightCM,
    weightKG: dbo.weightKG,
    gender: dbo.gender.index,
    goal: dbo.goal.index,
    pal: dbo.pal.index,
  );
}

UserDBO _userOBToDBO(UserOB ob) {
  return UserDBO(
    birthday: ob.birthday,
    heightCM: ob.heightCM,
    weightKG: ob.weightKG,
    gender: UserGenderDBO.values[ob.gender],
    goal: UserWeightGoalDBO.values[ob.goal],
    pal: UserPALDBO.values[ob.pal],
  );
}
