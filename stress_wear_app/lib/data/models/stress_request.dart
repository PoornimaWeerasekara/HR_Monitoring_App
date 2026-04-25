/// Data model for the stress prediction request sent to the Flask API.
class StressRequest {
  final String userId;
  final String timestamp;
  final Map<String, double> features;

  const StressRequest({
    required this.userId,
    required this.timestamp,
    required this.features,
  });

  /// Serialises to the JSON format expected by the Flask /predict endpoint.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'timestamp': timestamp,
      'features': features,
    };
  }
}
