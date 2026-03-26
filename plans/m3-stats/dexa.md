# Feature T -- DEXA Scan Import

## What
Store and display DEXA body composition scan results via manual entry.

## Why
DEXA is the gold standard for body composition measurement. Tracking scans over time shows the impact of diet and exercise on lean mass, fat mass, and bone density.

## How

**Input: Manual entry dialog only.**
~~PDF parsing via regex~~ -- too brittle; clinic software formatting varies widely. If photo-based import is desired later, use Google ML Kit OCR on a photo of the report rather than raw PDF text extraction.

**Fields captured:**
- Scan date
- Total body fat percent
- Lean mass (kg)
- Fat mass (kg)
- Bone mineral density
- Visceral fat area
- T-score
- Regional breakdowns

**Display:** Body composition card on Stats. Trend chart if multiple scans are entered.

## New files/collections
- **ObjectBox collection:** `DexaScan` (scanDate, totalBodyFatPercent, leanMassKG, fatMassKG, boneMineralDensity, visceralFatArea, tScore, regional breakdowns)
- `lib/features/dexa/` -- BLoC, repository, manual entry dialog, body composition card, trend chart

## Modified files
- Stats tab -- DEXA body composition card

## Checkpoint
Manual entry dialog captures all DEXA fields. Body composition card displays on Stats. Multiple scans show a trend chart.
