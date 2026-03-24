import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_screen.dart';
import 'package:opennutritracker/features/add_meal/presentation/add_meal_type.dart';
import 'package:opennutritracker/features/scanner/scanner_screen.dart';

class AddItemBottomSheet extends StatelessWidget {
  final DateTime day;

  const AddItemBottomSheet({super.key, required this.day});

  IntakeTypeEntity get _autoIntakeType {
    final hour = DateTime.now().hour;
    if (hour < 11) return IntakeTypeEntity.breakfast;
    if (hour < 15) return IntakeTypeEntity.lunch;
    if (hour < 21) return IntakeTypeEntity.dinner;
    return IntakeTypeEntity.snack;
  }

  AddMealType get _autoMealType {
    final hour = DateTime.now().hour;
    if (hour < 11) return AddMealType.breakfastType;
    if (hour < 15) return AddMealType.lunchType;
    if (hour < 21) return AddMealType.dinnerType;
    return AddMealType.snackType;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final gold = isLight ? ayuGoldMuted : ayuGoldLight;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // One camera button — scan anything
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(
                  NavigationOptions.scannerRoute,
                  arguments: ScannerScreenArguments(day, _autoIntakeType),
                );
              },
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: gold,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.camera_alt, size: 36,
                    color: isLight ? Colors.white : ayuNavyDark),
              ),
            ),
            const SizedBox(height: 12),
            Text('Scan anything',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600)),
            Text(
              'Barcode, receipt, or grocery bill',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(
                  NavigationOptions.addMealRoute,
                  arguments: AddMealScreenArguments(_autoMealType, day),
                );
              },
              icon: Icon(Icons.search, color: theme.colorScheme.primary),
              label: Text('or search by name',
                  style: TextStyle(color: theme.colorScheme.primary)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
