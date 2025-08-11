// A spiral transition that reveals content in a spiral pattern from center outward

// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/transition.dart';
import 'package:animated_transitions/enums.dart';

class SpiralTransition extends Transition {
  final Color? color;
  final List<Color>? colors;
  final bool clockwise;
  final double spiralTightness;
  final int spiralTurns;

  SpiralTransition({
    super.key,
    this.color = Colors.deepPurple,
    this.colors,
    this.clockwise = true,
    this.spiralTightness = 1.0, // 1.0 = normal, < 1.0 = tighter, > 1.0 = looser
    this.spiralTurns = 3, // Number of complete turns in the spiral
    super.duration = const Duration(milliseconds: 1200),
    super.exitMode = TransitionExitMode.reverse,
  });

  @override
  State<SpiralTransition> createState() => _SpiralTransitionState();
}

class _SpiralTransitionState extends TransitionState<SpiralTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  Animation<double>? _spiralAnimation;
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
    _fadeController.value = 1.0;

    _spiralAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isExiting) {
        widget.onAnimationComplete();
        // Auto-trigger exit animation after a short delay
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
        _fadeController.reverse();
        break;
      case TransitionExitMode.reverse:
      case TransitionExitMode.sameDirection:
        _controller.reverse();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double progress = _spiralAnimation?.value ?? 0.0;

          return ClipPath(
            clipper: SpiralClipper(
              progress: progress,
              clockwise: widget.clockwise,
              spiralTightness: widget.spiralTightness,
              spiralTurns: widget.spiralTurns,
              isExiting: _isExiting,
              exitMode: widget.exitMode,
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: _buildDecoration(progress),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _buildDecoration(double progress) {
    if (widget.colors != null && widget.colors!.isNotEmpty) {
      // Progress through colors based on spiral progress
      final colorProgress = progress * (widget.colors!.length - 1);
      final colorIndex =
          colorProgress.floor().clamp(0, widget.colors!.length - 2);
      final nextColorIndex =
          (colorIndex + 1).clamp(0, widget.colors!.length - 1);
      final segmentProgress = colorProgress - colorIndex;

      final currentColor = widget.colors![colorIndex];
      final nextColor = widget.colors![nextColorIndex];
      final interpolatedColor =
          Color.lerp(currentColor, nextColor, segmentProgress) ?? currentColor;

      return BoxDecoration(color: interpolatedColor);
    } else {
      return BoxDecoration(color: widget.color);
    }
  }
}

class SpiralClipper extends CustomClipper<Path> {
  final double progress;
  final bool clockwise;
  final double spiralTightness;
  final int spiralTurns;
  final bool isExiting;
  final TransitionExitMode exitMode;

  SpiralClipper({
    required this.progress,
    this.clockwise = true,
    this.spiralTightness = 1.0,
    this.spiralTurns = 3,
    this.isExiting = false,
    this.exitMode = TransitionExitMode.reverse,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    // Handle edge cases depending on phase/mode
    if (!isExiting) {
      if (progress <= 0) {
        return path; // Empty path - no overlay shown
      }
      if (progress >= 1.0) {
        path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
        return path;
      }
    } else {
      if (exitMode == TransitionExitMode.reverse ||
          exitMode == TransitionExitMode.sameDirection) {
        if (progress <= 0) {
          return path; // Done
        }
        if (progress >= 1.0) {
          path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
          return path;
        }
      } else if (exitMode == TransitionExitMode.fade) {
        // For fade, clipping remains as last entrance state; handled by opacity
      }
    }

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = sqrt(pow(size.width / 2, 2) + pow(size.height / 2, 2));

    // Calculate how much of the spiral to draw based on progress
    final totalAngle = spiralTurns * 2 * pi;
    final currentAngle = progress * totalAngle;

    final numSectors = 120; // Number of sectors to create smooth spiral

    double drawStartAngle;
    double drawSpanAngle;

    if (!isExiting ||
        exitMode == TransitionExitMode.reverse ||
        exitMode == TransitionExitMode.sameDirection) {
      // Entrance and reverse-exit: draw from 0 → currentAngle
      drawStartAngle = 0.0;
      drawSpanAngle = currentAngle;
    } else {
      // SameDirection exit: draw remaining part from currentAngle → totalAngle
      drawStartAngle = currentAngle;
      drawSpanAngle = (totalAngle - currentAngle).clamp(0.0, totalAngle);
    }

    final sectorAngle = (drawSpanAngle <= 0) ? 0.0 : drawSpanAngle / numSectors;

    for (int sector = 0; sector < numSectors; sector++) {
      final startAngle = drawStartAngle + sector * sectorAngle;
      final endAngle = drawStartAngle + (sector + 1) * sectorAngle;

      if (sectorAngle <= 0) break;

      // Calculate radius for this sector based on spiral equation
      final startRadius =
          (startAngle / totalAngle) * maxRadius * spiralTightness;
      final endRadius = (endAngle / totalAngle) * maxRadius * spiralTightness;

      final sectorPath = Path();
      sectorPath.moveTo(center.dx, center.dy);

      final rect = Rect.fromCircle(center: center, radius: endRadius);
      sectorPath.arcTo(
        rect,
        clockwise ? startAngle - pi / 2 : -(startAngle - pi / 2),
        clockwise ? sectorAngle : -sectorAngle,
        false,
      );
      sectorPath.close();

      if (startRadius > 0) {
        path.addPath(sectorPath, Offset.zero);
      }
    }

    return path;
  }

  @override
  bool shouldReclip(SpiralClipper oldClipper) {
    return oldClipper.progress != progress ||
        oldClipper.clockwise != clockwise ||
        oldClipper.spiralTightness != spiralTightness ||
        oldClipper.spiralTurns != spiralTurns ||
        oldClipper.isExiting != isExiting;
  }
}
