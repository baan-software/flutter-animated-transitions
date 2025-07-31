// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/transition.dart';

abstract class PixelatedTransitionBase extends Transition {
  final Color? color;
  final int pixelDensity;
  final List<Color>? colors;

  static const pixelDensityMin = 10;
  static const pixelDensityMax = 100;

  PixelatedTransitionBase({
    super.key,
    this.color = Colors.deepPurple,
    this.colors,
    int pixelDensity = 30,
    super.duration = const Duration(milliseconds: 1200),
  }) : pixelDensity = pixelDensity.clamp(pixelDensityMin, pixelDensityMax);

  @override
  State<PixelatedTransitionBase> createState() =>
      _PixelatedTransitionBaseState();

  /// Override this method to define how pixel delays are calculated
  List<List<double>> createPixelDelays(
      int verticalPixels, int horizontalPixels);
}

class _PixelatedTransitionBaseState
    extends TransitionState<PixelatedTransitionBase>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  Size? _lastSize;
  late List<List<double>> _pixelDelays;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize with empty arrays to prevent late initialization error
    _pixelDelays = [[]];

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
        Future.delayed(const Duration(milliseconds: 100), () {
          _fadeController.reverse();
        });
      }
    });
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) widget.onTransitionEnd();
    });
  }

  void _setup(Size size) {
    // Calculate pixel size based on the shorter dimension
    final shortestSide = min(size.width, size.height);
    final pixelSize = shortestSide / widget.pixelDensity;

    // Calculate number of pixels in each dimension
    final horizontalPixels = (size.width / pixelSize).ceil();
    final verticalPixels = (size.height / pixelSize).ceil();

    // Get pixel delays from the specific implementation
    _pixelDelays = widget.createPixelDelays(verticalPixels, horizontalPixels);

    // Setup color animation if colors are provided
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
                painter: _PixelatedPainter(
                  progress: _controller.value,
                  color: _colorAnimation?.value ?? widget.color ?? Colors.black,
                  pixelDelays: _pixelDelays,
                  pixelDensity: widget.pixelDensity,
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

class _PixelatedPainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<List<double>> pixelDelays;
  final int pixelDensity;

  _PixelatedPainter({
    required this.progress,
    required this.color,
    required this.pixelDelays,
    required this.pixelDensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Calculate pixel size based on the shorter dimension
    final shortestSide = min(size.width, size.height);
    final pixelSize = shortestSide / pixelDensity;

    for (int y = 0; y < pixelDelays.length; y++) {
      for (int x = 0; x < pixelDelays[y].length; x++) {
        // Only draw pixel if its delay threshold has been reached
        if (progress >= pixelDelays[y][x]) {
          final rect = Rect.fromLTWH(
            x * pixelSize,
            y * pixelSize,
            pixelSize,
            pixelSize,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelatedPainter oldDelegate) =>
      progress != oldDelegate.progress || color != oldDelegate.color;
}
