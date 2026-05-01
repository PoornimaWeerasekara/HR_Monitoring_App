import 'package:permission_handler/permission_handler.dart';
import '../data/models/stress_response.dart';
import '../data/repositories/stress_repository.dart';
import '../data/services/heart_rate_service.dart';

/// Presentation-layer controller – bridges the UI screens with the data layer.
class StressController {
  final StressRepository _repository;
  final HeartRateService _heartRateService;

  StressController({
    StressRepository? repository,
    HeartRateService? heartRateService,
  })  : _repository    = repository    ?? StressRepository(),
        _heartRateService = heartRateService ?? HeartRateService();

  /// Runs the full stress analysis pipeline and returns the result.
  Future<StressResponse> analyzeStress() async {
    final heartRates = await _collectHeartRates();
    return _repository.analyze(heartRates);
  }

  // ── Heart-rate collection ─────────────────────────────────────────────────

  /// Ensures sensor permissions are granted and then calls the real HR sensor.
  Future<List<double>> _collectHeartRates() async {
    // 1. Check/Request Body Sensors permission
    final status = await Permission.sensors.status;
    if (!status.isGranted) {
      final result = await Permission.sensors.request();
      if (!result.isGranted) {
        throw Exception('Sensor permission denied. Please enable it in settings.');
      }
    }

    // 2. Collect samples from the native sensor
    return _heartRateService.getHeartRateSamples();
  }
}
