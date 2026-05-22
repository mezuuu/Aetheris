import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/lrc_line.dart';

class TranslationService {
  TranslationService({Dio? dio}) {
    _dio = dio ?? Dio();
  }

  late final Dio _dio;
  
  // Simple in-memory cache to avoid re-translating same lines
  final Map<String, String> _cache = {};

  /// Translate a single text to the target language code (e.g., 'id', 'en')
  Future<String> translateText(String text, String targetLanguageCode) async {
    if (text.trim().isEmpty) return '';
    
    final cacheKey = '${targetLanguageCode}_$text';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    try {
      final url = 'https://translate.googleapis.com/translate_a/single';
      final response = await _dio.get(
        url,
        queryParameters: {
          'client': 'gtx',
          'sl': 'auto',
          'tl': targetLanguageCode,
          'dt': 't',
          'q': text,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // Google translate response format: [[[ "translated text", "original text", ...]]]
        final data = response.data as List;
        if (data.isNotEmpty && data[0] is List) {
          final translatedSegments = data[0] as List;
          final buffer = StringBuffer();
          for (final segment in translatedSegments) {
            if (segment is List && segment.isNotEmpty) {
              buffer.write(segment[0].toString());
            }
          }
          final result = buffer.toString();
          _cache[cacheKey] = result;
          return result;
        }
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    
    return ''; // Return empty string on failure to avoid disrupting UI
  }

  /// Translate multiple texts in batch
  Future<List<String>> translateBatch(List<String> texts, String targetLanguageCode) async {
    final results = <String>[];
    
    // Process in smaller batches to avoid URL length limits or rate limits
    // but for simplicity, we'll do them sequentially or with Future.wait with limit
    for (final text in texts) {
      final result = await translateText(text, targetLanguageCode);
      results.add(result);
      // Small delay to prevent rate-limiting from Google
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    
    return results;
  }

  /// Translates a list of LRC lines and populates their `translation` field
  Future<List<LrcLine>> translateLrcLines(List<LrcLine> lines, String targetLanguageCode) async {
    final translatedLines = <LrcLine>[];
    
    for (final line in lines) {
      if (line.text.trim().isEmpty) {
        translatedLines.add(line);
        continue;
      }
      
      final translatedText = await translateText(line.text, targetLanguageCode);
      final newLine = line.copyWith(translation: translatedText);
      translatedLines.add(newLine);
      
      // Small delay to prevent rate-limiting
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    
    return translatedLines;
  }
}
