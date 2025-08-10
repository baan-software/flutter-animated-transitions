// ignore_for_file: must_be_immutable

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:animated_transitions/transition.dart';
import 'package:animated_transitions/enums.dart';

/// CRT / TV shutoff style transition.
///
/// Entrance: mimics a CRT turning off – visible area collapses to a bright
/// line and then a dot while the overlay grows to cover the screen.
/// Exit (reverse and sameDirection): mimics a CRT turning on – expand from
/// dot to line to full screen, revealing the next page.
/// Exit (fade): fades the overlay like other transitions.
class CrtShutoffTransition extends Transition {
  /// Overlay color (typically black)
  final Color color;

  /// Highlight color for the bright line/dot at the end of shutoff
  final Color lineColor;

  /// Glow color for bloom/afterglow around the line/dot
  final Color glowColor;

  /// Split of time between vertical collapse and horizontal collapse phases.
  /// Must be between 0.1 and 0.9. Higher values spend more time collapsing
  /// vertically before the horizontal collapse.
  final double phaseSplit;

  /// Thickness of the horizontal highlight line (in logical pixels)
  final double lineThickness;

  /// Final dot radius (in logical pixels)
  final double dotRadius;

  /// Strength of the glow (sigma for blur)
  final double glowSigma;

  /// Duration of the afterglow linger at the end of the shutoff, before exit starts
  final Duration afterglowDuration;

  CrtShutoffTransition({
    super.key,
    this.color = Colors.black,
    this.lineColor = Colors.white,
    Color? glowColor,
    this.phaseSplit = 0.65,
    this.lineThickness = 3.0,
    this.dotRadius = 2.5,
    this.glowSigma = 6.0,
    this.afterglowDuration = const Duration(milliseconds: 280),
    super.duration = const Duration(milliseconds: 900),
    super.exitMode = TransitionExitMode.sameDirection,
  }) : glowColor = glowColor ?? lineColor;

  @override
  State<CrtShutoffTransition> createState() => _CrtShutoffTransitionState();
}

class _CrtShutoffTransitionState extends TransitionState<CrtShutoffTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late AnimationController _afterglowController;
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
      duration: widget.exitMode == TransitionExitMode.fade
          ? const Duration(milliseconds: 400)
          : widget.duration,
    )..value = 1.0;

    _afterglowController = AnimationController(
      vsync: this,
      duration: widget.afterglowDuration,
      value: 0.0,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isExiting) {
        // Linger at the dot with an afterglow before exiting
        // Animate afterglow from 1 -> 0
        _afterglowController.value = 1.0;
        _afterglowController.reverse().whenComplete(() {
          if (!mounted) return;
          widget.onAnimationComplete();
          _isExiting = true;
          if (widget.exitMode == TransitionExitMode.fade) {
            _fadeController.reverse();
          } else {
            _controller.reset();
            _controller.forward();
          }
        });
      } else if (status == AnimationStatus.completed && _isExiting) {
        // Shape-based exit finished
        if (widget.exitMode != TransitionExitMode.fade) {
          widget.onTransitionEnd();
        }
      }
    });

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed &&
          widget.exitMode == TransitionExitMode.fade) {
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final Size size = Size(constraints.maxWidth, constraints.maxHeight);
          return AnimatedBuilder(
            animation: Listenable.merge([_controller, _afterglowController]),
            builder: (context, child) {
              final double p = _controller.value;
              final double split = widget.phaseSplit.clamp(0.1, 0.9);
              final double afterglow = _afterglowController.value;

              // Map progress to visible rect factors (0..1) for width and height.
              // Entrance: collapse to dot (visible area shrinks)
              // Exit: expand from dot (visible area grows)
              double vWidthFactor;
              double vHeightFactor;

              if (!_isExiting) {
                // Faster vertical collapse, then slower horizontal collapse
                final double p1 = (p / split).clamp(0.0, 1.0);
                final double p2 = ((p - split) / (1 - split)).clamp(0.0, 1.0);
                final double vCollapse = Curves.easeInExpo.transform(p1);
                final double hCollapse = Curves.easeInCubic.transform(p2);
                vHeightFactor = 1.0 - vCollapse;
                vWidthFactor = 1.0 - hCollapse;
              } else {
                // On "turn on": quick bright flash (simulated via afterglow at start)
                final double p1 = (p / split).clamp(0.0, 1.0);
                final double p2 = ((p - split) / (1 - split)).clamp(0.0, 1.0);
                final double wExpand = Curves.easeOutCubic.transform(p1);
                final double hExpand = Curves.easeOutExpo.transform(p2);
                vWidthFactor = wExpand;
                vHeightFactor = hExpand;
              }

              // Convert to pixel sizes; keep a minimal thickness for line/dot visuals
              final double minLinePx = widget.lineThickness;
              double visibleWidth = size.width * vWidthFactor;
              double visibleHeight = size.height * vHeightFactor;
              if (visibleWidth > 0 && visibleWidth < minLinePx) {
                visibleWidth = minLinePx;
              }
              if (visibleHeight > 0 && visibleHeight < minLinePx) {
                visibleHeight = minLinePx;
              }

              return CustomPaint(
                size: size,
                painter: _CrtShutoffPainter(
                  overlayColor: widget.color,
                  lineColor: widget.lineColor,
                  glowColor: widget.glowColor,
                  glowSigma: widget.glowSigma,
                  lineThickness: widget.lineThickness,
                  dotRadius: widget.dotRadius,
                  visibleSize: Size(visibleWidth, visibleHeight),
                  afterglow: afterglow,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CrtShutoffPainter extends CustomPainter {
  final Color overlayColor;
  final Color lineColor;
  final Color glowColor;
  final Size visibleSize;
  final double glowSigma;
  final double lineThickness;
  final double dotRadius;
  final double afterglow;

  const _CrtShutoffPainter({
    required this.overlayColor,
    required this.lineColor,
    required this.glowColor,
    required this.visibleSize,
    required this.glowSigma,
    required this.lineThickness,
    required this.dotRadius,
    required this.afterglow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint overlayPaint = Paint()..color = overlayColor;

    final double visibleW = visibleSize.width.clamp(0.0, size.width);
    final double visibleH = visibleSize.height.clamp(0.0, size.height);

    final double left = (size.width - visibleW) / 2;
    final double top = (size.height - visibleH) / 2;

    // Draw overlay outside of the visible rectangle (four sides)
    // Top
    if (top > 0) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), overlayPaint);
    }
    // Bottom
    final double bottomTop = top + visibleH;
    if (bottomTop < size.height) {
      canvas.drawRect(
          Rect.fromLTWH(0, bottomTop, size.width, size.height - bottomTop),
          overlayPaint);
    }
    // Left
    if (left > 0 && visibleH > 0) {
      canvas.drawRect(Rect.fromLTWH(0, top, left, visibleH), overlayPaint);
    }
    // Right
    final double rightLeft = left + visibleW;
    if (rightLeft < size.width && visibleH > 0) {
      canvas.drawRect(
          Rect.fromLTWH(rightLeft, top, size.width - rightLeft, visibleH),
          overlayPaint);
    }

    // Draw highlight line/dot with optional glow
    final Paint highlight = Paint()..color = lineColor;

    // When nearly collapsed vertically, draw the horizontal line
    if (visibleH <= lineThickness && visibleW > dotRadius * 2) {
      final double y = size.height / 2 - (lineThickness / 2);

      // Glow pass
      if (afterglow > 0) {
        final Paint glow = Paint()
          ..color = glowColor.withValues(alpha: 0.6 * afterglow)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, glowSigma);
        canvas.drawRect(
          Rect.fromLTWH(left, y, visibleW, lineThickness),
          glow,
        );
      }

      // Core line
      canvas.drawRect(
        Rect.fromLTWH(left, y, visibleW, lineThickness),
        highlight,
      );
    }

    // When both width and height are tiny, draw a dot with glow
    if (visibleW <= dotRadius * 2 && visibleH <= dotRadius * 2) {
      final Offset c = Offset(size.width / 2, size.height / 2);

      if (afterglow > 0) {
        final Paint glow = Paint()
          ..color = glowColor.withValues(alpha: 0.8 * afterglow)
          ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, glowSigma);
        canvas.drawCircle(c, dotRadius, glow);
      }

      canvas.drawCircle(c, dotRadius, highlight);
    }
  }

  @override
  bool shouldRepaint(covariant _CrtShutoffPainter oldDelegate) {
    return oldDelegate.overlayColor != overlayColor ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.visibleSize != visibleSize;
  }
}
