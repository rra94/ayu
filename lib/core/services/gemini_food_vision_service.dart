import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/utils/env.dart';
import 'package:opennutritracker/features/add_meal/domain/entity/meal_entity.dart';

class FoodPhotoResult {
  final String? dishName;
  final List<FoodPhotoItem> items;
  final double totalKcal;

  FoodPhotoResult({this.dishName, required this.items, required this.totalKcal});
}

class FoodPhotoItem {
  final String name;
  final double grams;
  double kcal;
  double protein;
  double fat;
  double carbs;
  bool selected;
  MealEntity? matchedMeal; // verified database match
  String source; // 'common_db', 'government_db', 'calorie_ninja', 'off', 'gemini_estimate'

  FoodPhotoItem({
    required this.name,
    required this.grams,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.selected = true,
    this.matchedMeal,
    this.source = 'gemini_estimate',
  });

  bool get isVerified => source != 'gemini_estimate';
}

class GeminiFoodVisionService {
  static final _log = Logger('GeminiFoodVisionService');

  /// Analyze a food photo using Gemini Vision API.
  /// Returns identified food items with estimated nutrition.
  static Future<FoodPhotoResult?> analyzePhoto(String imagePath) async {
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
      );

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''Identify all food items in this image with estimated portion size in grams.
Return ONLY valid JSON (no markdown, no code blocks):
{
  "dish": "dish name or null",
  "items": [
    {"name": "grilled chicken breast", "grams": 150},
    {"name": "steamed broccoli", "grams": 80}
  ]
}
If this is not a food photo, return: {"error": "not_food"}'''
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                }
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
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': Env.geminiApiKey,
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        _log.warning('Gemini returned ${response.statusCode}: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text']
          as String?;
      if (text == null) return null;

      // Clean response -- strip markdown code blocks if present
      var cleaned = text.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned
            .replaceAll(RegExp(r'^```\w*\n?'), '')
            .replaceAll(RegExp(r'\n?```$'), '')
            .trim();
      }

      final result = jsonDecode(cleaned);

      if (result['error'] != null) {
        _log.info('Not a food photo: ${result['error']}');
        return null;
      }

      final items = (result['items'] as List).map((item) {
        return FoodPhotoItem(
          name: item['name'] as String? ?? 'Unknown',
          grams: (item['grams'] as num?)?.toDouble() ?? 100,
          kcal: 0,
          protein: 0,
          fat: 0,
          carbs: 0,
          source: 'gemini_estimate',
        );
      }).toList();

      return FoodPhotoResult(
        dishName: result['dish'] as String?,
        items: items,
        totalKcal: 0,
      );
    } catch (e) {
      _log.severe('Gemini Vision failed: $e');
      return null;
    }
  }
}
