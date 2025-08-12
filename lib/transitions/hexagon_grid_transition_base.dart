// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/transition.dart';
import 'package:animated_transitions/enums.dart';

abstract class HexagonGridTransitionBase extends Transition {
  final Color? color;
  final List<Color>? colors;
  final double hexagonSize;

  HexagonGridTransitionBase({
    super.key,
    this.color = Colors.deepPurple,
    this.colors,
    this.hexagonSize = 40.0,
    super.duration = const Duration(milliseconds: 1000),
    super.exitMode = TransitionExitMode.reverse,
  });

  // Subclasses must provide a delay per tile in [0, 1]
  double computeDelay(int col, int row, int cols, int rows);

  @override
  State<HexagonGridTransitionBase> createState() =>
      _HexagonGridTransitionBaseState();
}

class _HexagonGridTransitionBaseState
    extends TransitionState<HexagonGridTransitionBase>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  Animation<double>? _animation;
  List<_HexagonTile> _hexagons = [];
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
      } else if (status == AnimationStatus.dismissed &&
          _isExiting &&
          (widget.exitMode == TransitionExitMode.reverse ||
              widget.exitMode == TransitionExitMode.sameDirection)) {
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
      case TransitionExitMode.sameDirection:
        _controller.reverse();
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

        // Calculate animation delay provided by subclass
        final rawDelay = widget.computeDelay(col, row, cols, rows);
        final delay = rawDelay.clamp(0.001, 0.999);
        final color = colors[(row * cols + col) % colors.length];

        _hexagons.add(_HexagonTile(
          center: Offset(x, y),
          size: hexSize,
          color: color,
          delay: delay,
        ));
      }
    }
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
              final double progress = _animation?.value ?? 0.0;

              final bool isReverseExit = _isExiting &&
                  (widget.exitMode == TransitionExitMode.reverse ||
                      widget.exitMode == TransitionExitMode.sameDirection);

              return CustomPaint(
                painter: HexagonGridPainter(
                  hexagons: _hexagons,
                  progress: progress,
                  isReverseExit: isReverseExit,
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

class _HexagonTile {
  final Offset center;
  final double size;
  final Color color;
  final double delay;

  _HexagonTile({
    required this.center,
    required this.size,
    required this.color,
    required this.delay,
  });
}

class HexagonGridPainter extends CustomPainter {
  final List<_HexagonTile> hexagons;
  final double progress;
  final bool isReverseExit;

  HexagonGridPainter({
    required this.hexagons,
    required this.progress,
    required this.isReverseExit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final hexagon in hexagons) {
      _paintHexagon(canvas, hexagon, size);
    }
  }

  void _paintHexagon(Canvas canvas, _HexagonTile hexagon, Size size) {
    // Entrance or reverse/sameDirection exit (both play controller in reverse)
    final double adjustedProgress =
        ((progress - hexagon.delay) / (1.0 - hexagon.delay)).clamp(0.0, 1.0);

    if (adjustedProgress <= 0) return;

    final paint = Paint()
      ..color = hexagon.color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(hexagon.center.dx, hexagon.center.dy);

    final slideProgress = Curves.easeOutCubic.transform(adjustedProgress);
    final slideDistance = hexagon.size * 2;
    final slideOffset = (1.0 - slideProgress) * slideDistance;
    canvas.translate(-slideOffset * 0.5, -slideOffset * 0.5);

    final path = _createHexagonPath(hexagon.size);
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = hexagon.color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, borderPaint);

    canvas.restore();
  }

  Path _createHexagonPath(double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
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
        hexagons != oldDelegate.hexagons;
  }
}
