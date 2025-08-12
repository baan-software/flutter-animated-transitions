// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/enums.dart';
import 'package:animated_transitions/transition.dart';

class SunburstTransition extends Transition {
  final List<Color>? colors;

  SunburstTransition({
    super.key,
    this.colors,
    super.duration = const Duration(milliseconds: 800),
    super.exitMode = TransitionExitMode.fade,
  }) {
    if (exitMode == TransitionExitMode.sameDirection) {
      debugPrint('Same direction exit mode is not supported for SunburstTransition');
    }
  }

  @override
  State<SunburstTransition> createState() => SunburstTransitionState();
}

class SunburstTransitionState extends TransitionState<SunburstTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  List<Animation<double>> _sizeAnimations = [];
  List<Animation<Color?>> _colorAnimations = [];
  Size? _lastSize;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: widget.exitMode == TransitionExitMode.fade
          ? const Duration(milliseconds: 400)
          : widget.duration,
    );
    _fadeController.value = 1.0; // Start fully opaque

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          _isExiting = true;
          if (widget.exitMode == TransitionExitMode.fade) {
            _fadeController.reverse();
          } else {
            _setupAnimations(_lastSize!.width, _lastSize!.height);
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

  void _setupAnimations(double maxWidth, double maxHeight) {
    final rayCount = 24;
    final centerX = maxWidth / 2;
    final centerY = maxHeight / 2;
    final maxDistance = sqrt(centerX * centerX + centerY * centerY);

    _controller.duration = widget.duration;
    _sizeAnimations = List.generate(
      rayCount,
      (index) {
        final start = 0.0;
        final end = 1.0;
        
        final begin = _isExiting ? maxDistance : 0.0;
        final endSize = _isExiting ? 0.0 : maxDistance;
        final curve = _isExiting ? Curves.easeIn : Curves.easeOut;

        return Tween<double>(begin: begin, end: endSize).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: curve),
          ),
        );
      },
    );

    // Color animations
    final List<Color> animationColors;
    final colors = widget.colors;
    if (colors == null) {
      animationColors = [Colors.white, Colors.white];
    } else if (colors.length == 1) {
      animationColors = [colors[0], colors[0]];
    } else {
      animationColors = colors;
    }

    final tweenItems = <TweenSequenceItem<Color?>>[];

    if (_isExiting && widget.exitMode != TransitionExitMode.fade) {
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

    _colorAnimations = List.generate(
      rayCount,
      (index) {
        return TweenSequence<Color?>(tweenItems).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeIn,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _playAnimation() {
    if (_isExiting) {
      switch (widget.exitMode) {
        case TransitionExitMode.fade:
          // For fade, we only animate the fade controller
          _fadeController.animateTo(0.0, duration: widget.duration);
          break;
        case TransitionExitMode.reverse:
          // For reverse, animate the main controller backwards
          _controller.reverse();
          break;
        case TransitionExitMode.sameDirection:
          // For same direction, animate the main controller forwards (continues expanding)
          _controller.forward();
          break;
      }
    } else {
      // Normal entrance animation
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final newSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (newSize != _lastSize && !_isExiting) {
            _lastSize = newSize;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _setupAnimations(constraints.maxWidth, constraints.maxHeight);
                _playAnimation();
                setState(() {});
              }
            });
          }

          if (_sizeAnimations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final centerX = constraints.maxWidth / 2;
          final centerY = constraints.maxHeight / 2;
          final rayCount = 24; // Increased to 24 rays for better coverage
          
          // Calculate the maximum distance from center to any corner
          final maxDistance = sqrt(centerX * centerX + centerY * centerY);

          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: List.generate(rayCount, (index) {
                // Calculate angle for each bar (evenly distributed in 360 degrees)
                final angle = (2 * pi * index) / rayCount;
                
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final progress = _sizeAnimations[index].value;
                    final currentSize = maxDistance * (progress / maxDistance);
                    
                    // Non-linear width expansion: slow start, fast end for complete coverage
                    final progressRatio = progress / maxDistance;
                    final widthFactor = progressRatio * progressRatio * 0.3; // Quadratic growth for acceleration
                    final barWidth = 1.0 + (currentSize * widthFactor);
                    final barHeight = currentSize * 2.0; // Keep 100% extension for coverage
                    
                    return Positioned(
                      left: centerX - barWidth / 2,
                      top: centerY - barHeight / 2,
                      child: Transform.rotate(
                        angle: angle,
                        alignment: Alignment.center,
                        child: Container(
                          width: barWidth,
                          height: barHeight,
                          color: _colorAnimations[index].value,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          );
        },
      ),
    );
  }
} 