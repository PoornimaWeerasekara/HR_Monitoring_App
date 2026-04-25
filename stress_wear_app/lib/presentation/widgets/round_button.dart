import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

/// A customisable round button suited to Wear OS circular displays.
class RoundButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const RoundButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primary,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
