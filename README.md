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

### Nutrition (M1)
- Barcode scanning with OFF + USDA FDC fallback
- 23 vitamins & minerals with RDA% progress bars
- Added sugar tracking
- Glycemic load estimation (~200 food GI database)
- Net carbs (total carbs - fiber)
- Per-serving nutrient display

### Home Dashboard (M2)
- Water tracking with daily goal
- Daily habits checklist with smart time-based reminders
- Gut health panel — auto-detects 80+ harmful additives from OFF E-numbers
- Daily summary card (calories, protein, gut health pass/fail)
- Supplement checklist with take/skip logging
- Fasting timer (16:8, 18:6, 20:4, OMAD presets)
- NSDR / meditation countdown timer

### Stats Tab (M3)
- TDEE/BMR with thermic effect of food (auto from macros)
- Weight tracker with fl_chart, target line, and ETA
- 25 biomarkers with normal + longevity-optimal ranges (red/yellow/green)
- Biological age (Levine 2018 Phenotypic Age from 9 blood markers)
- Food-to-Feeling correlation engine (symptom → trigger food analysis)
- Bristol Stool Scale logger with 30-day distribution
- DEXA body composition manual entry
- Meal timing 24h clock with eating window visualization
- Cheat meal streak tracker
- Weekly review digest (wins, improvements, week-over-week trends)

### Longevity Suite (M4)
- Supplement stack with daily adherence tracking
- Intermittent fasting timer with circular countdown
- Sleep logging (bedtime, wake, quality 1-5) with 7-day trends
- Meal timing analysis
- Clean eating streak calculator

### Integrations (M5)
- Apple HealthKit sync (weight, sleep, HR, HRV, steps)
- HRV vs. late-meal correlation analysis
- Longevity insights engine (biomarker-based recommendations)
- iOS WidgetKit data bridge (Lock Screen + Home Screen widgets)

### Intelligence (M6)
- DailySummaryEntity — aggregates all daily data (AI-ready with toJson())
- Weekly review service with automated wins/improvements detection
- Smart notifications for missing entries (meals, water, supplements, sleep)

## Tech Stack

```
Flutter (iOS only — Android deprecated)
ObjectBox (local DB)
BLoC (state management)
fl_chart (charts)
health (HealthKit)
flutter_local_notifications
home_widget (WidgetKit bridge)
```

> **Note:** Android support is deprecated. Ayu is developed and tested exclusively for iOS.

## Data Sources

- [Open Food Facts](https://world.openfoodfacts.org/) — barcode + product search
- [USDA FDC](https://fdc.nal.usda.gov/) — branded food fallback for barcodes
- [University of Sydney GI Database](https://glycemicindex.com/) — glycemic index values

## Privacy

- All data stored locally on device (ObjectBox)
- HealthKit data never leaves the device
- No cloud dependency, no accounts, no tracking
- Open source

## Getting Started

```bash
flutter pub get
flutter pub run build_runner build
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

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.
