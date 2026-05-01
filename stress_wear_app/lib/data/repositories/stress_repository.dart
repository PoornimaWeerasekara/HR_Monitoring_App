import '../models/stress_request.dart';
import '../models/stress_response.dart';
import '../services/api_service.dart';
import '../../core/constants.dart';
import '../../domain/hrv_calculator.dart';

/// Thin repository layer between the presentation layer and data sources.
///
/// Combines [HrvCalculator] and [ApiService] so that screens / controllers
/// only call a single method.
class StressRepository {
  final ApiService _api;

  StressRepository({ApiService? apiService})
      : _api = apiService ?? ApiService();

  /// Calculates HRV features from raw [heartRates], builds a request, and
  /// returns the Flask API prediction.
  Future<StressResponse> analyze(List<double> heartRates) async {
    final features = HrvCalculator.calculateFeatures(heartRates);

    final request = StressRequest(
      userId: AppConstants.defaultUserId,
      timestamp: DateTime.now().toUtc().toIso8601String(),
      features: features,
    );

    return _api.predictStress(request, heartRate: features['mean_hr'] ?? 0.0);
  }
}
