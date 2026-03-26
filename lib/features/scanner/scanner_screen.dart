import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/presentation/widgets/error_dialog.dart';
import 'package:opennutritracker/core/domain/usecase/delete_intake_usecase.dart';
import 'package:opennutritracker/core/services/intent_donation_service.dart';
import 'package:opennutritracker/core/services/widget_service.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_nutriments_entity.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/calendar_day_bloc.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_bloc.dart';
import 'package:opennutritracker/features/edit_meal/presentation/edit_meal_screen.dart';
import 'package:opennutritracker/features/home/presentation/bloc/home_bloc.dart';
import 'package:opennutritracker/features/meal_detail/meal_detail_screen.dart';
import 'package:opennutritracker/features/meal_detail/presentation/bloc/meal_detail_bloc.dart';
import 'package:opennutritracker/features/scanner/presentation/scanner_bloc.dart';
import 'package:opennutritracker/generated/l10n.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final log = Logger('ScannerScreen');

  String? _scannedBarcode;
  Rect? _detectedBarcodeRect;
  bool _dialogShowing = false;
  late IntakeTypeEntity _intakeTypeEntity;
  late DateTime _day;

  late ScannerBloc _scannerBloc;

  @override
  void initState() {
    _scannerBloc = locator<ScannerBloc>();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final args =
        ModalRoute.of(context)?.settings.arguments as ScannerScreenArguments;
    _intakeTypeEntity = args.intakeTypeEntity;
    _day = args.day;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScannerBloc, ScannerState>(
      bloc: _scannerBloc,
      builder: (context, state) {
        if (state is ScannerInitial) {
          return _getScannerContent(context);
        } else if (state is ScannerLoadingState) {
          return Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()));
        } else if (state is ScannerLoadedState) {
          Future.microtask(() {
            if (!context.mounted) return;
            if (_dialogShowing) return;
            _dialogShowing = true;

            // Supplements: skip meal detail, show confirmation
            if (state.isSupplement) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(
                  '${state.product.name ?? "Supplement"} added to your stack!',
                )),
              );
              Navigator.of(context).pop();
              _dialogShowing = false;
              return;
            }

            // Food: show allergen warning or quick-add dialog
            if (state.allergenAlerts.isNotEmpty) {
              _showAllergenWarning(context, state);
            } else {
              _showQuickAddDialog(context, state);
            }
          });
        } else if (state is ScannerFailedState) {
          return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ErrorDialog(
                      errorText: state.type == ScannerFailedStateType.offline
                          ? 'No internet connection. Check your network and try again.'
                          : state.type == ScannerFailedStateType.productNotFound
                              ? S.of(context).errorProductNotFound
                              : S.of(context).errorFetchingProductData,
                      onRefreshPressed: _onRefreshButtonPressed,
                    ),
                    if (state.type == ScannerFailedStateType.productNotFound) ...[
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _createCustomFood(context),
                        icon: const Icon(Icons.edit),
                        label: const Text('Create Custom Entry'),
                      ),
                    ],
                  ],
                ),
              ));
        }
        return const SizedBox();
      },
    );
  }

  MobileScannerController? _cameraController;

  MobileScannerController get _camera {
    _cameraController ??= MobileScannerController();
    return _cameraController!;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Scaffold _getScannerContent(BuildContext context) {
    final cameraController = _camera;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).scanProductLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_camera),
            tooltip: 'Photo to Calories',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                NavigationOptions.photoMealRoute,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Scan Receipt',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                NavigationOptions.receiptScannerRoute,
              );
            },
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off || TorchState.unavailable:
                    return const Icon(Icons.flash_off_outlined,
                        color: Colors.grey);
                  case TorchState.on || TorchState.auto:
                    return const Icon(Icons.flash_on_outlined);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android_outlined),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null &&
                    barcode.type == BarcodeType.product) {
                  final barcodeResult = barcode.rawValue;
                  if (barcodeResult != null) {
                    // Visual feedback: highlight detected barcode location
                    final corners = barcode.corners;
                    if (corners.length >= 3) {
                      setState(() {
                        _detectedBarcodeRect = Rect.fromPoints(
                          Offset(corners.first.dx, corners.first.dy),
                          Offset(corners[2].dx, corners[2].dy),
                        );
                      });
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          setState(() => _detectedBarcodeRect = null);
                        }
                      });
                    }
                    _scannedBarcode = barcodeResult;
                    log.fine('Barcode found: $barcodeResult');
                    _scannerBloc
                        .add(ScannerLoadProductEvent(barcode: barcodeResult));
                  }
                }
              }
            },
          ),
          // Scan area guide overlay
          _buildScanOverlay(context),
          // Barcode detection highlight
          if (_detectedBarcodeRect != null)
            Positioned(
              left: _detectedBarcodeRect!.left,
              top: _detectedBarcodeRect!.top,
              width: _detectedBarcodeRect!.width,
              height: _detectedBarcodeRect!.height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay(BuildContext context) {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: const Align(
        alignment: Alignment(0, 0.6),
        child: Text(
          'Point at a barcode',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }

  void _onRefreshButtonPressed() {
    final barcode = _scannedBarcode;
    if (barcode != null) {
      _scannerBloc.add(ScannerLoadProductEvent(barcode: barcode));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).errorFetchingProductData)));
    }
  }

  void _createCustomFood(BuildContext context) {
    // Navigate to edit meal screen with empty template for custom entry
    Navigator.of(context).pushNamed(
      NavigationOptions.editMealRoute,
      arguments: EditMealScreenArguments(
        _day,
        MealEntity(
          code: _scannedBarcode,
          name: '',
          url: null,
          mealQuantity: '100',
          mealUnit: 'g',
          servingQuantity: null,
          servingUnit: null,
          servingSize: null,
          source: MealSourceEntity.custom,
          nutriments: MealNutrimentsEntity.empty(),
        ),
        _intakeTypeEntity,
        false,
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context, ScannerLoadedState state) {
    final product = state.product;
    final servingDesc = product.servingSize ??
        (product.servingQuantity != null
            ? '${product.servingQuantity} ${product.servingUnit ?? 'g'}'
            : '100g');
    final kcalText = product.nutriments.energyKcal100 != null
        ? '${product.nutriments.energyKcal100!.round()} kcal / 100g'
        : '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name ?? 'Unknown Product',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            if (kcalText.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(kcalText,
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(ctx).colorScheme.secondary)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await _quickAdd(context, state);
                    },
                    icon: const Icon(Icons.bolt),
                    label: Text('Quick Add ($servingDesc)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushReplacementNamed(
                        NavigationOptions.mealDetailRoute,
                        arguments: MealDetailScreenArguments(
                            product,
                            _intakeTypeEntity,
                            _day,
                            state.usesImperialUnits),
                      );
                    },
                    icon: const Icon(Icons.tune),
                    label: const Text('Details'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).whenComplete(() => _dialogShowing = false);
  }

  Future<void> _quickAdd(BuildContext context, ScannerLoadedState state) async {
    final product = state.product;

    // Determine default amount and unit:
    // - If product has serving quantity, use it (e.g., 250g for a can)
    // - If product has mealQuantity from OFF, use it
    // - Otherwise fall back to 100g
    final double amount;
    final String unit;
    if (product.servingQuantity != null && product.servingQuantity! > 0) {
      amount = product.servingQuantity!;
      unit = product.servingUnit ?? UnitDropdownItem.g.toString();
    } else {
      final mealQty = double.tryParse(product.mealQuantity ?? '');
      if (mealQty != null && mealQty > 0 && mealQty != 100) {
        amount = mealQty;
        unit = product.mealUnit ?? UnitDropdownItem.g.toString();
      } else {
        amount = 100.0;
        unit = UnitDropdownItem.g.toString();
      }
    }

    // Use MealDetailBloc to save — it handles AddIntakeUsecase + AddTrackedDayUsecase
    final mealDetailBloc = locator<MealDetailBloc>();
    final intake = await mealDetailBloc.addIntake(
        context, unit, amount.toString(), _intakeTypeEntity, product, _day);

    // Refresh dependent blocs
    locator<HomeBloc>().add(const LoadItemsEvent());
    locator<DiaryBloc>().add(const LoadDiaryYearEvent());
    locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());

    // Update iOS home-screen widget
    WidgetService.refreshFromDB();

    IntentDonationService.donateScanMeal();

    // Show confirmation snackbar with undo
    final kcal = amount * (product.nutriments.energyPerUnit ?? 0);
    final name = product.name ?? 'Item';
    if (context.mounted) {
      // Pop scanner first, then show snackbar on the parent screen
      Navigator.of(context).pop();
      // Use a microtask to show snackbar after navigation completes
      Future.microtask(() {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $name (${kcal.round()} kcal)'),
            duration: const Duration(seconds: 10),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () async {
                await locator<DeleteIntakeUsecase>().deleteIntake(intake);
                locator<HomeBloc>().add(const LoadItemsEvent());
                locator<DiaryBloc>().add(const LoadDiaryYearEvent());
                locator<CalendarDayBloc>().add(RefreshCalendarDayEvent());
              },
            ),
          ),
        );
      });
    }
  }

  void _showAllergenWarning(BuildContext context, ScannerLoadedState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber, color: Colors.red, size: 36),
        title: const Text('Allergen Alert!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${state.product.name ?? 'This product'} contains:'),
            const SizedBox(height: 8),
            ...state.allergenAlerts.map((a) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.dangerous, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(a.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (a.isTrace) const Text(' (trace)', style: TextStyle(fontSize: 12)),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // just close dialog, stay on scanner
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushReplacementNamed(
                  NavigationOptions.mealDetailRoute,
                  arguments: MealDetailScreenArguments(state.product,
                      _intakeTypeEntity, _day, state.usesImperialUnits));
            },
            child: const Text('Continue Anyway'),
          ),
        ],
      ),
    ).whenComplete(() => _dialogShowing = false);
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 - 40),
        width: size.width * 0.8,
        height: 200,
      ),
      const Radius.circular(16),
    );

    // Dark overlay with cutout
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(scanRRect);
    overlayPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(overlayPath, Paint()..color = Colors.black45);

    // Gold corner brackets
    final gold = Paint()
      ..color = const Color(0xFFD4A843)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = scanRRect.outerRect;
    const double len = 30.0;
    const double r = 16.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.top + len)
        ..lineTo(rect.left, rect.top + r)
        ..arcToPoint(Offset(rect.left + r, rect.top),
            radius: const Radius.circular(r))
        ..lineTo(rect.left + len, rect.top),
      gold,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - len, rect.top)
        ..lineTo(rect.right - r, rect.top)
        ..arcToPoint(Offset(rect.right, rect.top + r),
            radius: const Radius.circular(r))
        ..lineTo(rect.right, rect.top + len),
      gold,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(rect.left, rect.bottom - len)
        ..lineTo(rect.left, rect.bottom - r)
        ..arcToPoint(Offset(rect.left + r, rect.bottom),
            radius: const Radius.circular(r))
        ..lineTo(rect.left + len, rect.bottom),
      gold,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(rect.right - len, rect.bottom)
        ..lineTo(rect.right - r, rect.bottom)
        ..arcToPoint(Offset(rect.right, rect.bottom - r),
            radius: const Radius.circular(r))
        ..lineTo(rect.right, rect.bottom - len),
      gold,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScannerScreenArguments {
  final DateTime day;
  final IntakeTypeEntity intakeTypeEntity;

  ScannerScreenArguments(this.day, this.intakeTypeEntity);
}
