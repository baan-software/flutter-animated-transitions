// A clock-like radial sweep transition that reveals content clockwise like a ticking clock hand

// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:animated_transitions/transition.dart';
import 'package:animated_transitions/enums.dart';

class ClockSweepTransition extends Transition {
  final Color? color;
  final List<Color>? colors;
  final bool clockwise;

  ClockSweepTransition({
    super.key,
    this.color = Colors.deepPurple,
    this.colors,
    this.clockwise = true,
    super.duration = const Duration(milliseconds: 1000),
    super.exitMode = TransitionExitMode.reverse,
  });

  @override
  State<ClockSweepTransition> createState() => _ClockSweepTransitionState();
}

class _ClockSweepTransitionState extends TransitionState<ClockSweepTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  Animation<double>? _sweepAnimation;
  Animation<double>? _fadeAnimation;
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
      duration: const Duration(milliseconds: 300),
    );

    _sweepAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi, // Full circle in radians
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_fadeController);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isExiting) {
        widget.onAnimationComplete();
        // Auto-trigger exit animation after a short delay
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          exit();
        });
      } else if (status == AnimationStatus.completed && _isExiting) {
        widget.onTransitionEnd();
      } else if (status == AnimationStatus.dismissed && _isExiting) {
        widget.onTransitionEnd();
      }
    });

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isExiting) {
        widget.onTransitionEnd();
      }
    });

    // Start the animation
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
        // Fade out the overlay while keeping the sweep at full
        // Don't animate the main controller during fade
        _fadeController.forward();
        break;
      case TransitionExitMode.reverse:
        // Reverse the sweep animation (clock hand goes backward)
        _controller.reverse();
        break;
      case TransitionExitMode.sameDirection:
        // For now, same as reverse
        _controller.reverse();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // For fade exit mode, only listen to fade controller
    if (_isExiting && widget.exitMode == TransitionExitMode.fade) {
      return AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: 1.0 - (_fadeAnimation?.value ?? 0.0),
            child: ClipPath(
              clipper: ClockSweepClipper(
                sweepAngle: 2 * pi, // Full sweep
                clockwise: widget.clockwise,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: _buildDecoration(2 * pi), // Use final color
              ),
            ),
          );
        },
      );
    }

    // For all other modes, use main controller
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double currentSweepAngle = _sweepAnimation?.value ?? 0.0;

        return ClipPath(
          clipper: ClockSweepClipper(
            sweepAngle: currentSweepAngle,
            clockwise: widget.clockwise,
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: _buildDecoration(currentSweepAngle),
          ),
        );
      },
    );
  }

  BoxDecoration _buildDecoration(double sweepAngle) {
    if (widget.colors != null && widget.colors!.isNotEmpty) {
      // Progress through colors linearly from first to last (no cycling back)
      final animationProgress = sweepAngle / (2 * pi);
      final colorProgress = animationProgress * (widget.colors!.length - 1);
      final colorIndex =
          colorProgress.floor().clamp(0, widget.colors!.length - 2);
      final nextColorIndex =
          (colorIndex + 1).clamp(0, widget.colors!.length - 1);
      final segmentProgress = colorProgress - colorIndex;

      // Interpolate between current and next color
      final currentColor = widget.colors![colorIndex];
      final nextColor = widget.colors![nextColorIndex];
      final interpolatedColor =
          Color.lerp(currentColor, nextColor, segmentProgress) ?? currentColor;

      return BoxDecoration(
        color: interpolatedColor,
      );
    } else {
      // Use solid color
      return BoxDecoration(
        color: widget.color,
      );
    }
  }
}

class ClockSweepClipper extends CustomClipper<Path> {
  final double sweepAngle;
  final bool clockwise;

  ClockSweepClipper({
    required this.sweepAngle,
    this.clockwise = true,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    if (sweepAngle <= 0) {
      return path; // Empty path - no overlay shown
    }

    if (sweepAngle >= 2 * pi) {
      // Full sweep - show entire overlay
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    final centerPoint = Offset(size.width / 2, size.height / 2);
    final radius = sqrt(pow(size.width, 2) + pow(size.height, 2));

    // Start angle at 12 o'clock position (-π/2 radians)
    final startAngle = -pi / 2;

    // Create the swept area
    path.moveTo(centerPoint.dx, centerPoint.dy);
    path.arcTo(
      Rect.fromCircle(center: centerPoint, radius: radius),
      startAngle,
      clockwise ? sweepAngle : -sweepAngle,
      false,
    );
    path.close();

    return path;
  }

  @override
  bool shouldReclip(ClockSweepClipper oldClipper) {
    return oldClipper.sweepAngle != sweepAngle ||
        oldClipper.clockwise != clockwise;
  }
}
