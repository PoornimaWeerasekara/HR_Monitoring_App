import 'package:flutter/services.dart';

/// Reads heart-rate data from the Galaxy Watch sensor via a native
/// Android MethodChannel (Platform Channel).
///
/// Stage 1 – Dummy values
/// ----------------------
/// [getDummyHeartRates] returns a fixed list for early development and
/// Postman-equivalent testing without a real watch.
///
/// Stage 2 – Real sensor (Kotlin side)
/// ------------------------------------
/// Uncomment [getHeartRateSamples] and implement the corresponding Kotlin
/// handler in `android/app/src/main/kotlin/.../MainActivity.kt`.
///
/// Kotlin side (MainActivity.kt) should do:
///   MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
///     .setMethodCallHandler { call, result ->
///         if (call.method == "getHeartRateSamples") {
///             val samples = listOf(78.0, 80.0, 82.0)   // real sensor values
///             result.success(samples)
///         }
///     }
class HeartRateService {
  static const _channel = MethodChannel('com.stresswear.app/heart_rate');

  // ── Stage 1: Dummy values ─────────────────────────────────────────────────
  /// Returns a fixed list of plausible heart-rate readings (bpm).
  /// Use this while the UI and API are being built.
  List<double> getDummyHeartRates() {
    return [78, 80, 82, 79, 85, 88, 84, 81, 83, 86]
        .map((v) => v.toDouble())
        .toList();
  }

  // ── Stage 2: Real sensor (Platform Channel) ───────────────────────────────
  // Uncomment the method below once the Kotlin MainActivity is set up.
  //
  // /// Calls the native Android SensorManager and returns live HR samples.
  // Future<List<double>> getHeartRateSamples() async {
  //   try {
  //     final List<dynamic> raw =
  //         await _channel.invokeMethod('getHeartRateSamples');
  //     return raw.map((v) => (v as num).toDouble()).toList();
  //   } on PlatformException catch (e) {
  //     throw Exception('Heart rate sensor error: ${e.message}');
  //   }
  // }
}
