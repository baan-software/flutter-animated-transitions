// A random number of circles, scattered on the screen, expanding until completely filling the screen

// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:animated_transitions/transition.dart';

class ExpandingCirclesTransition extends Transition {
  final Color? color;
  final int numberOfCircles;
  final List<Color>? colors;

  ExpandingCirclesTransition({
    super.key,
    this.color = Colors.deepPurple,
    this.colors,
    this.numberOfCircles = 25,
    super.duration = const Duration(milliseconds: 800),
  });

  @override
  State<ExpandingCirclesTransition> createState() =>
      _ExpandingCirclesTransitionState();
}

class _ExpandingCirclesTransitionState
    extends TransitionState<ExpandingCirclesTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  Animation<double>? _radiusAnimation;
  Animation<Color?>? _colorAnimation;
  Size? _lastSize;
  final _random = Random();
  final List<Offset> _circleCenters = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

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

  void _setup(Size size) {
    _circleCenters.clear();
    for (int i = 0; i < widget.numberOfCircles; i++) {
      _circleCenters.add(
        Offset(
          _random.nextDouble() * size.width,
          _random.nextDouble() * size.height,
        ),
      );
    }

    double maxDist = 0.0;
    const gridDensity = 20;
    for (int i = 0; i <= gridDensity; i++) {
      for (int j = 0; j <= gridDensity; j++) {
        final p = Offset(
          i * size.width / gridDensity,
          j * size.height / gridDensity,
        );
        double minDistToCenter = double.infinity;
        for (final center in _circleCenters) {
          minDistToCenter = min(minDistToCenter, (p - center).distance);
        }
        if (minDistToCenter > maxDist) {
          maxDist = minDistToCenter;
        }
      }
    }

    final maxRadius = maxDist;

    _radiusAnimation = Tween<double>(
      begin: 0,
      end: maxRadius,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc));

    final List<Color> animationColors;
    final colors = widget.colors;
    if (colors == null || colors.isEmpty) {
      animationColors = [widget.color!, widget.color!];
    } else if (colors.length == 1) {
      animationColors = [colors[0], colors[0]];
    } else {
      animationColors = colors;
    }

    final tweenItems = <TweenSequenceItem<Color?>>[];
    for (var i = 0; i < animationColors.length - 1; i++) {
      tweenItems.add(
        TweenSequenceItem(
          tween: ColorTween(
            begin: animationColors[i],
            end: animationColors[i + 1],
          ),
          weight: 1,
        ),
      );
    }
    _colorAnimation = TweenSequence<Color?>(tweenItems).animate(_controller);
  }

  void _play() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (_lastSize != size) {
            _lastSize = size;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _setup(size);
                _play();
              }
            });
          }

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ScatteredCirclesPainter(
                  radius: _radiusAnimation?.value ?? 0,
                  color: _colorAnimation?.value ?? widget.color ?? Colors.black,
                  centers: _circleCenters,
                ),
                size: size,
              );
            },
          );
        },
      ),
    );
  }
}

class _ScatteredCirclesPainter extends CustomPainter {
  final double radius;
  final Color color;
  final List<Offset> centers;

  _ScatteredCirclesPainter({
    required this.radius,
    required this.color,
    required this.centers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final center in centers) {
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScatteredCirclesPainter oldDelegate) => true;
}
