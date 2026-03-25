import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// On-device OCR using Apple Vision framework.
/// Zero cloud dependency. Image never leaves the device.
class VisionOCRService {
  static const _channel = MethodChannel('com.rra94.ayu/vision_ocr');
  static final _log = Logger('VisionOCRService');

  /// Recognize text from an image file path.
  /// Returns extracted text or null if recognition fails.
  static Future<String?> recognizeText(String imagePath) async {
    try {
      final result = await _channel.invokeMethod<String>(
        'recognizeText',
        {'imagePath': imagePath},
      );
      _log.info('Vision OCR extracted ${result?.length ?? 0} characters');
      return result;
    } on PlatformException catch (e) {
      _log.warning('Vision OCR failed: ${e.message}');
      return null;
    }
  }
}
