// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../enums.dart';
import '../transition_animation.dart';

class GrowingBarsTransition extends TransitionAnimation {
  final TransitionDirection direction;
  final List<Color>? colors;

  const GrowingBarsTransition({
    super.key,
    required super.onAnimationComplete,
    required super.onTransitionEnd,
    this.direction = TransitionDirection.left,
    this.colors,
  });

  @override
  State<GrowingBarsTransition> createState() => GrowingBarsTransitionState();
}

class GrowingBarsTransitionState
    extends TransitionAnimationState<GrowingBarsTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeController.value = 1.0; // Start fully opaque

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
        _fadeController.reverse();
      }
    });

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) widget.onTransitionEnd();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomPaint(
          painter: _GrowingBarsPainter(
            animation: _controller,
            colors: widget.colors ?? [Colors.blue, Colors.red, Colors.green],
            direction: widget.direction,
          ),
        );
      },
    );
  }
}

class _GrowingBarsPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Color> colors;
  final TransitionDirection direction;

  _GrowingBarsPainter({
    required this.animation,
    required this.colors,
    required this.direction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double barWidth = animation.value;
    final double barHeight = size.height;
    final double barThickness = size.width / 10; // Fixed thickness for now

    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = barThickness;

    for (int i = 0; i < colors.length; i++) {
      final Color color = colors[i];
      final double startX = (i * barWidth) + (barWidth / 2) - (barWidth / 2);
      final double endX = startX + barWidth;
      final double y = barHeight / 2;

      paint.color = color;
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
