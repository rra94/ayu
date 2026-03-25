import 'package:flutter/material.dart';
import 'package:opennutritracker/core/db/data_sources/fasting_data_source.dart';
import 'package:opennutritracker/core/db/data_sources/water_data_source.dart';
import 'package:opennutritracker/core/db/entities/caffeine_log_ob.dart';
import 'package:opennutritracker/core/db/data_sources/caffeine_data_source.dart';
import 'package:opennutritracker/core/db/entities/fasting_session_ob.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/styles/color_schemes.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/core/services/intent_donation_service.dart';
import 'package:opennutritracker/features/scanner/scanner_screen.dart';

class QuickActionBar extends StatelessWidget {
  final VoidCallback onActionComplete;

  const QuickActionBar({super.key, required this.onActionComplete});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final gold = isLight ? ayuGoldMuted : ayuGoldLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickChip(
              icon: Icons.water_drop,
              label: '+250ml',
              color: gold,
              onTap: () async {
                final ds = locator<WaterDataSource>();
                await ds.addWaterRecord(250, DateTime.now());
                IntentDonationService.donateLogWater();
                onActionComplete();
              },
            ),
            const SizedBox(width: 8),
            _QuickChip(
              icon: Icons.qr_code_scanner,
              label: 'Scan',
              color: gold,
              onTap: () => Navigator.of(context).pushNamed(
                NavigationOptions.scannerRoute,
                arguments: ScannerScreenArguments(
                  DateTime.now(), IntakeTypeEntity.snack,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _QuickChip(
              icon: Icons.coffee,
              label: 'Coffee',
              color: gold,
              onTap: () async {
                final ds = locator<CaffeineDataSource>();
                await ds.addLog(CaffeineLogOB(
                  amountMg: 95, source: 'coffee', dateTime: DateTime.now(),
                ));
                IntentDonationService.donateLogCoffee();
                onActionComplete();
              },
            ),
            const SizedBox(width: 8),
            _QuickChip(
              icon: Icons.timer,
              label: 'Fast 16:8',
              color: gold,
              onTap: () async {
                final ds = locator<FastingDataSource>();
                final active = await ds.getActiveSession();
                if (active == null) {
                  await ds.saveSession(FastingSessionOB(
                    startTime: DateTime.now(),
                    targetHours: 16,
                    type: 0,
                  ));
                }
                IntentDonationService.donateStartFast();
                onActionComplete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      onPressed: onTap,
      side: BorderSide(color: color.withValues(alpha: 0.3)),
      backgroundColor: color.withValues(alpha: 0.05),
    );
  }
}
