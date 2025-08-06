// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/transition.dart';
import 'package:animated_transitions/enums.dart';

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
    super.exitMode = TransitionExitMode.sameDirection,
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
  late List<List<double>>
      _initialPixelDelays; // Store for reverse/sameDirection modes
  Animation<Color?>? _colorAnimation;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    // Initialize with empty arrays to prevent late initialization error
    _pixelDelays = [[]];
    _initialPixelDelays = [[]];

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: widget.exitMode == TransitionExitMode.fade
          ? const Duration(milliseconds: 400)
          : widget.duration,
    )..value = 1.0;

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
        Future.delayed(const Duration(milliseconds: 100), () {
          _isExiting = true;
          if (!mounted) return; // Safety check
          if (widget.exitMode == TransitionExitMode.fade) {
            _fadeController.reverse();
          } else if (_lastSize != null) {
            // Safety check for size
            _setup(_lastSize!);
            _controller.reset();
            _controller.forward();
          }
        });
      }
    });
    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed &&
          widget.exitMode == TransitionExitMode.fade) {
        widget.onTransitionEnd();
      }
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isExiting) {
        widget.onTransitionEnd();
      }
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
    _initialPixelDelays =
        widget.createPixelDelays(verticalPixels, horizontalPixels);

    if (_isExiting) {
      switch (widget.exitMode) {
        case TransitionExitMode.fade:
          _pixelDelays = _initialPixelDelays;
          break;
        case TransitionExitMode.reverse:
          _pixelDelays = List.generate(
            verticalPixels,
            (y) => List.generate(
              horizontalPixels,
              (x) => 1.0 - _initialPixelDelays[y][x],
            ),
          );
          break;
        case TransitionExitMode.sameDirection:
          _pixelDelays = _initialPixelDelays;
          break;
      }
    } else {
      _pixelDelays = _initialPixelDelays;
    }

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

    if (_isExiting && widget.exitMode != TransitionExitMode.fade) {
      // Reverse the color sequence for exit animations
      for (var i = animationColors.length - 1; i > 0; i--) {
        tweenItems.add(
          TweenSequenceItem(
            tween: ColorTween(
              begin: animationColors[i],
              end: animationColors[i - 1],
            ),
            weight: 1,
          ),
        );
      }
    } else {
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
          if (_lastSize != size && !_isExiting) {
            // Only setup on size change during entrance
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
                  isExiting: _isExiting,
                  exitMode: widget.exitMode,
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
  final bool isExiting;
  final TransitionExitMode exitMode;

  _PixelatedPainter({
    required this.progress,
    required this.color,
    required this.pixelDelays,
    required this.pixelDensity,
    required this.isExiting,
    required this.exitMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // Calculate pixel size based on the shorter dimension
    final shortestSide = min(size.width, size.height);
    final pixelSize = shortestSide / pixelDensity;

    for (int y = 0; y < pixelDelays.length; y++) {
      for (int x = 0; x < pixelDelays[y].length; x++) {
        // For exit animations (except fade), we remove pixels instead of adding them
        bool shouldDraw = exitMode == TransitionExitMode.fade || !isExiting
            ? progress >=
                pixelDelays[y][x] // Normal: draw when progress exceeds delay
            : progress <
                pixelDelays[y]
                    [x]; // Exit: draw when progress is less than delay

        if (shouldDraw) {
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
