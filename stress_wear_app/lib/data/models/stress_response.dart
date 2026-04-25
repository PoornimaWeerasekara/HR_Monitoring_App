/// Data model for the stress prediction response returned by the Flask API.
class StressResponse {
  /// Either "stressed" or "not_stressed".
  final String label;

  /// Model confidence score in the range [0.0, 1.0].
  final double confidence;

  const StressResponse({
    required this.label,
    required this.confidence,
  });

  /// Deserialises the Flask API response JSON.
  ///
  /// Expected shape:
  /// ```json
  /// {
  ///   "status": "success",
  ///   "prediction": { "label": "stressed", "confidence": 0.87 }
  /// }
  /// ```
  factory StressResponse.fromJson(Map<String, dynamic> json) {
    final prediction = json['prediction'] as Map<String, dynamic>;
    return StressResponse(
      label: prediction['label'] as String,
      confidence: (prediction['confidence'] as num).toDouble(),
    );
  }

  bool get isStressed => label == 'stressed';

  /// Confidence as a human-readable percentage string, e.g. "87.3%".
  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(1)}%';
}
