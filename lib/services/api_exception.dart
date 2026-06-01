import 'dart:convert' as convert;

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  factory ApiException.fromResponse(String fallback, String body) {
    if (body.trim().isEmpty) return ApiException(fallback);

    try {
      final decoded = convert.jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final messages = <String>[];
        decoded.forEach((key, value) {
          if (value is List && value.isNotEmpty) {
            messages.add('$key: ${value.join(', ')}');
          } else {
            messages.add('$key: $value');
          }
        });
        if (messages.isNotEmpty) return ApiException(messages.join('\n'));
      }
      return ApiException(decoded.toString());
    } catch (_) {
      return ApiException(fallback);
    }
  }

  @override
  String toString() => message;
}
