# Ayu — Project Plans

> **Ayu** (Sanskrit: आयु — "life / longevity") — fork of OpenNutriTracker into a comprehensive nutrition + longevity tracker.

## Architecture Defaults
```yaml
db: objectbox (23 entities)
architecture: modular (feature-module pattern + service layer)
state: bloc (feature-level, not monolithic)
params: named
platform: flutter_ios
ai: on_device (Apple Vision OCR, pure Dart agents)
testing: manual_iphone (after each milestone)
theme: lotus (navy #0D1B2A + gold #D4A843, 16px card radius)
```

## Milestone Index

| Milestone | Directory | Status |
|-----------|-----------|--------|
| [M0: Architecture Refactor](m0-architecture/) | ObjectBox migration, modular structure, service layer | Done |
| [M1: Nutrient Pipeline](m1-nutrients/) | Micronutrients, RDA, added sugar, data resolution | Done |
| [M2: Home Page UX](m2-home-ux/) | Water, habits, gut health, quick actions, today view | Done |
| [M3: Stats Tab](m3-stats/) | Weight, DEXA, biomarkers, bio age, food-to-feeling, Bristol stool | Done |
| [M4: Longevity Suite](m4-longevity/) | Supplements, fasting, sleep, meal timing, streaks, NSDR | Done |
| [M5: Integrations](m5-integrations/) | HealthKit, HRV correlation, longevity insights | Done |
| [M6: Intelligence](m6-intelligence/) | Net carbs, GI/GL, weekly review, daily summary, agents | Done |
| [M7: Smart Nutrition](m7-smart-nutrition/) | Bioavailability engine, nutrient recommendations | Done |
| M8: Phone Sensors | CoreMotion, CoreLocation, Barometer, Activity Dashboard | Not started |
| M9: Peptide Tracker | Peptide stack, reconstitution calc, injection site rotation, agent | Not started |
| M10: Polishing | 30 plants tracker, nutrient synergy, allergen persistence | Not started |
| M11: Widget & Extras | iOS Lock Screen widget, Blueprint Mode | Not started |

**Implementation plan:** [`docs/superpowers/plans/2026-03-24-remaining-features.md`](../docs/superpowers/plans/2026-03-24-remaining-features.md)

## Implemented But Not Originally Planned

These features were added during development and are not tracked in milestone plan files:

| Feature | Key Files | Notes |
|---------|-----------|-------|
| Allergen alerts | `allergen_service.dart` | User-configured allergens, scanned product warnings |
| Receipt scanning (Vision OCR) | `AppDelegate.swift`, `receipt_parser_service.dart` | Apple Vision on-device, grocery classification |
| Health conditions | `health_condition_service.dart` | 16 conditions incl. cosmetic (acne, hair loss, dental) |
| Caffeine tracking | `caffeine_data_source.dart`, `caffeine_log_ob.dart` | Quick-add from home, agent-aware |
| Cross-agent observation engine | `observation_agent.dart` | 5 cross-domain correlations |
| Smart notifications | `smart_notification_service.dart` | Auto-start fast, missing entry reminders |
| Supplement auto-detection | `supplement_detector.dart` | Barcode scan auto-adds supplements |
| Custom food entry | `scanner_screen.dart` | Create custom entry for not-found items |
| Grocery/pantry tracking | `grocery_service.dart`, `inventory_data_source.dart` | Receipt-based, expiry alerts |
| Lotus theme | `color_schemes.dart`, `main.dart` | Navy + gold, 11 component themes |

## Not Yet Implemented (from original plans)

| Feature | Plan File | Priority | Notes |
|---------|-----------|----------|-------|
| Nutritionix API | `m1-nutrients/nutritionix.md` | Low | OFF + USDA covers most needs |
| Nutrient synergy checker | `m1-nutrients/synergy-checker.md` | Medium | Shows beneficial/harmful nutrient combos |
| 30 Plants a Week tracker | `m2-home-ux/30-plants.md` | Medium | Count unique plant foods per week |
| Blueprint Mode toggle | `m2-home-ux/blueprint-mode.md` | Low | Bryan Johnson protocol mode |
| iOS Lock Screen widget | `m5-integrations/widget.md` | Medium | WidgetKit bridge exists but widget not built |
| Phone sensors (CoreMotion/Location/Barometer) | `docs/superpowers/specs/2026-03-24-phone-sensors-design.md` | High | Spec approved, ready for implementation |

## Feature Index (A-Z)

### Core Features
- **A.** Gut health panel → [m2-home-ux/gut-health.md](m2-home-ux/gut-health.md)
- **B.** Micronutrients + RDA → [m1-nutrients/micronutrients.md](m1-nutrients/micronutrients.md)
- **C.** Weight history → [m3-stats/weight.md](m3-stats/weight.md)
- **D.** Stats tab shell → [m3-stats/stats-tab.md](m3-stats/stats-tab.md)
- **E.** Biomarkers → [m3-stats/biomarkers.md](m3-stats/biomarkers.md)
- **F.** Supplements → [m4-longevity/supplements.md](m4-longevity/supplements.md)
- **G.** Fasting timer → [m4-longevity/fasting.md](m4-longevity/fasting.md)
- **H.** Daily habits → [m2-home-ux/habits.md](m2-home-ux/habits.md)
- **I.** Quick-add favorites → [m2-home-ux/favorites.md](m2-home-ux/favorites.md)
- **J.** Water tracking → [m2-home-ux/water.md](m2-home-ux/water.md)
- **K.** Sleep tracking → [m4-longevity/sleep.md](m4-longevity/sleep.md)
- **L.** Meal timing → [m4-longevity/meal-timing.md](m4-longevity/meal-timing.md)
- **M.** Data resolution → [m1-nutrients/data-resolution.md](m1-nutrients/data-resolution.md)
- **N.** Daily summary entity → [m6-intelligence/daily-summary.md](m6-intelligence/daily-summary.md)
- **O.** HealthKit → [m5-integrations/healthkit.md](m5-integrations/healthkit.md)
- **P.** Added sugar → [m1-nutrients/added-sugar.md](m1-nutrients/added-sugar.md)
- **Q.** Cheat meal streak → [m4-longevity/streaks.md](m4-longevity/streaks.md)
- **R.** Pattern auto-logging → [m2-home-ux/patterns.md](m2-home-ux/patterns.md)
- **S.** DEXA scan → [m3-stats/dexa.md](m3-stats/dexa.md)
- **T.** Biological age → [m3-stats/bio-age.md](m3-stats/bio-age.md)
- **U.** Longevity insights → [m5-integrations/longevity-insights.md](m5-integrations/longevity-insights.md)
- **V.** Net carbs + GI/GL → [m6-intelligence/glycemic.md](m6-intelligence/glycemic.md)
- **W.** Condensed Home → [m2-home-ux/condensed-layout.md](m2-home-ux/condensed-layout.md)
- **X.** Weekly review → [m6-intelligence/weekly-review.md](m6-intelligence/weekly-review.md)
- **Y.** Lock Screen widget → [m5-integrations/widget.md](m5-integrations/widget.md)

### Competitive Edge Features (unique to Ayu)
- Food-to-Feeling Engine → [m3-stats/food-to-feeling.md](m3-stats/food-to-feeling.md)
- Bristol Stool Scale → [m3-stats/bristol-stool.md](m3-stats/bristol-stool.md)
- NSDR/Meditation Timer → [m4-longevity/nsdr.md](m4-longevity/nsdr.md)
- HRV-Meal Correlation → [m5-integrations/hrv-correlation.md](m5-integrations/hrv-correlation.md)
- Bioavailability Engine → [m7-smart-nutrition/](m7-smart-nutrition/)
- Cross-Agent Observation Engine → `lib/core/services/observation_agent.dart`
- On-Device Vision OCR → `ios/Runner/AppDelegate.swift`
- Health Condition Awareness → `lib/core/services/health_condition_service.dart`

## Dependencies
```yaml
objectbox: ^4.0.1
objectbox_flutter_libs: ^4.0.1
fl_chart: ^0.69.0
health: ^13.3.1
home_widget: ^0.7.0
mobile_scanner: ^7.0.0
flutter_local_notifications: ^21.0.0
```

## Sources
- [Longevity Coach](https://github.com/longevitycoach)
- [BioAge](https://github.com/dayoonkwon/BioAge)
- [awesome-biomarkers](https://github.com/markwk/awesome-biomarkers)
- [Longevity Supplement Selector](https://github.com/bhoffman1/LongevitySupplementSelector)
