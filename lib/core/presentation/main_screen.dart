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
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/core/services/notification_action_service.dart';
import 'package:opennutritracker/core/services/widget_service.dart';
import 'package:opennutritracker/features/health_connect/services/healthkit_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    // Request notification permission on first launch (iOS)
    FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    NotificationActionService.init();
    WidgetService.init();
    DataRetentionService.pruneOldData().catchError((e) {
      debugPrint('DataRetention prune error: $e');
    });
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
      try {
        // Day changed — reload all data
        _onAppResumed();
        // Force home page to refresh via BLoC (resets water tracker etc.)
        try {
          locator<HomeBloc>().add(const LoadItemsEvent());
        } catch (_) {}
      } catch (_) {}
      // Always reschedule next midnight
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
    try { await locator<CoreMotionService>().recordSnapshot(); } catch (e) { debugPrint('CoreMotion: $e'); }
    try { await locator<BarometerService>().recordReading(); } catch (e) { debugPrint('Barometer: $e'); }
    try { await locator<LocationInferenceService>().startMonitoring(); } catch (e) { debugPrint('LocationInference: $e'); }
    // Auto-sync HealthKit data on each foreground (lightweight, just last day)
    try {
      if (await HealthKitService.hasPermissions()) {
        await HealthKitService.sync(days: 1);
      }
    } catch (e) { debugPrint('HealthKit sync: $e'); }
    // Load photo analysis opt-in setting
    try {
      final enabled = locator<ConfigDataSourceOB>().getShowPhotoAnalysis();
      if (mounted) setState(() => _photoAnalysisEnabled = enabled);
    } catch (e) { debugPrint('Config load: $e'); }
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
          ? FloatingActionButton(
              heroTag: 'add',
              onPressed: () => _showAddOptions(context),
              tooltip: 'Add',
              child: const Icon(Icons.add),
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

  void _showAddOptions(BuildContext context) {
    final hour = DateTime.now().hour;
    final intakeType = hour < 11
        ? IntakeTypeEntity.breakfast
        : hour < 15
            ? IntakeTypeEntity.lunch
            : hour < 21
                ? IntakeTypeEntity.dinner
                : IntakeTypeEntity.snack;

    final mealType = hour < 11
        ? AddMealType.breakfastType
        : hour < 15
            ? AddMealType.lunchType
            : hour < 21
                ? AddMealType.dinnerType
                : AddMealType.snackType;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search Food'),
              subtitle: const Text('Look up by name'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushNamed(
                  NavigationOptions.addMealRoute,
                  arguments: AddMealScreenArguments(mealType, DateTime.now()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan Barcode'),
              subtitle: const Text('Scan a product barcode'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushNamed(
                  NavigationOptions.scannerRoute,
                  arguments: ScannerScreenArguments(DateTime.now(), intakeType),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Scan Receipt'),
              subtitle: const Text('Photo of grocery or restaurant receipt'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushNamed(
                  NavigationOptions.receiptScannerRoute,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('Photo Meal'),
              subtitle: Text(_photoAnalysisEnabled
                  ? 'Take a photo — AI identifies food & calories'
                  : 'Enable in Settings to use AI photo analysis'),
              onTap: () {
                Navigator.pop(ctx);
                if (_photoAnalysisEnabled) {
                  Navigator.of(context).pushNamed(
                    NavigationOptions.photoMealRoute,
                  );
                } else {
                  Navigator.of(context).pushNamed(
                    NavigationOptions.settingsRoute,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Describe Meal'),
              subtitle: const Text('Type what you ate — we look up nutrition'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushNamed(
                  NavigationOptions.photoMealRoute,
                  arguments: 'manual',
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
