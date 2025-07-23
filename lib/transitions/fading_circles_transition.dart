// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';

import '../transition_animation.dart';

class FadingCirclesTransition extends TransitionAnimation {
  final int circleCount;
  final List<Color>? colors;

  const FadingCirclesTransition({
    super.key,
    required super.onAnimationComplete,
    required super.onTransitionEnd,
    this.circleCount = 10,
    this.colors,
  });

  @override
  State<FadingCirclesTransition> createState() =>
      _FadingCirclesTransitionState();
}

class _FadingCirclesTransitionState
    extends TransitionAnimationState<FadingCirclesTransition>
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
    )..value = 1.0;

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
          painter: _FadingCirclesPainter(
            controller: _controller,
            circleCount: widget.circleCount,
            colors: widget.colors ?? [Colors.blue, Colors.red, Colors.green],
          ),
        );
      },
    );
  }
}

class _FadingCirclesPainter extends CustomPainter {
  _FadingCirclesPainter({
    required this.controller,
    required this.circleCount,
    required this.colors,
  });

  final AnimationController controller;
  final int circleCount;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = min(size.width, size.height) / 3;

    for (int i = 0; i < circleCount; i++) {
      final Paint paint = Paint()
        ..color = colors[i % colors.length]
            .withAlpha((255 * max(0, 1 - (i / circleCount - controller.value).abs())).toInt());
      canvas.drawCircle(Offset.zero, radius * (i + 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
