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

---

**Ayu** is a privacy-first **nutrition and longevity tracker** for iOS. It goes beyond calorie counting — tracking micronutrients, biomarkers, sleep, fasting, gut health, supplements, peptides, and more — all powered by on-device intelligence with zero cloud dependency.

Originally forked from [OpenNutriTracker](https://github.com/simonoppowa/OpenNutriTracker) (GPLv3).

---

## Features

### Food & Nutrition
- Barcode scanning via Open Food Facts + USDA FDC fallback
- 23 vitamins & minerals with RDA% progress bars
- Glycemic load estimation, net carbs, added sugar tracking
- Nutrient synergy checker (17 evidence-based rules per meal)
- Bioavailability engine — estimates real absorption based on meal context
- Smart food recommendations to fill micronutrient gaps
- Food allergen alerts (user-configured, persisted)
- Custom food entry for items not in database
- 30 Plants a Week tracker for gut microbiome diversity

### Daily Dashboard
- Today View — calories, water, supplements, sleep, streak at a glance
- Activity Dashboard — steps, activity type, calories, outdoor time + gym visits, workouts, avg HR
- Quick actions — water +250ml, scan barcode, log coffee, start fast
- Gut health panel — auto-detects 64 harmful additives from E-numbers
- Daily habits checklist with time-based reminders
- Caffeine tracking

### Supplements & Peptides
- Supplement stack with daily take/skip logging
- Peptide tracker — dosing cycles, reconstitution calculator, injection site rotation with body map
- Blueprint Mode — Bryan Johnson's longevity protocol targets

### Body & Biomarkers
- 25 biomarkers with normal + longevity-optimal ranges
- 8 wellness biomarkers (hair, skin, teeth, nails, energy, sleep, stress, Norwood scale)
- Biological age (Levine 2018 Phenotypic Age from 9 blood markers)
- Longevity Score (0-100 composite)
- DEXA body composition, weight trends with ETA
- Bristol Stool Scale with 30-day distribution
- Food-to-Feeling correlation (symptom to trigger food analysis)
- 16 health conditions with nutrient rules (including cosmetic: acne, hair loss, eczema)

### Timers & Streaks
- Intermittent fasting (16:8, 18:6, 20:4, OMAD) with auto-start/stop
- NSDR / meditation countdown timer
- Sleep logging (bedtime, wake, quality 1-5) with trends
- Clean eating streak calculator
- Meal timing analysis with eating window visualization

### Phone Sensors
- CoreMotion — activity detection, sedentary alerts after 3+ hours
- CoreLocation — gym detection via significant location changes, outdoor time estimation
- Barometer — pressure tracking for weather-mood correlation
- Data auto-pruned (90 days snapshots, 30 days locations)

### On-Device Intelligence
- **11 agents** running locally: meal pattern, nutrient gap, fasting adapt, supplement reminder, hydration, biomarker staleness, sedentary, gym frequency, outdoor time, peptide reminder
- **Cross-agent observations**: stress+HR contradiction, sleep+caffeine, mood+nutrition, sleep+eating window, pressure+mood, sedentary+sleep, gym+protein
- Smart notifications for missing entries
- Weekly review with automated wins/improvements

### Integrations
- Apple HealthKit (weight, sleep, HR, HRV, steps, workouts)
- iOS Lock Screen + Home Screen widgets (calories, water, supplements, streak)
- Apple Vision OCR for receipt scanning (grocery classification)
- Supplement auto-detection from barcode scans

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (iOS only) |
| Database | ObjectBox (29 entities, all local) |
| State | BLoC |
| Charts | fl_chart |
| Health | Apple HealthKit via `health` package |
| Notifications | flutter_local_notifications |
| Widgets | WidgetKit via `home_widget` |
| Vision | Apple Vision framework (on-device OCR) |
| Sensors | CoreMotion, CoreLocation, CMAltimeter |

## Data Sources

| Source | Used For |
|--------|----------|
| [Open Food Facts](https://world.openfoodfacts.org/) | Barcode + product search |
| [USDA FDC](https://fdc.nal.usda.gov/) | Branded food fallback |
| [University of Sydney GI Database](https://glycemicindex.com/) | Glycemic index values |
| WHO/FAO 2001 | Mineral bioavailability rates |
| Peer-reviewed research | Nutrient interaction rules |

## Privacy

All computation happens on your device. Nothing leaves your phone.

- ObjectBox local database — no cloud sync
- HealthKit data stays on device
- Location data never exported (auto-pruned after 30 days)
- OCR processed locally via Apple Vision
- No accounts, no analytics, no tracking
- Open source (GPLv3)

## Getting Started

```bash
flutter pub get
cd ios && pod install && cd ..
dart run build_runner build --delete-conflicting-outputs
flutter run
```

See [GettingStarted.md](GettingStarted.md) for detailed setup.

## Disclaimer

Ayu is not a medical application. All data provided is not validated and should be used with caution. Consult a healthcare professional before making health decisions.

## Acknowledgments

- [OpenNutriTracker](https://github.com/simonoppowa/OpenNutriTracker) by Simon Oppowa — original foundation
- Longevity protocols: Peter Attia, Bryan Johnson (Blueprint), Andrew Huberman
- Biomarker ranges: [Longevity Coach](https://github.com/longevitycoach)
- Biological age: [Levine 2018](https://pubmed.ncbi.nlm.nih.gov/29676998/)
- Bioavailability: [Hurrell & Egli 2010](https://pubmed.ncbi.nlm.nih.gov/20200264/), [Weaver 1999](https://pubmed.ncbi.nlm.nih.gov/10193899/), [Schuchardt & Hahn 2017](https://pubmed.ncbi.nlm.nih.gov/28587022/)

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE).
