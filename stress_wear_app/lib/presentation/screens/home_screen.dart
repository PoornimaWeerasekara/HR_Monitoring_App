import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../data/models/stress_response.dart';
import '../../state/stress_controller.dart';
import '../widgets/round_button.dart';
import 'result_screen.dart';

/// The first screen shown on the watch.
///
/// Shows a "Start" button. When tapped it:
///   1. Collects heart-rate samples (dummy in Stage 1).
///   2. Calculates HRV features.
///   3. POSTs the features to the Flask backend.
///   4. Navigates to [ResultScreen] with the prediction.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  final _controller = StressController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startTest() async {
    setState(() => _isLoading = true);

    try {
      final StressResponse result = await _controller.analyzeStress();

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppTheme.stressRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Heart icon with pulse animation ──────────────────────────
              ScaleTransition(
                scale: _pulseAnim,
                child: const Icon(
                  Icons.favorite,
                  color: AppTheme.stressRed,
                  size: 36,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Stress Check', style: AppTheme.heading),
              const SizedBox(height: 4),
              const Text(
                'Tap Start to measure',
                style: AppTheme.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // ── Action button ────────────────────────────────────────────
              _isLoading
                  ? const CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 3,
                    )
                  : RoundButton(
                      label: 'Start',
                      onPressed: _startTest,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
