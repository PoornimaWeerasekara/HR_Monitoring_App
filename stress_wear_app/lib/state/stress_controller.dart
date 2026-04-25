import '../data/models/stress_response.dart';
import '../data/repositories/stress_repository.dart';
import '../data/services/heart_rate_service.dart';

/// Presentation-layer controller – bridges the UI screens with the data layer.
///
/// Responsibilities:
///   1. Fetch heart-rate samples (dummy or real sensor).
///   2. Delegate HRV calculation + API call to [StressRepository].
///   3. Return [StressResponse] for the UI to display.
class StressController {
  final StressRepository _repository;
  final HeartRateService _heartRateService;

  StressController({
    StressRepository? repository,
    HeartRateService? heartRateService,
  })  : _repository    = repository    ?? StressRepository(),
        _heartRateService = heartRateService ?? HeartRateService();

  /// Runs the full stress analysis pipeline and returns the result.
  ///
  /// Stage 1: uses dummy HR values from [HeartRateService.getDummyHeartRates].
  /// Stage 2: replace the body of [_collectHeartRates] to call the real sensor.
  Future<StressResponse> analyzeStress() async {
    final heartRates = await _collectHeartRates();
    return _repository.analyze(heartRates);
  }

  // ── Heart-rate collection ─────────────────────────────────────────────────

  /// Stage 1 – returns dummy values immediately.
  ///
  /// Stage 2 (real watch) – uncomment [heartRateService.getHeartRateSamples()]
  /// and remove the dummy line.
  Future<List<double>> _collectHeartRates() async {
    // Stage 1: dummy
    return _heartRateService.getDummyHeartRates();

    // Stage 2: real sensor via Platform Channel
    // return _heartRateService.getHeartRateSamples();
  }
}
