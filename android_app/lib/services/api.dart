
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'store.dart';

class Api {
  static String get base {
    final url = Store.url.trim();

    return url.replaceAll(
      RegExp(r'/+$'),
      '',
    );
  }

  // Build API URL
  static Uri _uri(String path) {
    if (base.isEmpty) {
      throw Exception(
        'Backend is not configured. Please check your app setup.',
      );
    }

    final normalizedPath = path.startsWith('/')
        ? path
        : '/$path';

    return Uri.parse('$base$normalizedPath');
  }

  // POST request
  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .post(
            _uri(path),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(minutes: 3),
          );

      return _read(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // GET request
  static Future<Map<String, dynamic>> get(
    String path,
  ) async {
    try {
      final response = await http
          .get(
            _uri(path),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
          );

      return _read(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Upload resume
  static Future<Map<String, dynamic>> upload(
    String path,
    String name,
  ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        _uri('/resume/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          path,
          filename: name,
        ),
      );

      final streamedResponse = await request
          .send()
          .timeout(
            const Duration(minutes: 2),
          );

      final response = await http.Response.fromStream(
        streamedResponse,
      );

      return _read(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Parse server response
  static Map<String, dynamic> _read(
    http.Response response,
  ) {
    dynamic data;

    try {
      data = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'The server returned an invalid response.',
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final message = data is Map
          ? data['detail'] ?? data['message']
          : null;

      throw Exception(
        message?.toString() ??
            'Server error: HTTP ${response.statusCode}',
      );
    }

    if (data is! Map) {
      throw Exception(
        'Unexpected server response format.',
      );
    }

    return Map<String, dynamic>.from(data);
  }

  // Handle network errors
  static Exception _handleError(Object error) {
    if (error is http.ClientException) {
      return Exception(
        'Unable to connect to the AI server. Check your connection.',
      );
    }

    if (error is FormatException) {
      return Exception(
        'Invalid server response.',
      );
    }

    if (error is Exception) {
      return error;
    }

    return Exception(
      'Something went wrong. Please try again.',
    );
  }
}
