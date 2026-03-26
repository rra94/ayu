# Feature S -- Nutritionix API (with Aggressive Caching)

## What
Third food data source for restaurant and chain foods via the Nutritionix API.

## Why
FDC and OFF have poor coverage of restaurant/chain foods. Nutritionix fills this gap but has a strict 50 calls/day free tier limit, requiring aggressive caching.

## How

**API endpoints:**
- `/v2/search/instant` -- search
- `/v2/natural/nutrients` -- detailed nutrient data

**API key:** stored in Settings via secure storage.

**Caching strategy (critical -- avoid burning 50 calls/day):**
1. Cache every Nutritionix API response in ObjectBox (query string to full result).
2. Same search query returns cached result; never hits network again.
3. Cache food detail by ID -- once fetched, permanent local copy.
4. Nutritionix is a **user-triggered fallback only** -- do not auto-search Nutritionix alongside FDC/OFF.
5. UI: show "Search Nutritionix" button at the bottom of FDC/OFF results (explicit opt-in).
6. Display remaining API calls in Settings: "Nutritionix: 42/50 calls remaining today".

## New files
- `lib/features/food_data/data/data_sources/nutritionix_data_source.dart` -- API client with caching
- ObjectBox collection for Nutritionix cache (query string, response JSON, timestamp)

## Modified files
- Food search UI -- add "Search Nutritionix" button below FDC/OFF results
- Settings screen -- API key input, remaining calls display
- `nutrient_resolver.dart` -- integrate Nutritionix in priority chain

## Checkpoint
Searching Nutritionix returns restaurant food data. Repeated searches hit cache. Remaining API call count displays in Settings.
