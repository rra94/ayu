# Feature Z -- iOS Lock Screen Widget

## What

Native iOS WidgetKit widgets showing key daily metrics (calories, water, supplements, fasting) on the iPhone Lock Screen and Home Screen.

## Why

Glanceable health data without opening the app increases engagement and awareness. Lock Screen widgets are the highest-visibility real estate on iOS -- users see them dozens of times per day.

## How

### Architecture

- iOS WidgetKit extension in `ios/NutriWidget/` (SwiftUI, required by Apple)
- Flutter side uses `home_widget: ^0.7.0` to push data from Dart to the widget extension
- Data is serialized to UserDefaults (App Group shared container) by Flutter, read by SwiftUI
- Widget refreshes when: app updates data, system timeline refresh (every 15-30 min)

### Widget Variants

| Size | Content |
|------|---------|
| Small (circular) | Calories remaining as circular gauge (e.g., "820 left") |
| Medium (rectangular) | Calories + water progress + supplement count (e.g., "1,430/2,250 kcal | 1.5/2.5L | 6/10 supps") |
| Large | Calories + macro breakdown + water + fasting timer countdown |

### Data Flow

1. When user logs intake/water/supplements, Flutter app calls `HomeWidget.saveWidgetData()` with updated values
2. Data keys: `calories_consumed`, `calories_target`, `water_ml`, `water_target`, `supps_taken`, `supps_total`, `fasting_active`, `fasting_elapsed_min`, `fasting_target_min`
3. SwiftUI widget reads from shared UserDefaults and renders
4. Call `HomeWidget.updateWidget()` to trigger re-render

### SwiftUI Widget Code

- `NutriWidget.swift` -- entry point, timeline provider
- `NutriWidgetSmall.swift` -- circular calorie gauge
- `NutriWidgetMedium.swift` -- multi-metric row
- `NutriWidgetLarge.swift` -- full dashboard

### Configuration

- User selects widget size when adding to Lock Screen / Home Screen (standard iOS flow)
- No in-app widget configuration needed (widgets show the same data the app tracks)

## New Files / Collections

### New Files (Flutter side)

- `lib/core/services/widget_service.dart` -- pushes data to widget via home_widget
- Widget data update calls in relevant BLoCs (intake, water, supplements, fasting)

### New Files (iOS side)

- `ios/NutriWidget/NutriWidget.swift`
- `ios/NutriWidget/NutriWidgetSmall.swift`
- `ios/NutriWidget/NutriWidgetMedium.swift`
- `ios/NutriWidget/NutriWidgetLarge.swift`
- `ios/NutriWidget/Assets.xcassets/`
- `ios/NutriWidget/Info.plist`

### No New Collections

Reads aggregated data from existing collections via widget_service.dart.

## Modified Files

- `pubspec.yaml` -- add `home_widget: ^0.7.0`
- `ios/Runner.xcodeproj` -- add NutriWidget target and App Group
- `ios/Runner/Runner.entitlements` -- add App Group entitlement
- Intake BLoC, Water BLoC, Supplement BLoC, Fasting BLoC -- call `WidgetService.update()` after state changes

## Checkpoint

- Add small widget to iPhone Lock Screen -- shows calories remaining as circular gauge
- Log a meal in the app -- widget updates within seconds
- Add medium widget to Home Screen -- shows calories + water + supplements
- Fasting timer countdown visible on large widget
