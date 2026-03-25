import 'package:logging/logging.dart';

class ReceiptItem {
  final String name;
  final double? price;
  final int? quantity;
  final double? estimatedCalories;
  final String? category; // food, drink, supplement, non_food

  ReceiptItem({
    required this.name,
    this.price,
    this.quantity,
    this.estimatedCalories,
    this.category,
  });
}

class ReceiptParserService {
  static final _log = Logger('ReceiptParserService');

  /// Parse raw OCR text from a receipt into food items.
  /// Step 1: regex-based extraction. Step 2: Gemini fallback.
  static List<ReceiptItem> parseText(String rawText) {
    final items = <ReceiptItem>[];
    final lines = rawText.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.length < 3) continue;

      // Skip header/footer lines
      if (_isHeaderFooter(trimmed)) continue;

      // Try to extract item + price
      final match = _itemPricePattern.firstMatch(trimmed);
      if (match != null) {
        final name = match.group(1)?.trim() ?? trimmed;
        final priceStr = match.group(2);
        final price = priceStr != null ? double.tryParse(priceStr) : null;

        if (name.length >= 3 && !_isNonFoodKeyword(name)) {
          items.add(ReceiptItem(
            name: _cleanItemName(name),
            price: price,
            quantity: 1,
          ));
        }
      }
    }

    return items;
  }

  // ── Regex patterns ──

  static final _itemPricePattern = RegExp(
    r'^(.+?)\s+\$?(\d+\.\d{2})\s*[A-Z]?\s*$',
  );

  static bool _isHeaderFooter(String line) {
    final lower = line.toLowerCase();
    return lower.contains('thank you') ||
        lower.contains('total') ||
        lower.contains('subtotal') ||
        lower.contains('tax') ||
        lower.contains('change') ||
        lower.contains('visa') ||
        lower.contains('mastercard') ||
        lower.contains('debit') ||
        lower.contains('credit') ||
        lower.contains('cashier') ||
        lower.contains('store #') ||
        lower.contains('receipt') ||
        lower.contains('member') ||
        RegExp(r'^\d{2}/\d{2}/\d{2,4}').hasMatch(line) || // dates
        RegExp(r'^\d{10,}$').hasMatch(line.replaceAll(' ', '')); // barcodes
  }

  static bool _isNonFoodKeyword(String name) {
    final lower = name.toLowerCase();
    return lower.contains('bag') ||
        lower.contains('coupon') ||
        lower.contains('discount') ||
        lower.contains('return') ||
        lower.contains('deposit') ||
        lower.contains('crv') ||
        lower.contains('cleaning') ||
        lower.contains('paper') ||
        lower.contains('trash') ||
        lower.contains('tissue');
  }

  static String _cleanItemName(String name) {
    // Remove common receipt abbreviations and codes
    return name
        .replaceAll(RegExp(r'\b[A-Z]{2,3}\b$'), '') // trailing codes like "F" "T"
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
