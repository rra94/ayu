import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/services/receipt_parser_service.dart';

void main() {
  group('ReceiptParserService', () {
    test('empty text returns empty list', () {
      expect(ReceiptParserService.parseText(''), isEmpty);
    });

    test('parses items with prices', () {
      final text = '''
ORGANIC BANANAS     1.29
WHOLE MILK 1GAL     4.99
CHICKEN BREAST      8.49
''';
      final items = ReceiptParserService.parseText(text);
      expect(items.length, 3);
      expect(items[0].name, contains('ORGANIC BANANAS'));
      expect(items[0].price, 1.29);
      expect(items[2].price, 8.49);
    });

    test('filters out header/footer lines', () {
      final text = '''
COSTCO WHOLESALE
Store #123
01/15/2026
ORGANIC BANANAS     1.29
SUBTOTAL            1.29
TAX                 0.10
TOTAL               1.39
VISA ****1234
THANK YOU FOR SHOPPING
''';
      final items = ReceiptParserService.parseText(text);
      expect(items.length, 1);
      expect(items[0].name, contains('ORGANIC BANANAS'));
    });

    test('filters out non-food items', () {
      final text = '''
TRASH BAGS LG       5.99
PAPER TOWELS        8.99
ORGANIC EGGS        6.49
CLEANING SPRAY      4.29
''';
      final items = ReceiptParserService.parseText(text);
      expect(items.length, 1);
      expect(items[0].name, contains('ORGANIC EGGS'));
    });

    test('handles lines without prices', () {
      final text = '''
Some random text
Another line
''';
      final items = ReceiptParserService.parseText(text);
      expect(items, isEmpty);
    });

    test('handles various price formats', () {
      final text = 'ALMOND MILK 64OZ  3.99\nGREEK YOGURT  4.49\n';
      final items = ReceiptParserService.parseText(text);
      expect(items.length, greaterThanOrEqualTo(1));
    });
  });
}
