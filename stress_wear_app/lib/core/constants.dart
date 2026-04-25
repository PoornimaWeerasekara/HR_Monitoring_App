/// Application-wide constants.
///
/// Replace [flaskBaseUrl] with your laptop's IPv4 address when testing on a
/// real watch.  Use the deployed URL (https://...) in production.
class AppConstants {
  AppConstants._();

  // ── API ──────────────────────────────────────────────────────────────────
  /// Change this to your laptop's IP when testing on a real watch.
  /// Example: 'http://192.168.1.8:5000'
  /// DO NOT use 'localhost' on a physical device.
  static const String flaskBaseUrl = 'http://10.0.2.2:5005'; // emulator default

  // ── User ─────────────────────────────────────────────────────────────────
  /// Hard-coded user ID for early development.  Replace with real auth later.
  static const String defaultUserId = 'student_001';

  // ── Thresholds ────────────────────────────────────────────────────────────
  /// Minimum valid heart-rate reading (bpm).
  static const double minValidHr = 40.0;

  /// Maximum valid heart-rate reading (bpm).
  static const double maxValidHr = 200.0;

  /// Minimum number of HR samples required to calculate HRV.
  static const int minSampleCount = 2;
}
