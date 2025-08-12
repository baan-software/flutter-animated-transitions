// A hexagon grid transition that reveals content through hexagonal tiles that flip or slide

// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/transition.dart';
import 'package:animated_transitions/enums.dart';

class HexagonGridTransition extends Transition {
  final Color? color;
  final List<Color>? colors;
  final TransitionDirection direction;
  final double hexagonSize;

  HexagonGridTransition({
    super.key,
    this.color = Colors.deepPurple,
    this.colors,
    this.direction = TransitionDirection.bottom,
    this.hexagonSize = 40.0,
    super.duration = const Duration(milliseconds: 500),
    super.exitMode = TransitionExitMode.reverse,
  });

  @override
  State<HexagonGridTransition> createState() => _HexagonGridTransitionState();
}

class _HexagonGridTransitionState extends TransitionState<HexagonGridTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  Animation<double>? _animation;
  final List<HexagonTile> _hexagons = [];
  Size? _lastSize;
  bool _isExiting = false;

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
    );
    _fadeController.value = 1.0; // Start fully opaque

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isExiting) {
        widget.onAnimationComplete();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          exit();
        });
      } else if (status == AnimationStatus.completed &&
          _isExiting &&
          widget.exitMode == TransitionExitMode.sameDirection) {
        widget.onTransitionEnd();
      } else if (status == AnimationStatus.dismissed &&
          _isExiting &&
          widget.exitMode == TransitionExitMode.reverse) {
        widget.onTransitionEnd();
      }
    });

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && _isExiting) {
        widget.onTransitionEnd();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void exit() {
    if (_isExiting) return;
    _isExiting = true;

    switch (widget.exitMode) {
      case TransitionExitMode.fade:
        _fadeController.reverse();
        break;
      case TransitionExitMode.reverse:
        _controller.reverse();
        break;
      case TransitionExitMode.sameDirection:
        _controller.reset();
        _controller.forward();
        break;
    }
  }

  void _setupHexagons(Size size) {
    if (_lastSize == size && _hexagons.isNotEmpty) return;
    _lastSize = size;
    _hexagons.clear();

    final hexSize = widget.hexagonSize;
    // For perfect tessellation, we need the correct spacing
    final hexWidth =
        hexSize * sqrt(3); // Distance between hex centers horizontally
    final hexHeight = hexSize * 1.5; // Distance between hex centers vertically

    // Calculate how many hexagons we need to cover the screen (with extra margin)
    final cols = (size.width / hexWidth).ceil() + 3;
    final rows = (size.height / hexHeight).ceil() + 3;

    final colors = widget.colors ?? [widget.color ?? Colors.deepPurple];

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        // Offset every other row for proper hexagon tessellation
        final offsetX = (row % 2) * (hexWidth / 2);
        final x = col * hexWidth + offsetX - hexSize;
        final y = row * hexHeight - hexSize;

        // Calculate animation delay based on direction
        final delay = _calculateDelay(col, row, cols, rows);
        final color = colors[(row * cols + col) % colors.length];

        _hexagons.add(HexagonTile(
          center: Offset(x, y),
          size: hexSize,
          color: color,
          delay: delay,
        ));
      }
    }
  }

  double _calculateDelay(int col, int row, int cols, int rows) {
    double normalizedDelay = 0.0;

    // Always use the original direction for delay calculation
    switch (widget.direction) {
      case TransitionDirection.top:
        normalizedDelay = row / rows;
        break;
      case TransitionDirection.bottom:
        normalizedDelay = (rows - row - 1) / rows;
        break;
      case TransitionDirection.left:
        normalizedDelay = col / cols;
        break;
      case TransitionDirection.right:
        normalizedDelay = (cols - col - 1) / cols;
        break;
    }

    // Add some randomness for organic feel
    final random = Random((col * 1000 + row).toInt());
    normalizedDelay += random.nextDouble() * 0.1;

    // Clamp delay to avoid division by zero or degenerate intervals
    return normalizedDelay.clamp(0.001, 0.999);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          _setupHexagons(size);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double progress = _animation?.value ?? 0.0;

              // Only reverse mode uses reverse animation
              bool isReverseExit =
                  _isExiting && widget.exitMode == TransitionExitMode.reverse;
              bool isSameDirectionExit = _isExiting &&
                  widget.exitMode == TransitionExitMode.sameDirection;

              return CustomPaint(
                painter: HexagonGridPainter(
                  hexagons: _hexagons,
                  progress: progress,
                  isReverseExit: isReverseExit,
                  isSameDirectionExit: isSameDirectionExit,
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

class HexagonTile {
  final Offset center;
  final double size;
  final Color color;
  final double delay;

  HexagonTile({
    required this.center,
    required this.size,
    required this.color,
    required this.delay,
  });
}

class HexagonGridPainter extends CustomPainter {
  final List<HexagonTile> hexagons;
  final double progress;
  final bool isReverseExit;
  final bool isSameDirectionExit;

  HexagonGridPainter({
    required this.hexagons,
    required this.progress,
    required this.isReverseExit,
    required this.isSameDirectionExit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final hexagon in hexagons) {
      _paintHexagon(canvas, hexagon, size);
    }
  }

  void _paintHexagon(Canvas canvas, HexagonTile hexagon, Size size) {
    // Calculate if this hexagon should be visible based on progress and delay
    double adjustedProgress;

    if (isSameDirectionExit) {
      // For sameDirection, tiles should disappear in the same order they appeared.
      // Make each tile's end time equal to its own delay (earlier delay → earlier disappear).
      // adjustedProgress goes from 1 → 0 over the interval [0, delay].
      adjustedProgress = 1.0 - (progress / hexagon.delay).clamp(0.0, 1.0);
    } else {
      // Normal entrance or reverse exit
      adjustedProgress =
          ((progress - hexagon.delay) / (1.0 - hexagon.delay)).clamp(0.0, 1.0);
    }

    if (adjustedProgress <= 0) return;

    final paint = Paint()
      ..color = hexagon.color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(hexagon.center.dx, hexagon.center.dy);

    // Slide animation - slide in from direction
    final slideProgress = Curves.easeOutCubic.transform(adjustedProgress);
    final slideDistance = hexagon.size * 2;

    // Note: Direction is handled by delay calculation, so we slide from center
    final slideOffset = (1.0 - slideProgress) * slideDistance;
    canvas.translate(-slideOffset * 0.5, -slideOffset * 0.5);

    // Draw hexagon
    final path = _createHexagonPath(hexagon.size);
    canvas.drawPath(path, paint);

    // Add subtle border
    final borderPaint = Paint()
      ..color = hexagon.color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, borderPaint);

    canvas.restore();
  }

  Path _createHexagonPath(double size) {
    final path = Path();
    // Create a regular hexagon with flat top/bottom orientation
    for (int i = 0; i < 6; i++) {
      // Start from top and go clockwise, with flat top
      final angle = (i * 60.0 - 90.0) * pi / 180.0;
      final x = size * cos(angle);
      final y = size * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant HexagonGridPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        isReverseExit != oldDelegate.isReverseExit ||
        isSameDirectionExit != oldDelegate.isSameDirectionExit ||
        hexagons != oldDelegate.hexagons;
  }
}
