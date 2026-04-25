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
              // ── Status icon ───────────────────────────────────────────────
              Icon(statusIcon, color: statusColor, size: 40),
              const SizedBox(height: 8),

              // ── Label ─────────────────────────────────────────────────────
              Text(
                statusText,
                style: AppTheme.heading.copyWith(color: statusColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // ── Confidence ────────────────────────────────────────────────
              Text(
                'Confidence: ${result.confidencePercent}',
                style: AppTheme.body,
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
