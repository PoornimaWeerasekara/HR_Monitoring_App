import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../data/models/stress_response.dart';

/// Displays the Flask prediction result on the watch.
///
/// Shows:
///   - Stressed / Not Stressed status with a colour-coded icon.
///   - Confidence score as a percentage.
///   - A Back button to return to [HomeScreen].
class ResultScreen extends StatelessWidget {
  final StressResponse result;

  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isStressed = result.isStressed;
    final statusColor = isStressed ? AppTheme.stressRed : AppTheme.calmGreen;
    final statusIcon  = isStressed ? Icons.warning_rounded : Icons.check_circle;
    final statusText  = isStressed ? 'Stressed' : 'Not Stressed';

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Heart Rate Value ──────────────────────────────────────────────
                Text(
                  result.heartRateString,
                  style: const TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'BPM',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                const SizedBox(height: 30),

                // ── Back button ───────────────────────────────────────────────
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('BACK'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
