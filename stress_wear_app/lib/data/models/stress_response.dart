/// Data model for the stress prediction response returned by the Flask API.
class StressResponse {
  /// Either "stressed" or "not_stressed".
  final String label;

  /// Model confidence score in the range [0.0, 1.0].
  final double confidence;

  /// The average heart rate measured during the sample period.
  final double measuredHeartRate;

  /// Raw HRV features.
  final Map<String, double> features;

  const StressResponse({
    required this.label,
    required this.confidence,
    required this.measuredHeartRate,
    this.features = const {},
  });

  /// Deserialises the Flask API response JSON.
  factory StressResponse.fromJson(Map<String, dynamic> json, {
    double heartRate = 0.0,
    Map<String, double> features = const {},
  }) {
    final prediction = json['prediction'] as Map<String, dynamic>;
    return StressResponse(
      label: prediction['label'] as String,
      confidence: (prediction['confidence'] as num).toDouble(),
      measuredHeartRate: heartRate,
      features: features,
    );
  }

  bool get isStressed => label == 'stressed';

  /// Heart rate as a whole number string, e.g. "78".
  String get heartRateString => measuredHeartRate.toStringAsFixed(0);

  /// Confidence as a human-readable percentage string, e.g. "87.3%".
  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(1)}%';
}
