# Feature I -- Quick-Add Favorites

## What
One-tap logging of favorite meals from the Home page.

## Why
Users eat the same meals repeatedly. Removing friction for common foods increases logging consistency -- the single biggest factor in nutrition tracking success.

## How

- Horizontal scroll of favorite cards above the Dashboard on Home
- Tap a card to instantly log that meal with default amount/unit/intake type
- Star icon in meal detail view to add a food to favorites

## New files/collections
- **ObjectBox collection:** `FavoriteMeal` (mealData, defaultAmount, defaultUnit, defaultIntakeType)
- `lib/features/favorites/` -- BLoC, repository, UI widgets (horizontal card list, star toggle)

## Modified files
- Home page -- add horizontal favorites scroll above Dashboard
- Meal detail screen -- add star/favorite toggle icon
- Quick Actions bar -- long-press on [+Meal] opens favorites list

## Checkpoint
Starring a food adds it to favorites. Favorites appear as horizontal cards on Home. Tapping a card instantly logs the meal.
