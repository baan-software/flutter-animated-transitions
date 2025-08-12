// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/enums.dart';
import 'package:animated_transitions/transition.dart';

class CrossingBarsTransition extends Transition {
  final TransitionDirection direction;
  final List<Color>? colors;
  final int barCount;

  CrossingBarsTransition({
    super.key,
    this.direction = TransitionDirection.bottom,
    this.colors,
    this.barCount = 10,
    super.duration = const Duration(milliseconds: 800),
    super.exitMode = TransitionExitMode.sameDirection,
  });

  @override
  State<CrossingBarsTransition> createState() => CrossingBarsTransitionState();
}

class CrossingBarsTransitionState extends TransitionState<CrossingBarsTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  List<Animation<double>> _sizeAnimations = [];
  List<Animation<Color?>> _colorAnimations = [];
  final _random = Random();
  Size? _lastSize;
  bool _isExiting = false;
  List<double>? _storedDurations;

  bool get _isHorizontal =>
      widget.direction == TransitionDirection.left ||
      widget.direction == TransitionDirection.right;

  // Get the effective direction for the current animation phase
  TransitionDirection get _effectiveDirection {
    if (!_isExiting) {
      return widget.direction;
    }
    
    switch (widget.exitMode) {
      case TransitionExitMode.reverse:
        return _getOppositeDirection(widget.direction);
      case TransitionExitMode.sameDirection:
        return widget.direction; // Keep same direction
      case TransitionExitMode.fade:
        return widget.direction; // Not used for fade
    }
  }

  // Get direction for each bar (alternating)
  TransitionDirection _getBarDirection(int barIndex) {
    final baseDirection = _effectiveDirection;
    final isEvenBar = barIndex % 2 == 0;
    
    if (isEvenBar) {
      return baseDirection;
    } else {
      return _getOppositeDirection(baseDirection);
    }
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
    // Use stored durations for exit, or generate new ones for entrance
    final List<double> durations;
    if (_isExiting && _storedDurations != null) {
      durations = _storedDurations!;
    } else {
      int baseDuration = widget.duration.inMilliseconds;
      double durationVariation = widget.duration.inMilliseconds / 2.0;
      durations = List.generate(
        widget.barCount,
        (_) => baseDuration + _random.nextDouble() * durationVariation,
      );
      if (!_isExiting) {
        _storedDurations = durations;
      }
    }

    final double totalDuration = durations.reduce(max);
    _controller.duration = Duration(milliseconds: totalDuration.toInt());

    // Create size animations for each bar (expanding from sides)
    _sizeAnimations = List.generate(
      widget.barCount,
      (index) {
        final start = 0.0;
        final end = durations[index] / totalDuration;
        final barDirection = _getBarDirection(index);
        
        // Calculate start and end sizes based on direction
        double startSize;
        double endSize;
        
        if (_isHorizontal) {
          // Horizontal bars (left/right direction)
          if (barDirection == TransitionDirection.left) {
            startSize = 0.0; // Start empty
            endSize = 1.0; // Expand to full width
          } else {
            startSize = 0.0; // Start empty
            endSize = 1.0; // Expand to full width
          }
        } else {
          // Vertical bars (top/bottom direction)
          if (barDirection == TransitionDirection.top) {
            startSize = 0.0; // Start empty
            endSize = 1.0; // Expand to full height
          } else {
            startSize = 0.0; // Start empty
            endSize = 1.0; // Expand to full height
          }
        }

        // For exit animations, reverse the sizes
        if (_isExiting) {
          final temp = startSize;
          startSize = endSize;
          endSize = temp;
        }

        return Tween<double>(
          begin: startSize,
          end: endSize,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut),
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

    _colorAnimations = List.generate(
      widget.barCount,
      (index) {
        final start = 0.0;
        final end = durations[index] / totalDuration;
        return TweenSequence<Color?>(tweenItems).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeIn),
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

          final double barThickness = (_isHorizontal ? constraints.maxHeight : constraints.maxWidth) / widget.barCount;
          final double barLength = _isHorizontal ? constraints.maxWidth : constraints.maxHeight;

          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: List.generate(widget.barCount, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final size = _sizeAnimations[index].value;
                    final barDirection = _getBarDirection(index);
                    
                    // Calculate position and size based on direction
                    double left, top, width, height;
                    
                    if (_isHorizontal) {
                      // Horizontal bars expanding from sides
                      if (barDirection == TransitionDirection.left) {
                        // Expand from left to right
                        if (_isExiting && widget.exitMode == TransitionExitMode.sameDirection) {
                          // For sameDirection exit, shrink from left to right
                          left = barLength * (1 - size);
                          top = index * barThickness;
                          width = barLength * size;
                          height = barThickness;
                        } else if (_isExiting && widget.exitMode == TransitionExitMode.reverse) {
                          // For reverse exit, shrink from right to left (opposite direction)
                          left = barLength * (1 - size);
                          top = index * barThickness;
                          width = barLength * size;
                          height = barThickness;
                        } else {
                          // Normal entrance
                          left = 0;
                          top = index * barThickness;
                          width = barLength * size;
                          height = barThickness;
                        }
                      } else {
                        // Expand from right to left
                        if (_isExiting && widget.exitMode == TransitionExitMode.sameDirection) {
                          // For sameDirection exit, shrink from right to left
                          left = 0;
                          top = index * barThickness;
                          width = barLength * size;
                          height = barThickness;
                        } else if (_isExiting && widget.exitMode == TransitionExitMode.reverse) {
                          // For reverse exit, shrink from left to right (opposite direction)
                          left = 0;
                          top = index * barThickness;
                          width = barLength * size;
                          height = barThickness;
                        } else {
                          // Normal entrance or reverse exit
                          left = barLength * (1 - size);
                          top = index * barThickness;
                          width = barLength * size;
                          height = barThickness;
                        }
                      }
                    } else {
                      // Vertical bars expanding from top/bottom
                      if (barDirection == TransitionDirection.top) {
                        // Expand from top to bottom
                        if (_isExiting && widget.exitMode == TransitionExitMode.sameDirection) {
                          // For sameDirection exit, shrink from top to bottom
                          left = index * barThickness;
                          top = 0;
                          width = barThickness;
                          height = barLength * size;
                        } else if (_isExiting && widget.exitMode == TransitionExitMode.reverse) {
                          // For reverse exit, shrink from bottom to top (opposite direction)
                          left = index * barThickness;
                          top = 0;
                          width = barThickness;
                          height = barLength * size;
                        } else {
                          // Normal entrance
                          left = index * barThickness;
                          top = 0;
                          width = barThickness;
                          height = barLength * size;
                        }
                      } else {
                        // Expand from bottom to top
                        if (_isExiting && widget.exitMode == TransitionExitMode.sameDirection) {
                          // For sameDirection exit, shrink from bottom to top
                          left = index * barThickness;
                          top = barLength * (1 - size);
                          width = barThickness;
                          height = barLength * size;
                        } else if (_isExiting && widget.exitMode == TransitionExitMode.reverse) {
                          // For reverse exit, shrink from top to bottom (opposite direction)
                          left = index * barThickness;
                          top = barLength * (1 - size);
                          width = barThickness;
                          height = barLength * size;
                        } else {
                          // Normal entrance
                          left = index * barThickness;
                          top = barLength * (1 - size);
                          width = barThickness;
                          height = barLength * size;
                        }
                      }
                    }
                    
                    return Positioned(
                      left: left,
                      top: top,
                      child: Container(
                        width: width,
                        height: height,
                        color: _colorAnimations[index].value,
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
