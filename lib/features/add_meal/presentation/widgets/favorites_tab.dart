import 'package:flutter/material.dart';
import 'package:opennutritracker/core/data/dbo/intake_dbo.dart';
import 'package:opennutritracker/core/db/data_sources/intake_data_source_ob.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/utils/navigation_options.dart';
import 'package:opennutritracker/features/meal_detail/meal_detail_screen.dart';

class FavoritesTab extends StatefulWidget {
  final DateTime day;

  const FavoritesTab({super.key, required this.day});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<IntakeDBO> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  IntakeTypeEntity get _autoIntakeType {
    final hour = DateTime.now().hour;
    if (hour < 11) return IntakeTypeEntity.breakfast;
    if (hour < 15) return IntakeTypeEntity.lunch;
    if (hour < 21) return IntakeTypeEntity.dinner;
    return IntakeTypeEntity.snack;
  }

  Future<void> _load() async {
    final ds = locator<IntakeDataSourceOB>();
    final favorites = await ds.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = favorites;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_outline, size: 48,
                  color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
              Text('No favorites yet', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Long-press any logged meal to add it to favorites.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final dbo = _favorites[index];
        final entity = IntakeEntity.fromIntakeDBO(dbo);
        final meal = entity.meal;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: Text(
              meal.name ?? 'Unknown',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${meal.brands ?? ''} · ${entity.totalKcal.round()} kcal',
              style: theme.textTheme.bodySmall,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(
                NavigationOptions.mealDetailRoute,
                arguments: MealDetailScreenArguments(
                  meal, _autoIntakeType, widget.day, false,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
