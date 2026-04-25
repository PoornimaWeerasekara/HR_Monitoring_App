import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../data/models/stress_response.dart';
import '../../state/stress_controller.dart';
import '../widgets/round_button.dart';
import 'result_screen.dart';

/// Intermediate screen shown while HR is being collected.
///
/// In Stage 1 this is mostly cosmetic (HR collection is instant with dummy
/// values). In Stage 2+ this can show a real countdown or progress ring.
class MeasuringScreen extends StatefulWidget {
  const MeasuringScreen({super.key});

  @override
  State<MeasuringScreen> createState() => _MeasuringScreenState();
}

class _MeasuringScreenState extends State<MeasuringScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;
  final _controller = StressController();
  String _statusText = 'Collecting data…';

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Start analysis as soon as the screen opens.
    _runAnalysis();
  }

  Future<void> _runAnalysis() async {
    setState(() => _statusText = 'Analysing HRV…');

    try {
      final StressResponse result = await _controller.analyzeStress();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusText = 'Error: $e');
    }
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _rotateController,
                child: const Icon(
                  Icons.sync,
                  color: AppTheme.primary,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(_statusText,
                  style: AppTheme.body, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
