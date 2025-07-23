// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/enums.dart';
import 'package:animated_transitions/transition.dart';

class GrowingBarsTransition extends Transition {
  final TransitionDirection direction;
  final List<Color>? colors;

  GrowingBarsTransition(
      {super.key,
      this.direction = TransitionDirection.bottom,
      this.colors});

  @override
  State<GrowingBarsTransition> createState() => GrowingBarsTransitionState();
}

class GrowingBarsTransitionState
    extends TransitionState<GrowingBarsTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  List<Animation<double>> _sizeAnimations = [];
  List<Animation<Color?>> _colorAnimations = [];
  List<Animation<double>> _thicknessAnimations = [];
  final int _barCount = 10;
  final _random = Random();
  Size? _lastSize;

  bool get _isHorizontal =>
      widget.direction == TransitionDirection.left ||
      widget.direction == TransitionDirection.right;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeController.value = 1.0; // Start fully opaque

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
        _fadeController.reverse();
      }
    });

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onTransitionEnd();
      }
    });
  }

  void _setupAnimations(double maxWidth, double maxHeight) {
    final double finalBarThickness =
        (_isHorizontal ? maxHeight : maxWidth) / _barCount;
    final double initialBarThickness = finalBarThickness * 0.5;

    const double baseDuration = 800; // ms
    const double durationVariation = 400; // ms
    final List<double> durations = List.generate(
      _barCount,
      (_) => baseDuration + _random.nextDouble() * durationVariation,
    );

    final double totalDuration = durations.reduce(max);
    _controller.duration = Duration(milliseconds: totalDuration.toInt());

    _thicknessAnimations = List.generate(
      _barCount,
      (index) {
        final start = 0.0;
        final end = durations[index] / totalDuration;
        return Tween<double>(begin: initialBarThickness, end: finalBarThickness)
            .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );
      },
    );

    _sizeAnimations = List.generate(
      _barCount,
      (index) {
        final start = 0.0;
        final end = durations[index] / totalDuration;
        return Tween<double>(
                begin: 0.0, end: _isHorizontal ? maxWidth : maxHeight)
            .animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        );
      },
    );

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

    _colorAnimations = List.generate(
      _barCount,
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
          if (newSize != _lastSize) {
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment:
                    widget.direction == TransitionDirection.left
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                children: List.generate(_barCount, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        width: _sizeAnimations[index].value,
                        height: _thicknessAnimations[index].value,
                        color: _colorAnimations[index].value,
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment:
                    widget.direction == TransitionDirection.bottom
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: List.generate(_barCount, (index) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        width: _thicknessAnimations[index].value,
                        height: _sizeAnimations[index].value,
                        color: _colorAnimations[index].value,
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