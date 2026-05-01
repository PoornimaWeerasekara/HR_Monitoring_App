import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../data/models/stress_response.dart';
import '../../state/stress_controller.dart';
import '../../data/services/heart_rate_service.dart';
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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                const Text('VitaSense', style: AppTheme.heading),
                const Text(
                  'HR Checker',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap Start to measure',
                  style: AppTheme.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // ── Action button ────────────────────────────────────────────
                _isLoading
                    ? Column(
                        children: [
                          const SizedBox(
                            height: 40,
                            width: 120,
                            child: EcgWaveform(),
                          ),
                          const SizedBox(height: 10),
                          const Text('Measuring...', style: AppTheme.heading),
                          const SizedBox(height: 5),
                          const Text('Keep your wrist still', style: AppTheme.body),
                        ],
                      )
                    : RoundButton(
                        label: 'Start',
                        onPressed: _startTest,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EcgWaveform extends StatefulWidget {
  const EcgWaveform({super.key});

  @override
  State<EcgWaveform> createState() => _EcgWaveformState();
}

class _EcgWaveformState extends State<EcgWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: EcgPainter(_controller.value),
        );
      },
    );
  }
}

class EcgPainter extends CustomPainter {
  final double progress;
  EcgPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.stressRed
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final midY = height / 2;

    path.moveTo(0, midY);

    for (double x = 0; x <= width; x++) {
      double relativeX = (x / width + progress) % 1.0;
      double y = midY;

      // Simple ECG-like pulse
      if (relativeX > 0.4 && relativeX < 0.6) {
        double t = (relativeX - 0.4) / 0.2;
        if (t < 0.2) y -= t * 20; // P wave
        else if (t < 0.3) y = midY;
        else if (t < 0.4) y += 10; // Q wave
        else if (t < 0.5) y -= 40; // R wave (peak)
        else if (t < 0.6) y += 50; // S wave
        else if (t < 0.7) y = midY;
        else if (t < 0.9) y -= (1.0 - (t-0.7)/0.2) * 5; // T wave
      }

      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EcgPainter oldDelegate) => true;
}
