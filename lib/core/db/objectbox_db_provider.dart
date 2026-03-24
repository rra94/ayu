import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:opennutritracker/core/db/entities/intake_ob.dart';
import 'package:opennutritracker/core/db/entities/tracked_day_ob.dart';
import 'package:opennutritracker/core/db/entities/user_ob.dart';
import 'package:opennutritracker/core/db/entities/config_ob.dart';
import 'package:opennutritracker/core/db/entities/user_activity_ob.dart';
import 'package:opennutritracker/core/db/entities/physical_activity_ob.dart';
import 'package:opennutritracker/core/db/entities/water_record_ob.dart';
import 'package:opennutritracker/core/db/entities/habit_ob.dart';
import 'package:opennutritracker/core/db/entities/habit_log_ob.dart';
import 'package:opennutritracker/core/db/entities/gut_health_item_ob.dart';
import 'package:opennutritracker/core/db/entities/biomarker_record_ob.dart';
import 'package:opennutritracker/core/db/entities/caffeine_log_ob.dart';
import 'package:opennutritracker/core/db/entities/product_inventory_ob.dart';
import 'package:opennutritracker/core/db/entities/dexa_scan_ob.dart';
import 'package:opennutritracker/core/db/entities/fasting_session_ob.dart';
import 'package:opennutritracker/core/db/entities/mindfulness_session_ob.dart';
import 'package:opennutritracker/core/db/entities/sleep_record_ob.dart';
import 'package:opennutritracker/core/db/entities/supplement_ob.dart';
import 'package:opennutritracker/core/db/entities/stool_log_ob.dart';
import 'package:opennutritracker/core/db/entities/symptom_log_ob.dart';
import 'package:opennutritracker/core/db/entities/weight_record_ob.dart';
import 'package:opennutritracker/objectbox.g.dart';

class ObjectBoxDBProvider extends ChangeNotifier {
  late Store store;

  late Box<IntakeOB> intakeBox;
  late Box<TrackedDayOB> trackedDayBox;
  late Box<UserOB> userBox;
  late Box<ConfigOB> configBox;
  late Box<UserActivityOB> userActivityBox;
  late Box<PhysicalActivityOB> physicalActivityBox;
  late Box<WaterRecordOB> waterRecordBox;
  late Box<HabitOB> habitBox;
  late Box<HabitLogOB> habitLogBox;
  late Box<GutHealthItemOB> gutHealthItemBox;
  late Box<WeightRecordOB> weightRecordBox;
  late Box<StoolLogOB> stoolLogBox;
  late Box<SymptomLogOB> symptomLogBox;
  late Box<BiomarkerRecordOB> biomarkerBox;
  late Box<DexaScanOB> dexaScanBox;
  late Box<CaffeineLogOB> caffeineLogBox;
  late Box<ProductInventoryOB> inventoryBox;
  late Box<SupplementOB> supplementBox;
  late Box<SupplementLogOB> supplementLogBox;
  late Box<FastingSessionOB> fastingSessionBox;
  late Box<SleepRecordOB> sleepRecordBox;
  late Box<MindfulnessSessionOB> mindfulnessSessionBox;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    store = await openStore(directory: '${dir.path}/objectbox');

    intakeBox = store.box<IntakeOB>();
    trackedDayBox = store.box<TrackedDayOB>();
    userBox = store.box<UserOB>();
    configBox = store.box<ConfigOB>();
    userActivityBox = store.box<UserActivityOB>();
    physicalActivityBox = store.box<PhysicalActivityOB>();
    waterRecordBox = store.box<WaterRecordOB>();
    habitBox = store.box<HabitOB>();
    habitLogBox = store.box<HabitLogOB>();
    gutHealthItemBox = store.box<GutHealthItemOB>();
    weightRecordBox = store.box<WeightRecordOB>();
    stoolLogBox = store.box<StoolLogOB>();
    symptomLogBox = store.box<SymptomLogOB>();
    biomarkerBox = store.box<BiomarkerRecordOB>();
    dexaScanBox = store.box<DexaScanOB>();
    caffeineLogBox = store.box<CaffeineLogOB>();
    inventoryBox = store.box<ProductInventoryOB>();
    supplementBox = store.box<SupplementOB>();
    supplementLogBox = store.box<SupplementLogOB>();
    fastingSessionBox = store.box<FastingSessionOB>();
    sleepRecordBox = store.box<SleepRecordOB>();
    mindfulnessSessionBox = store.box<MindfulnessSessionOB>();
  }

  void close() {
    store.close();
  }
}
