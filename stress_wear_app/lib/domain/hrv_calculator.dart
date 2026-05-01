import 'dart:math';

import '../core/constants.dart';

/// Calculates HRV (Heart Rate Variability) features from a list of raw
/// heart-rate readings (in beats-per-minute).
///
/// Feature set (must match the training column order exactly):
///   mean_hr, mean_rr, sdnn, rmssd, pnn50, min_hr, max_hr
///
/// Notes
/// -----
/// - RR intervals are estimated as 60 000 / HR (ms). True RR intervals from
///   the raw ECG give more accurate HRV but are not available from the watch
///   sensor directly.
/// - For a production app, collect raw inter-beat intervals from the watch
///   SensorManager and pass those directly, skipping the HR→RR conversion.
class HrvCalculator {
  HrvCalculator._(); // prevent instantiation

  /// Returns a map of HRV features from the provided HR sample list.
  ///
  /// Throws [Exception] if there are fewer than [AppConstants.minSampleCount]
  /// valid readings.
  static Map<String, double> calculateFeatures(List<double> heartRates) {
    // Filter out physiologically impossible readings
    final valid = heartRates
        .where(
          (hr) =>
              hr > 0 && hr >= AppConstants.minValidHr && hr <= AppConstants.maxValidHr,
        )
        .toList();

    if (valid.length < AppConstants.minSampleCount) {
      throw Exception(
        'Not enough valid heart-rate samples '
        '(need ≥ ${AppConstants.minSampleCount}, got ${valid.length}).',
      );
    }

    // Convert HR (bpm) → RR interval (ms)
    final rr = valid.map((hr) => 60000.0 / hr).toList();

    return {
      'mean_hr': _mean(valid),
      'mean_rr': _mean(rr),
      'sdnn':    _stdDev(rr),
      'rmssd':   _rmssd(rr),
      'pnn50':   _pnn50(rr),
      'min_hr':  valid.reduce(min),
      'max_hr':  valid.reduce(max),
    };
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static double _mean(List<double> v) =>
      v.reduce((a, b) => a + b) / v.length;

  static double _stdDev(List<double> v) {
    final avg = _mean(v);
    final variance =
        v.map((x) => pow(x - avg, 2)).reduce((a, b) => a + b) / v.length;
    return sqrt(variance);
  }

  static double _rmssd(List<double> rr) {
    final squaredDiffs = <double>[
      for (int i = 1; i < rr.length; i++) pow(rr[i] - rr[i - 1], 2).toDouble(),
    ];
    return sqrt(_mean(squaredDiffs));
  }

  static double _pnn50(List<double> rr) {
    int count = 0;
    for (int i = 1; i < rr.length; i++) {
      if ((rr[i] - rr[i - 1]).abs() > 50) count++;
    }
    return count / (rr.length - 1) * 100;
  }
}
