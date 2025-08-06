// ignore_for_file: must_be_immutable
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/enums.dart';
import 'package:animated_transitions/transition.dart';

class WhiteNoiseTransition extends Transition {
  final int pixelSize;

  WhiteNoiseTransition({
    super.key,
    super.duration = const Duration(milliseconds: 700),
    super.exitMode = TransitionExitMode.fade,
    int pixelSize = 4,
  }) : pixelSize = pixelSize < 4 ? 4 : pixelSize;

  @override
  State<WhiteNoiseTransition> createState() => _WhiteNoiseTransitionState();
}

class _WhiteNoiseTransitionState extends TransitionState<WhiteNoiseTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  late AnimationController _noiseController;
  late Animation<double> _fadeInAnimation;
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

    // Noise animation controller for continuous noise pattern changes
    _noiseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Fast refresh for noise
    );

    // Fade in for first 30% of duration, then full opacity
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutExpo),
      ),
    );

    // Set up animation listeners
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          _isExiting = true;
          _handleExitAnimation();
        });
      }
    });

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed &&
          widget.exitMode == TransitionExitMode.fade) {
        widget.onTransitionEnd();
      }
    });

    if (mounted) {
      _controller.forward();
      // Start continuous noise animation
      _noiseController.repeat();
    }
  }

  void _handleExitAnimation() {
    switch (widget.exitMode) {
      case TransitionExitMode.fade:
        _fadeController.reverse();
        break;
      case TransitionExitMode.reverse:
      case TransitionExitMode.sameDirection:
        // For reverse and sameDirection, fade out the noise smoothly
        _controller.reset();
        _controller.forward().then((_) {
          if (mounted) widget.onTransitionEnd();
        });
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _noiseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _noiseController]),
        builder: (context, child) {
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _WhiteNoisePainter(
              fadeProgress: _fadeInAnimation.value,
              noiseProgress: _noiseController.value,
              pixelSize: widget.pixelSize,
              isExiting: _isExiting,
              exitMode: widget.exitMode,
              mainProgress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _WhiteNoisePainter extends CustomPainter {
  final double fadeProgress;
  final double noiseProgress;
  final double mainProgress;
  final int pixelSize;
  final bool isExiting;
  final TransitionExitMode exitMode;
  late final Random _random;

  _WhiteNoisePainter({
    required this.fadeProgress,
    required this.noiseProgress,
    required this.mainProgress,
    required this.pixelSize,
    required this.isExiting,
    required this.exitMode,
  }) {
    // Use noise progress for animated pattern
    _random = Random((noiseProgress * 10000).floor());
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Calculate opacity based on phase and exit mode
    double opacity = _calculateOpacity();

    if (opacity <= 0) return;

    // Draw animated white noise pixels
    for (double y = 0; y < size.height; y += pixelSize) {
      for (double x = 0; x < size.width; x += pixelSize) {
        int gray = _random.nextInt(256);
        paint.color = Color.fromARGB(
          (255 * opacity).round(),
          gray,
          gray,
          gray,
        );
        canvas.drawRect(
          Rect.fromLTWH(x, y, pixelSize.toDouble(), pixelSize.toDouble()),
          paint,
        );
      }
    }
  }

  double _calculateOpacity() {
    if (!isExiting) {
      // Entrance: fade in for first 30%, then full opacity
      if (mainProgress <= 1.0) {
        return fadeProgress;
      } else {
        return 1.0; // Full opacity during "playing" phase
      }
    }

    switch (exitMode) {
      case TransitionExitMode.fade:
        return 1.0; // Handled by FadeTransition
      case TransitionExitMode.reverse:
      case TransitionExitMode.sameDirection:
        // Fade out smoothly during exit
        return 1.0 - mainProgress;
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteNoisePainter oldDelegate) {
    return fadeProgress != oldDelegate.fadeProgress ||
        noiseProgress != oldDelegate.noiseProgress ||
        mainProgress != oldDelegate.mainProgress ||
        isExiting != oldDelegate.isExiting;
  }
}
