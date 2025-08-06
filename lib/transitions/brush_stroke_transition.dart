// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/enums.dart';
import 'package:animated_transitions/transition.dart';

class BrushStrokeTransition extends Transition {
  final TransitionDirection direction;
  final List<Color>? colors;
  final int strokeCount;
  final double strokeWidth;
  final double curviness;
  @override
  // ignore: overridden_fields
  final TransitionExitMode exitMode = TransitionExitMode.fade;

  BrushStrokeTransition({
    super.key,
    this.direction = TransitionDirection.bottom,
    this.colors,
    this.strokeCount = 8,
    this.strokeWidth = 80.0,
    this.curviness = 0.3,
    super.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<BrushStrokeTransition> createState() => BrushStrokeTransitionState();
}

class BrushStrokeTransitionState extends TransitionState<BrushStrokeTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  List<BrushStroke> _brushStrokes = [];
  final _random = Random();
  Size? _lastSize;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: widget.exitMode == TransitionExitMode.fade
          ? const Duration(milliseconds: 400)
          : widget.duration,
      vsync: this,
    );
    _fadeController.value = 1.0; // Start fully opaque

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isExiting) {
        widget.onAnimationComplete();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          _isExiting = true;
          if (widget.exitMode == TransitionExitMode.fade) {
            _fadeController.reverse();
          } else if (widget.exitMode == TransitionExitMode.reverse) {
            _controller.reverse();
          } else {
            // sameDirection - use same strokes, replay animation
            _controller.reset();
            _controller.forward();
          }
        });
      } else if (status == AnimationStatus.completed && _isExiting) {
        widget.onTransitionEnd();
      } else if (status == AnimationStatus.dismissed && _isExiting) {
        widget.onTransitionEnd();
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

    _controller.forward();
  }

  void _setupBrushStrokes(Size size) {
    if (_lastSize == size && _brushStrokes.isNotEmpty) return;
    _lastSize = size;

    _brushStrokes.clear();

    final colors = widget.colors ??
        [
          const Color(0xFF2C3E50),
          const Color(0xFF34495E),
          const Color(0xFF1ABC9C),
        ];

    // Calculate optimal stroke count for full screen coverage
    final optimalStrokeCount = _calculateOptimalStrokeCount(size);

    for (int i = 0; i < optimalStrokeCount; i++) {
      final color = colors[i % colors.length];
      final stroke = _createBrushStroke(size, i, color, optimalStrokeCount);
      _brushStrokes.add(stroke);
    }
  }

  int _calculateOptimalStrokeCount(Size size) {
    final isHorizontal = widget.direction == TransitionDirection.left ||
        widget.direction == TransitionDirection.right;

    // Get the dimension we need to cover (perpendicular to stroke direction)
    final dimensionToCover = isHorizontal ? size.height : size.width;

    // Account for curviness - more curved strokes need more overlap
    final curvinessMultiplier = 1.0 + (widget.curviness * 0.5);

    // Calculate effective stroke width (accounting for overlap needed)
    final effectiveStrokeWidth =
        widget.strokeWidth * 0.8; // 80% coverage per stroke

    // Calculate base count needed for coverage
    final baseCount =
        (dimensionToCover / effectiveStrokeWidth * curvinessMultiplier).ceil();

    // Add extra strokes for better coverage and organic look
    final extraStrokes = (baseCount * 0.2).ceil(); // 20% extra

    // Ensure minimum count for visual appeal
    final minCount = widget.strokeCount; // Use provided strokeCount as minimum
    final maxCount = (dimensionToCover / (widget.strokeWidth * 0.3))
        .ceil(); // Prevent too many

    return (baseCount + extraStrokes).clamp(minCount, maxCount);
  }

  BrushStroke _createBrushStroke(
      Size size, int index, Color color, int totalStrokes) {
    final isHorizontal = widget.direction == TransitionDirection.left ||
        widget.direction == TransitionDirection.right;

    // Calculate stroke position
    final spacing = isHorizontal
        ? size.height / (totalStrokes + 1)
        : size.width / (totalStrokes + 1);
    final basePosition = spacing * (index + 1);
    final variation = spacing * 0.3 * (_random.nextDouble() - 0.5);
    final position = (basePosition + variation).clamp(
        spacing * 0.5,
        isHorizontal
            ? size.height - spacing * 0.5
            : size.width - spacing * 0.5);

    // Create brush stroke segments
    final segments = <BrushSegment>[];
    final numSegments = 50; // More segments = smoother brush stroke
    final strokeWidth = widget.strokeWidth * (0.8 + _random.nextDouble() * 0.4);

    for (int i = 0; i < numSegments; i++) {
      final t = i / (numSegments - 1); // 0 to 1
      final delay = t * 0.7 + (index / totalStrokes) * 0.3; // Stagger strokes

      Offset segmentPosition;
      double segmentSize;

      switch (widget.direction) {
        case TransitionDirection.top:
          final x = position +
              widget.curviness *
                  40 *
                  sin(t * pi * 2) *
                  (_random.nextDouble() - 0.5);
          final y = t * size.height;
          segmentPosition = Offset(x, y);
          break;
        case TransitionDirection.bottom:
          final x = position +
              widget.curviness *
                  40 *
                  sin(t * pi * 2) *
                  (_random.nextDouble() - 0.5);
          final y = size.height - (t * size.height);
          segmentPosition = Offset(x, y);
          break;
        case TransitionDirection.left:
          final x = t * size.width;
          final y = position +
              widget.curviness *
                  40 *
                  sin(t * pi * 2) *
                  (_random.nextDouble() - 0.5);
          segmentPosition = Offset(x, y);
          break;
        case TransitionDirection.right:
          final x = size.width - (t * size.width);
          final y = position +
              widget.curviness *
                  40 *
                  sin(t * pi * 2) *
                  (_random.nextDouble() - 0.5);
          segmentPosition = Offset(x, y);
          break;
      }

      // Vary segment size for organic brush look
      segmentSize = strokeWidth *
          (0.7 + 0.6 * sin(t * pi)) *
          (0.8 + _random.nextDouble() * 0.4);

      segments.add(BrushSegment(
        position: segmentPosition,
        size: segmentSize,
        delay: delay,
      ));
    }

    return BrushStroke(
      segments: segments,
      color: color,
      opacity: 0.9 + _random.nextDouble() * 0.1,
    );
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
          _setupBrushStrokes(size);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: SimpleBrushPainter(
                  progress: _controller.value,
                  brushStrokes: _brushStrokes,
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

class BrushStroke {
  final List<BrushSegment> segments;
  final Color color;
  final double opacity;

  BrushStroke({
    required this.segments,
    required this.color,
    required this.opacity,
  });
}

class BrushSegment {
  final Offset position;
  final double size;
  final double delay;

  BrushSegment({
    required this.position,
    required this.size,
    required this.delay,
  });
}

class SimpleBrushPainter extends CustomPainter {
  final double progress;
  final List<BrushStroke> brushStrokes;
  final bool isExiting;
  final TransitionExitMode? exitMode;

  SimpleBrushPainter({
    required this.progress,
    required this.brushStrokes,
    required this.isExiting,
    this.exitMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isExiting && exitMode == TransitionExitMode.sameDirection) {
      // For sameDirection exit mode, use reverse progress for erasing effect
      _paintSameDirectionBrushStrokes(canvas, size);
    } else {
      // For entrance mode and other exit modes, paint normally
      _paintNormalBrushStrokes(canvas, size);
    }
  }

  void _paintNormalBrushStrokes(Canvas canvas, Size size) {
    for (final stroke in brushStrokes) {
      final paint = Paint()
        ..color = stroke.color.withValues(alpha: stroke.opacity)
        ..style = PaintingStyle.fill;

      for (final segment in stroke.segments) {
        // Only draw segment if progress has reached its delay
        if (progress >= segment.delay) {
          // Calculate how much of this segment should be visible
          final segmentProgress =
              ((progress - segment.delay) / (1.0 - segment.delay))
                  .clamp(0.0, 1.0);

          if (segmentProgress > 0) {
            final currentSize = segment.size * segmentProgress;
            canvas.drawCircle(segment.position, currentSize / 2, paint);

            // Add some texture with smaller circles
            final textureSize = currentSize * 0.3;
            for (int i = 0; i < 3; i++) {
              final angle = i * 2 * pi / 3;
              final offset = Offset(
                segment.position.dx + cos(angle) * textureSize,
                segment.position.dy + sin(angle) * textureSize,
              );
              final texturePaint = Paint()
                ..color = stroke.color.withValues(alpha: stroke.opacity * 0.5)
                ..style = PaintingStyle.fill;
              canvas.drawCircle(offset, textureSize / 2, texturePaint);
            }
          }
        }
      }
    }
  }

  void _paintSameDirectionBrushStrokes(Canvas canvas, Size size) {
    // For sameDirection exit mode, reverse the progress so strokes disappear in same order they appeared
    final reverseProgress = 1.0 - progress;

    for (final stroke in brushStrokes) {
      final paint = Paint()
        ..color = stroke.color.withValues(alpha: stroke.opacity)
        ..style = PaintingStyle.fill;

      for (final segment in stroke.segments) {
        // Only draw segment if reverse progress hasn't reached its delay yet
        // This makes strokes disappear in the same order they appeared
        final adjustedDelay = 1.0 - segment.delay;
        if (reverseProgress >= adjustedDelay) {
          // Calculate how much of this segment should be visible
          final segmentProgress =
              ((reverseProgress - adjustedDelay) / (1.0 - adjustedDelay))
                  .clamp(0.0, 1.0);

          if (segmentProgress > 0) {
            final currentSize = segment.size * segmentProgress;
            canvas.drawCircle(segment.position, currentSize / 2, paint);

            // Add texture with smaller circles
            final textureSize = currentSize * 0.3;
            for (int i = 0; i < 3; i++) {
              final angle = i * 2 * pi / 3;
              final offset = Offset(
                segment.position.dx + cos(angle) * textureSize,
                segment.position.dy + sin(angle) * textureSize,
              );
              final texturePaint = Paint()
                ..color = stroke.color.withValues(alpha: stroke.opacity * 0.5)
                ..style = PaintingStyle.fill;
              canvas.drawCircle(offset, textureSize / 2, texturePaint);
            }
          }
        }
      }
    }
  }

  Color _getAverageStrokeColor() {
    if (brushStrokes.isEmpty) return Colors.black;

    double r = 0, g = 0, b = 0, a = 0;
    for (final stroke in brushStrokes) {
      r += stroke.color.r;
      g += stroke.color.g;
      b += stroke.color.b;
      a += stroke.opacity;
    }

    final count = brushStrokes.length;
    return Color.fromARGB(
      (255 * a / count).round(),
      (r / count).round(),
      (g / count).round(),
      (b / count).round(),
    );
  }

  @override
  bool shouldRepaint(covariant SimpleBrushPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        isExiting != oldDelegate.isExiting;
  }
}
