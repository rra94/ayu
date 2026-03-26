# Feature X -- Condensed Home Page Layout

## What
Redesign the Home page from 10+ scrollable panels into 4 clean, condensed sections.

## Why
The current Home page has too many separate panels. Users scroll past content instead of absorbing it. A condensed layout surfaces everything at a glance.

## How

**Layout:**
```
+-------------------------+
|   Dashboard (calories)  |  <- always visible
|   ooo carbs fat protein |
+-------------------------+
| [+Meal] [+Water] [+Supp]|  <- Quick Actions bar
+-------------------------+
| Pattern suggestion       |  <- dismissible, only when relevant
+-------------------------+
| Today's Progress         |  <- condensed card
| Water ----___  1.5/2.5L |
| Habits ------_ 8/12     |
| Supps  ----___ 6/10     |
| Fasting 14h / 16h       |
+-------------------------+
| Breakfast  >  320kcal   |  <- collapsible meal sections
| Lunch      >            |
| Dinner     >            |
| Snack      >            |
+-------------------------+
| Gut Health (2 alerts)   |  <- only shows if alerts exist
+-------------------------+
```

**Key UX decisions:**
- "Today's Progress" combines water + habits + supplements + fasting into ONE compact card with progress bars
- Meal sections are collapsed by default (tap to expand, shows food cards)
- Pattern suggestion is dismissible and only appears when relevant (not every time)
- Gut health alerts only show when there are flags (not an empty panel)
- Quick Actions bar provides one-tap access to most common actions
- Favorites accessible via long-press on Quick Actions [+Meal] button

## New files
- Home page layout widgets for each section (progress card, quick actions bar, collapsible meal sections)

## Modified files
- `lib/features/diary/presentation/` (or equivalent Home page files) -- replace current layout
- Config collection -- add `homePageSettings` for which sub-items to show in Today's Progress card
- Settings screen -- add "Customize Home" option

## Checkpoint
Home page renders the condensed layout. Quick Actions work. Meal sections collapse/expand. Today's Progress card shows combined progress bars.
