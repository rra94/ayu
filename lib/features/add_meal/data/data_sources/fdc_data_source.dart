import 'dart:convert';

import 'package:logging/logging.dart';

import 'package:http/http.dart' as http;
import 'package:opennutritracker/core/utils/env.dart';
import 'package:opennutritracker/features/add_meal/data/dto/fdc/fdc_const.dart';
import 'package:opennutritracker/features/add_meal/data/dto/fdc/fdc_word_response_dto.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class FDCDataSource {
  static const _timeoutDuration = Duration(seconds: 10);
  final log = Logger('FDCDataSource');

  Future<FDCWordResponseDTO> fetchSearchWordResults(String searchString) async {
    final searchUrlString =
        FDCConst.getFDCWordSearchUrl(searchString, Env.fdcApiKey);
    return _fetchWithRetry(searchUrlString, 'FDC word search');
  }

  /// Search FDC Branded database by UPC/GTIN barcode
  Future<FDCWordResponseDTO> fetchBarcodeResults(String barcode) async {
    final searchUrl =
        FDCConst.getFDCBarcodeSearchUrl(barcode, Env.fdcApiKey);
    return _fetchWithRetry(searchUrl, 'FDC barcode search');
  }

  Future<FDCWordResponseDTO> _fetchWithRetry(Uri url, String label, {int maxRetries = 2}) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.get(url).timeout(_timeoutDuration);
        log.fine('$label response: ${response.statusCode}');
        return FDCWordResponseDTO.fromJson(jsonDecode(response.body));
      } catch (exception, stacktrace) {
        if (attempt == maxRetries) {
          log.severe('$label failed after ${attempt + 1} attempts: $exception');
          Sentry.captureException(exception, stackTrace: stacktrace);
          return Future.error(exception);
        }
        log.info('$label attempt ${attempt + 1} failed, retrying...');
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
    return Future.error(Exception('$label: max retries exceeded'));
  }
}
