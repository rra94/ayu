import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/utils/env.dart';

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

  // ── Regex patterns ──

  /// Primary pattern: item followed by price (e.g. "Chicken Breast  4.99")
  static final _itemPricePattern = RegExp(
    r'^(.+?)\s+\$?(\d+\.\d{2})\s*[A-Z]?\s*$',
  );

  /// Pattern 2: quantity prefix (e.g. "2x Chicken Breast" or "2X Coca Cola 3.99")
  static final _qtyItemPattern = RegExp(
    r'^(\d+)\s*[xX]\s*(.+?)(?:\s+\$?(\d+\.\d{2}))?\s*$',
  );

  /// Pattern 3: plain capitalized food name with no price (restaurant receipts)
  static final _plainItemPattern = RegExp(
    r"^([A-Z][A-Za-z\s&\-']+)$",
  );

  // ── State ──

  static String? _lastDetectedRestaurant;

  /// Get the restaurant name detected during the last smart parse.
  static String? get lastDetectedRestaurant => _lastDetectedRestaurant;

  // ── Public API ──

  /// Smart receipt parsing using Gemini AI.
  /// Falls back to regex parsing if Gemini fails or is unavailable.
  static Future<List<ReceiptItem>> parseTextSmart(String rawText) async {
    // Reset restaurant each call
    _lastDetectedRestaurant = null;

    // Try Gemini first for intelligent parsing
    try {
      final items = await _geminiParse(rawText);
      if (items.isNotEmpty) return items;
    } catch (e) {
      _log.warning('Gemini parse failed, falling back to regex: $e');
    }

    // Fallback to regex parsing
    return parseText(rawText);
  }

  /// Parse raw OCR text from a receipt into food items using regex.
  /// Step 1: regex-based extraction. Step 2: Gemini fallback (see parseTextSmart).
  static List<ReceiptItem> parseText(String rawText) {
    final items = <ReceiptItem>[];
    final lines = rawText.split('\n');

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.length < 3) continue;

      // Skip header/footer lines
      if (_isHeaderFooter(trimmed)) continue;

      // Pattern 1: item + price
      final match1 = _itemPricePattern.firstMatch(trimmed);
      if (match1 != null) {
        final name = match1.group(1)?.trim() ?? trimmed;
        final priceStr = match1.group(2);
        final price = priceStr != null ? double.tryParse(priceStr) : null;

        if (name.length >= 3 && !_isNonFoodKeyword(name)) {
          items.add(ReceiptItem(
            name: _cleanItemName(name),
            price: price,
            quantity: 1,
          ));
          continue;
        }
      }

      // Pattern 2: quantity prefix (2x item or 2X item $price)
      final match2 = _qtyItemPattern.firstMatch(trimmed);
      if (match2 != null) {
        final qty = int.tryParse(match2.group(1) ?? '1') ?? 1;
        final name = match2.group(2)?.trim() ?? '';
        final priceStr = match2.group(3);
        final price = priceStr != null ? double.tryParse(priceStr) : null;

        if (name.length >= 3 && !_isNonFoodKeyword(name)) {
          items.add(ReceiptItem(
            name: _cleanItemName(name),
            price: price,
            quantity: qty,
          ));
          continue;
        }
      }

      // Pattern 3 (plain names without prices) is intentionally NOT used in
      // regex fallback — too many false positives (store names, headers, random text).
      // Plain-name items are handled by the Gemini smart parse path instead.
    }

    return items;
  }

  // ── Gemini parsing ──

  static Future<List<ReceiptItem>> _geminiParse(String rawText) async {
    // Pre-analyze OCR text to give Gemini context
    final lines = rawText.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final lineCount = lines.length;
    final hasPrice = RegExp(r'\$?\d+\.\d{2}').hasMatch(rawText);
    final lowerText = rawText.toLowerCase();
    final looksLikeRestaurant = lowerText.contains('server') ||
        lowerText.contains('table') ||
        lowerText.contains('tip') ||
        lowerText.contains('gratuity') ||
        lowerText.contains('dine in');
    final looksLikeGrocery = lowerText.contains('grocery') ||
        lowerText.contains('supermarket') ||
        lowerText.contains('produce') ||
        lowerText.contains('organic') ||
        lowerText.contains('lb') ||
        lowerText.contains('qty');

    final receiptType = looksLikeRestaurant
        ? 'restaurant bill'
        : looksLikeGrocery
            ? 'grocery store receipt'
            : 'receipt (type unknown)';

    // First few lines often have store name
    final headerLines = lines.take(3).join(', ');

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${Env.geminiApiKey}',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text': '''You are parsing OCR text from a $receiptType.
The OCR text may have errors, abbreviations, and formatting issues.
Header lines: "$headerLines"
Total lines: $lineCount. Has prices: $hasPrice.

TASK: Extract all FOOD and DRINK items from this receipt.

Rules:
- ONLY include food/drink items — ignore tax, tips, totals, discounts, bags, non-food
- Clean up OCR errors and abbreviations:
  "CHKN BRST" → "Chicken Breast"
  "ORG BAN" → "Organic Banana"
  "VIT D MLK" → "Vitamin D Milk"
  "GRK YGRT" → "Greek Yogurt"
- For restaurant bills: identify the restaurant name from the header
- For grocery receipts: identify individual food products
- If a line has a weight (e.g., "1.5 lb"), include it in the name
- Estimate quantity from "2x", "QTY 3", or repeated items

OCR text:
"""
$rawText
"""

Return ONLY valid JSON (no markdown, no code blocks):
{
  "restaurant": "restaurant name or null",
  "type": "$receiptType",
  "items": [
    {"name": "full cleaned food name", "price": 4.99, "quantity": 1, "category": "food"}
  ]
}

Categories: food, drink, supplement, unknown
If no food items found, return: {"restaurant": null, "type": "$receiptType", "items": []}'''
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'maxOutputTokens': 2048,
      }
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      _log.warning('Gemini API returned ${response.statusCode}');
      return [];
    }

    final data = jsonDecode(response.body);
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text']
        as String?;
    if (text == null) return [];

    var cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceAll(RegExp(r'^```\w*\n?'), '')
          .replaceAll(RegExp(r'\n?```$'), '')
          .trim();
    }

    final result = jsonDecode(cleaned);
    final itemsList = result['items'] as List? ?? [];

    // Store detected restaurant name for caller
    final restaurant = result['restaurant'];
    _lastDetectedRestaurant =
        (restaurant is String && restaurant.toLowerCase() != 'null')
            ? restaurant
            : null;

    return itemsList
        .map((item) => ReceiptItem(
              name: item['name'] as String? ?? '',
              price: (item['price'] as num?)?.toDouble(),
              quantity: (item['quantity'] as num?)?.toInt() ?? 1,
              category: item['category'] as String?,
            ))
        .where((item) => item.name.isNotEmpty)
        .toList();
  }

  // ── Helpers ──

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
    const nonFood = [
      'bag', 'coupon', 'discount', 'return', 'deposit', 'crv',
      'cleaning', 'paper', 'trash', 'tissue', 'napkin', 'utensil',
      'fork', 'spoon', 'plate', 'cup', 'straw', 'lid',
      'battery', 'charger', 'soap', 'shampoo', 'toothpaste',
      'detergent', 'bleach', 'wrap', 'foil', 'sponge',
      'magazine', 'newspaper', 'card', 'gift card',
      'delivery fee', 'service fee', 'convenience fee',
    ];
    return nonFood.any((kw) => lower.contains(kw));
  }

  static String _cleanItemName(String name) {
    // Remove common receipt abbreviations and codes
    return name
        .replaceAll(RegExp(r'\b[A-Z]{2,3}\b$'), '') // trailing codes like "F" "T"
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Detect if receipt is from a restaurant (vs grocery store).
  /// Returns restaurant name if detected, null otherwise.
  static String? detectRestaurant(String rawText) {
    final lines = rawText.split('\n').map((l) => l.trim()).toList();

    // Common restaurant chains
    const chains = [
      'mcdonald', 'burger king', 'wendy', 'chick-fil-a', 'chipotle',
      'subway', 'taco bell', 'panera', 'panda express', 'five guys',
      'shake shack', 'in-n-out', 'popeyes', 'kfc', 'domino',
      'pizza hut', 'papa john', 'olive garden', 'applebee', 'chili',
      'ihop', 'denny', 'waffle house', 'starbucks', 'dunkin',
      'sweetgreen', 'cava', 'nando', 'wingstop', 'raising cane',
      'jersey mike', 'firehouse sub', 'jimmy john', 'potbelly',
      'cheesecake factory', 'outback', 'red lobster', 'buffalo wild',
      'ruth chris', 'morton', 'nobu', 'benihana',
    ];

    // Check first 5 lines for restaurant name (usually at top of receipt)
    for (final line in lines.take(5)) {
      final lower = line.toLowerCase();
      for (final chain in chains) {
        if (lower.contains(chain)) {
          return line; // Return the actual line as restaurant name
        }
      }
    }

    // Heuristics for non-chain restaurants:
    // Receipt has "server", "table", "tip", "gratuity" = likely restaurant
    final fullText = rawText.toLowerCase();
    const restaurantKeywords = [
      'server:', 'table #', 'table:', 'tip:', 'gratuity',
      'dine in', 'take out', 'takeout', 'drive thru',
    ];
    final hasRestaurantKeywords =
        restaurantKeywords.where((k) => fullText.contains(k)).length >= 2;

    if (hasRestaurantKeywords) {
      // Return first non-empty line as restaurant name (usually the business name)
      return lines.firstWhere(
        (l) => l.length > 3 && !RegExp(r'^\d').hasMatch(l),
        orElse: () => '',
      );
    }

    return null;
  }
}
