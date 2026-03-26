# Feature F -- Supplements (Barcode Auto-Detect + Manual)

## What

Track a personal supplement stack with daily take/skip logging. Automatically detect supplement products when scanning barcodes via Open Food Facts category keywords.

## Why

Longevity protocols (Bryan Johnson Blueprint, Huberman, Attia) revolve around consistent supplement stacks. Currently the app treats supplement barcodes like food -- there is no way to build a stack or track daily adherence.

## How

### Barcode Auto-Detect

New file `lib/features/supplements/services/supplement_detector.dart`:
- When a barcode scan returns an OFF product, check `product.categories` for supplement keywords: "supplement", "vitamin", "mineral", "capsule", "tablet", "softgel", "probiotic", "fish oil", "omega", "collagen", "protein powder"
- If detected, show prompt: "This looks like a supplement. Add to your stack?" instead of the meal logging flow
- Extract name, serving size, and nutrient data from the OFF product

### Manual Entry

- User can manually add any supplement with: name, dosage, unit (mg/mcg/IU/g/drops), category, frequency
- Predefined stack templates: NMN/NR, D3, K2, B complex, omega-3, magnesium, zinc, creatine, CoQ10, probiotics, ashwagandha, curcumin, collagen

### Daily Checklist

- Home "Today's Progress" card shows: "Supps 6/10" with progress bar
- Tap to expand full checklist with take/skip per supplement
- Stats page shows adherence history (7-day, 30-day)

## New Files / Collections

### ObjectBox Collections

- `Supplement` -- id, name, dosage, unit, category, isActive, sourceBarcode?
- `SupplementLog` -- id, supplementId, dateTime, taken (bool)

### New Files

- `lib/features/supplements/data/dbo/supplement_dbo.dart`
- `lib/features/supplements/data/dbo/supplement_log_dbo.dart`
- `lib/features/supplements/data/data_source/supplement_data_source.dart`
- `lib/features/supplements/bloc/supplement_bloc.dart`
- `lib/features/supplements/bloc/supplement_event.dart`
- `lib/features/supplements/bloc/supplement_state.dart`
- `lib/features/supplements/services/supplement_detector.dart`
- `lib/features/supplements/presentation/widgets/supplement_checklist_widget.dart`
- `lib/features/supplements/presentation/widgets/supplement_manage_dialog.dart`
- `lib/features/supplements/presentation/widgets/supplement_stats_card.dart`

## Modified Files

- `lib/features/food_data/` -- barcode scan flow: check supplement_detector before routing to meal logging
- Home page BLoC -- include supplement completion count in Today's Progress
- Stats page -- add supplement adherence card

## Checkpoint

- Scan a supplement barcode (e.g., vitamin D bottle) -> prompted to add to stack instead of logging as meal
- Manually add supplements to stack
- Daily checklist shows on Home, tracks take/skip
- Stats card shows 7-day adherence percentage
