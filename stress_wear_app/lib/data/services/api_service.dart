import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../models/stress_request.dart';
import '../models/stress_response.dart';

/// Handles all HTTP communication with the Flask stress-detection API.
class ApiService {
  // Base URL is read from [AppConstants] – change it there, not here.
  static String get _baseUrl => AppConstants.flaskBaseUrl;

  /// POSTs HRV features to [_baseUrl]/predict and returns a [StressResponse].
  ///
  /// Throws [Exception] on non-200 responses or network errors.
  Future<StressResponse> predictStress(StressRequest request, {double heartRate = 0.0}) async {
    final url = Uri.parse('$_baseUrl/predict');

    final http.Response response;
    try {
      response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      throw Exception('Network error – is Flask running? ($e)');
    }

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return StressResponse.fromJson(json, heartRate: heartRate);
    } else {
      throw Exception(
        'Prediction failed [${response.statusCode}]: ${response.body}',
      );
    }
  }

  /// Checks whether the Flask server is reachable.
  Future<bool> isServerReachable() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
