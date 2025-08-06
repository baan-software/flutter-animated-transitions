// ignore_for_file: must_be_immutable
import 'dart:math';

import 'package:flutter/material.dart';

import '../enums.dart';
import '../transition.dart';

class RandomFinishBarsTransition extends Transition {
  final TransitionDirection direction;
  final List<Color>? colors;

  RandomFinishBarsTransition({
    super.key,
    this.direction = TransitionDirection.bottom,
    this.colors,
    super.duration = const Duration(milliseconds: 500),
    super.exitMode = TransitionExitMode.sameDirection,
  });

  @override
  RandomFinishBarsTransitionState createState() =>
      RandomFinishBarsTransitionState();
}

class RandomFinishBarsTransitionState
    extends TransitionState<RandomFinishBarsTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  List<Animation<double>> _sizeAnimations = [];
  List<Animation<Color?>> _colorAnimations = [];
  List<double> _barThicknesses = [];
  final int _barCount = 50;
  final _random = Random();
  Size? _lastSize;
  bool _isExiting = false;
  List<double>? _storedDurations; // Store durations for consistent exit
  List<double>? _storedThicknesses; // Store thicknesses for consistent exit

  bool get _isHorizontal =>
      widget.direction == TransitionDirection.left ||
      widget.direction == TransitionDirection.right;

  // Get the effective direction for the current animation phase
  TransitionDirection get _effectiveDirection {
    return (!_isExiting || widget.exitMode == TransitionExitMode.reverse)
        ? widget.direction
        : _getOppositeDirection(widget.direction);
  }

  TransitionDirection _getOppositeDirection(TransitionDirection direction) {
    switch (direction) {
      case TransitionDirection.left:
        return TransitionDirection.right;
      case TransitionDirection.right:
        return TransitionDirection.left;
      case TransitionDirection.top:
        return TransitionDirection.bottom;
      case TransitionDirection.bottom:
        return TransitionDirection.top;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _fadeController = AnimationController(
      vsync: this,
      duration: widget.exitMode == TransitionExitMode.fade
          ? const Duration(milliseconds: 400)
          : widget.duration,
    );
    _fadeController.value = 1.0;

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
    // 1. Use stored thicknesses for exit, or generate new ones for entrance
    if (_isExiting && _storedThicknesses != null) {
      _barThicknesses = _storedThicknesses!;
    } else {
      final proportions = List.generate(_barCount, (_) => _random.nextDouble());
      final totalProportion = proportions.reduce((a, b) => a + b);
      _barThicknesses = proportions
          .map(
            (p) => p / totalProportion * (_isHorizontal ? maxHeight : maxWidth),
          )
          .toList();
      if (!_isExiting) {
        _storedThicknesses = List.from(_barThicknesses); // Store for exit phase
      }
    }

    // 2. Use stored durations for exit, or generate new ones for entrance
    final List<double> durations;
    if (_isExiting && _storedDurations != null) {
      durations = _storedDurations!;
    } else {
      int baseDuration = widget.duration.inMilliseconds;
      double durationVariation = widget.duration.inMilliseconds / 2.0;
      durations = List.generate(
        _barCount,
        (_) => baseDuration + _random.nextDouble() * durationVariation,
      );
      if (!_isExiting) {
        _storedDurations = List.from(durations); // Store for exit phase
      }
    }

    final double totalDuration = durations.reduce(max);
    _controller.duration = Duration(milliseconds: totalDuration.toInt());

    // 3. Create animations
    _sizeAnimations = List.generate(_barCount, (index) {
      final start = 0.0;
      final end = durations[index] / totalDuration;
      final maxSize = _isHorizontal ? maxWidth : maxHeight;

      // For exit animations, bars shrink from full size to 0
      final begin = _isExiting ? maxSize : 0.0;
      final endSize = _isExiting ? 0.0 : maxSize;
      final curve = _isExiting ? Curves.easeIn : Curves.easeOut;

      return Tween<double>(begin: begin, end: endSize).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: curve),
        ),
      );
    });

    final List<Color> animationColors;
    final colors = widget.colors;
    if (colors == null) {
      animationColors = [Colors.white, Colors.lightBlue.shade300];
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

    _colorAnimations = List.generate(_barCount, (index) {
      final start = 0.0;
      final end = durations[index] / totalDuration;
      return TweenSequence<Color?>(tweenItems).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeIn),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _playAnimation() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final newSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (newSize != _lastSize && !_isExiting) {
            // Only setup on size change during entrance
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

          if (_isHorizontal) {
            return SizedBox(
              width: constraints.maxWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    _effectiveDirection == TransitionDirection.left
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                children: List.generate(_barCount, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Align(
                        alignment:
                            _effectiveDirection == TransitionDirection.left
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                        child: Container(
                          width: _sizeAnimations[index].value,
                          height: _barThicknesses[index],
                          color: _colorAnimations[index].value,
                        ),
                      );
                    },
                  );
                }),
              ),
            );
          } else {
            return SizedBox(
              height: constraints.maxHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    _effectiveDirection == TransitionDirection.bottom
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: List.generate(_barCount, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Align(
                        alignment:
                            _effectiveDirection == TransitionDirection.bottom
                                ? Alignment.bottomCenter
                                : Alignment.topCenter,
                        child: Container(
                          width: _barThicknesses[index],
                          height: _sizeAnimations[index].value,
                          color: _colorAnimations[index].value,
                        ),
                      );
                    },
                  );
                }),
              ),
            );
          }
        },
      ),
    );
  }
}
