import 'dart:async';
import 'package:flutter/material.dart';
import 'package:opennutritracker/features/diary/diary_page.dart';
import 'package:opennutritracker/core/presentation/widgets/home_appbar.dart';
import 'package:opennutritracker/features/home/home_page.dart';
import 'package:opennutritracker/core/presentation/widgets/main_appbar.dart';
import 'package:opennutritracker/features/stats/stats_page.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/scanner/scanner_screen.dart';
import 'package:opennutritracker/features/stats/charts_page.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:opennutritracker/core/services/barometer_service.dart';
import 'package:opennutritracker/core/services/core_motion_service.dart';
import 'package:opennutritracker/core/db/data_sources/config_data_source_ob.dart';
import 'package:opennutritracker/core/services/data_retention_service.dart';
import 'package:opennutritracker/core/services/location_inference_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedPageIndex = 0;
  Timer? _midnightTimer;
  bool _photoAnalysisEnabled = false;

  late List<Widget> _bodyPages;
  late List<PreferredSizeWidget> _appbarPages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DataRetentionService.pruneOldData();
    _onAppResumed();
    _scheduleMidnightRefresh();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Schedule a refresh at midnight so daily data resets automatically.
  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final duration = midnight.difference(now);
    _midnightTimer = Timer(duration, () {
      // Day changed — reload all data
      _onAppResumed();
      // Schedule next midnight
      _scheduleMidnightRefresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  Future<void> _onAppResumed() async {
    // Record sensor data on each foreground
    try { await locator<CoreMotionService>().recordSnapshot(); } catch (_) {}
    try { await locator<BarometerService>().recordReading(); } catch (_) {}
    try { await locator<LocationInferenceService>().startMonitoring(); } catch (_) {}
    // Load photo analysis opt-in setting
    try {
      final enabled = locator<ConfigDataSourceOB>().getShowPhotoAnalysis();
      if (mounted) setState(() => _photoAnalysisEnabled = enabled);
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    _bodyPages = [
      const HomePage(),
      const DiaryPage(),
      const ChartsPage(),
      const StatsPage(),
    ];
    _appbarPages = [
      const HomeAppbar(),
      MainAppbar(title: S.of(context).diaryLabel, iconData: Icons.book),
      MainAppbar(title: 'Charts', iconData: Icons.show_chart),
      MainAppbar(title: 'Stats', iconData: Icons.bar_chart),
    ];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarPages[_selectedPageIndex],
      body: _bodyPages[_selectedPageIndex],
      floatingActionButton: _selectedPageIndex == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Only show photo FAB if user opted in
                if (_photoAnalysisEnabled) ...[
                  FloatingActionButton.small(
                    heroTag: 'photo',
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(NavigationOptions.photoMealRoute);
                    },
                    tooltip: 'Photo meal',
                    child: const Icon(Icons.photo_camera, size: 20),
                  ),
                  const SizedBox(height: 8),
                ],
                FloatingActionButton.small(
                  heroTag: 'search',
                  onPressed: () {
                    final hour = DateTime.now().hour;
                    final mealType = hour < 11
                        ? AddMealType.breakfastType
                        : hour < 15
                            ? AddMealType.lunchType
                            : hour < 21
                                ? AddMealType.dinnerType
                                : AddMealType.snackType;
                    Navigator.of(context).pushNamed(
                      NavigationOptions.addMealRoute,
                      arguments: AddMealScreenArguments(mealType, DateTime.now()),
                    );
                  },
                  tooltip: 'Search food',
                  child: const Icon(Icons.search, size: 20),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'scan',
                  onPressed: () {
                    final hour = DateTime.now().hour;
                    final intakeType = hour < 11
                        ? IntakeTypeEntity.breakfast
                        : hour < 15
                            ? IntakeTypeEntity.lunch
                            : hour < 21
                                ? IntakeTypeEntity.dinner
                                : IntakeTypeEntity.snack;
                    Navigator.of(context).pushNamed(
                      NavigationOptions.scannerRoute,
                      arguments: ScannerScreenArguments(DateTime.now(), intakeType),
                    );
                  },
                  tooltip: 'Scan',
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedPageIndex,
        onDestinationSelected: _setPage,
        destinations: [
          NavigationDestination(
              icon: _selectedPageIndex == 0
                  ? const Icon(Icons.home)
                  : const Icon(Icons.home_outlined),
              label: S.of(context).homeLabel),
          NavigationDestination(
              icon: _selectedPageIndex == 1
                  ? const Icon(Icons.book)
                  : const Icon((Icons.book_outlined)),
              label: S.of(context).diaryLabel),
          NavigationDestination(
              icon: _selectedPageIndex == 2
                  ? const Icon(Icons.show_chart)
                  : const Icon(Icons.show_chart),
              label: 'Charts'),
          NavigationDestination(
              icon: _selectedPageIndex == 3
                  ? const Icon(Icons.bar_chart)
                  : const Icon(Icons.bar_chart_outlined),
              label: 'Stats'),
        ],
      ),
    );
  }

  void _setPage(int selectedIndex) {
    setState(() {
      _selectedPageIndex = selectedIndex;
    });
  }

}
