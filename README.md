<p align="center">
  <img alt="Ayu Logo" src="assets/icon/ayu_logo.png" width="128" />
  <h1 align="center">Ayu</h1>
  <p align="center"><em>आयु — Sanskrit for "life / longevity"</em></p>
</p>

<p align="center">
  <a href="https://opensource.org/licenses/GPL-3.0"><img src="https://img.shields.io/badge/license-GPLv3-blue" /></a>
  <a href="https://github.com/rra94/ayu/stargazers"><img src="https://img.shields.io/github/stars/rra94/ayu.svg" /></a>
  <a href="https://github.com/rra94/ayu/issues"><img src="https://img.shields.io/github/issues/rra94/ayu.svg" /></a>
</p>

## What is Ayu?

Ayu is a comprehensive **nutrition and longevity tracker** for iOS. It goes beyond calorie counting — tracking micronutrients, biomarkers, sleep, fasting, gut health, supplements, and more — all designed around evidence-based longevity protocols.

Built on top of [OpenNutriTracker](https://github.com/simonoppowa/OpenNutriTracker) (GPLv3).

## Features

### Nutrition
- Barcode scanning with OFF + USDA FDC fallback
- 23 vitamins & minerals with RDA% progress bars
- Added sugar tracking
- Glycemic load estimation (~200 food GI database)
- Net carbs (total carbs - fiber)
- Per-serving nutrient display
- Food allergen alerts (user-configured allergens)
- Custom food entry for items not in database

### Home Dashboard
- Water tracking with daily goal
- Daily habits checklist with smart time-based reminders
- Gut health panel — auto-detects 64 harmful additives from OFF E-numbers
- Today View card (calories, water, supplements, sleep, streak at a glance)
- Quick action bar (water +250ml, scan, coffee, fast)
- Supplement checklist with take/skip logging
- Fasting timer (16:8, 18:6, 20:4, OMAD presets)
- NSDR / meditation countdown timer
- Caffeine tracking

### Stats Tab
- TDEE/BMR with thermic effect of food (auto from macros)
- Weight tracker with fl_chart, target line, and ETA
- 25 biomarkers with normal + longevity-optimal ranges (red/yellow/green)
- 8 wellness biomarkers (hair, skin, teeth, nails, energy, sleep quality, stress, Norwood scale)
- Biological age (Levine 2018 Phenotypic Age from 9 blood markers)
- Longevity Score (0-100 composite)
- Food-to-Feeling correlation engine (symptom -> trigger food analysis)
- Bristol Stool Scale logger with 30-day distribution
- DEXA body composition manual entry
- Meal timing 24h clock with eating window visualization
- Cheat meal streak tracker
- Weekly review digest (wins, improvements, week-over-week trends)
- Grocery/pantry tracking with receipt scanning

### Longevity Suite
- Supplement stack with daily adherence tracking
- Intermittent fasting timer with circular countdown + auto-start/stop
- Sleep logging (bedtime, wake, quality 1-5) with 7-day trends
- Meal timing analysis
- Clean eating streak calculator

### Integrations
- Apple HealthKit sync (weight, sleep, HR, HRV, steps, workouts)
- HRV vs. late-meal correlation analysis
- Longevity insights engine (biomarker-based recommendations)
- iOS WidgetKit data bridge (Lock Screen + Home Screen widgets)

### Intelligence
- 7 on-device agents: meal pattern, nutrient gap, fasting adapt, supplement, hydration, biomarker, cross-domain observation
- Cross-agent observation engine (stress+HR contradiction, sleep+caffeine, mood+nutrition, sleep+eating window, weather+mood)
- Smart notifications for missing entries (meals, water, supplements, sleep)
- Auto-start fasting after meal logging gap
- DailySummaryEntity — aggregates all daily data
- Weekly review service with automated wins/improvements detection

### Smart Nutrition
- **Bioavailability engine** — estimates real absorption for 10+ nutrients based on meal context
  - Iron: 2-35% depending on heme vs non-heme, vitamin C, calcium, phytates
  - Calcium: 5-40% (kale 49% bioavailable vs spinach 5% due to oxalates)
  - Fat-soluble vitamins (A, D, E, K): 10-90% based on dietary fat in meal
  - Shows enhancers/inhibitors detected in your meals
- **Food recommendations** — suggests specific foods to fill micronutrient gaps
  - Shows both raw content AND bioavailable amount
  - Gender/age-aware RDA targets, ranked by lowest %RDA
  - Absorption tips (e.g., "Pair with vitamin C to boost iron 2-6x")
- Research-backed: WHO/FAO 2001, Hurrell & Egli 2010, Weaver 1999, Schuchardt 2017

### On-Device Vision
- Apple Vision OCR for receipt scanning (no cloud, no API key)
- Auto-classifies grocery items from receipts (produce, protein, dairy, etc.)
- Supplement auto-detection from barcode scans

### Health Awareness
- 16 health conditions with nutrient rules (including cosmetic: acne, dental, eczema, hair loss)
- Configurable during onboarding and updateable in settings
- Condition-specific nutrient increase/avoid recommendations

## Tech Stack

```
Flutter (iOS only — Android deprecated)
ObjectBox (local DB, 23 entities)
BLoC (state management)
fl_chart (charts)
health (HealthKit)
flutter_local_notifications
home_widget (WidgetKit bridge)
Apple Vision framework (on-device OCR)
```

> **Note:** Android support is deprecated. Ayu is developed and tested exclusively for iOS.

## Data Sources

- [Open Food Facts](https://world.openfoodfacts.org/) — barcode + product search
- [USDA FDC](https://fdc.nal.usda.gov/) — branded food fallback for barcodes
- [University of Sydney GI Database](https://glycemicindex.com/) — glycemic index values
- WHO/FAO mineral bioavailability data (2001) — absorption rate calculations
- Peer-reviewed nutrient interaction research — enhancer/inhibitor rules

## Privacy

- All data stored locally on device (ObjectBox)
- HealthKit data never leaves the device
- On-device OCR (Apple Vision, no cloud)
- No cloud dependency, no accounts, no tracking
- Open source

## Getting Started

```bash
flutter pub get
cd ios && pod install && cd ..
dart run build_runner build --delete-conflicting-outputs
flutter run
```

See [GettingStarted.md](GettingStarted.md) for detailed setup.

## Disclaimer

Ayu is not a medical application. All data provided is not validated and should be used with caution. Consult a healthcare professional before making health decisions. Use during illness, pregnancy, or lactation is not recommended.

## Acknowledgments

- Originally forked from [OpenNutriTracker](https://github.com/simonoppowa/OpenNutriTracker) by Simon Oppowa
- Longevity protocols informed by research from Peter Attia, Bryan Johnson (Blueprint), Andrew Huberman
- Biomarker optimal ranges from [Longevity Coach](https://github.com/longevitycoach) methodology
- Biological age calculation based on [Levine 2018](https://pubmed.ncbi.nlm.nih.gov/29676998/)
- Bioavailability data from [Hurrell & Egli 2010](https://pubmed.ncbi.nlm.nih.gov/20200264/), [Weaver 1999](https://pubmed.ncbi.nlm.nih.gov/10193899/), [Schuchardt & Hahn 2017](https://pubmed.ncbi.nlm.nih.gov/28587022/)

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.
