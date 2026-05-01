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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Heart Rate Value ──────────────────────────────────────────────
              Text(
                result.heartRateString,
                style: const TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.stressRed,
                ),
              ),
              const Text(
                'BPM',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),

              // ── Back button ───────────────────────────────────────────────
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
