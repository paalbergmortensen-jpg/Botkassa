import 'package:flutter/material.dart';
import '../theme.dart';

class VarAnimationOverlay extends StatefulWidget {
  final VoidCallback onFinished;

  const VarAnimationOverlay({super.key, required this.onFinished});

  @override
  State<VarAnimationOverlay> createState() => _VarAnimationOverlayState();
}

class _VarAnimationOverlayState extends State<VarAnimationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rectAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _rectAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) widget.onFinished();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // The drawing of the rectangle (VAR sign)
                AnimatedBuilder(
                  animation: _rectAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(200, 150),
                      painter: VarSignPainter(_rectAnimation.value),
                    );
                  },
                ),
                // Text appearing after the sign
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Column(
                    children: [
                      const Icon(Icons.monitor_rounded, color: AppTheme.accentLime, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'CHECKING VAR...',
                        style: TextStyle(
                          color: AppTheme.accentLime,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class VarSignPainter extends CustomPainter {
  final double progress;

  VarSignPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // Drawing the rectangle in 4 steps based on progress
    double w = size.width;
    double h = size.height;

    if (progress > 0) {
      // Top
      double p1 = (progress / 0.25).clamp(0.0, 1.0);
      path.moveTo(0, 0);
      path.lineTo(w * p1, 0);
    }
    if (progress > 0.25) {
      // Right
      double p2 = ((progress - 0.25) / 0.25).clamp(0.0, 1.0);
      path.moveTo(w, 0);
      path.lineTo(w, h * p2);
    }
    if (progress > 0.5) {
      // Bottom
      double p3 = ((progress - 0.5) / 0.25).clamp(0.0, 1.0);
      path.moveTo(w, h);
      path.lineTo(w - (w * p3), h);
    }
    if (progress > 0.75) {
      // Left
      double p4 = ((progress - 0.75) / 0.25).clamp(0.0, 1.0);
      path.moveTo(0, h);
      path.lineTo(0, h - (h * p4));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(VarSignPainter oldDelegate) => oldDelegate.progress != progress;
}
