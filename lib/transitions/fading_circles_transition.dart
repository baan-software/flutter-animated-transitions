// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animations/transition_animation.dart';

class FadingCirclesTransition extends TransitionAnimation {
  final int circleCount;
  final List<Color>? colors;

  FadingCirclesTransition({super.key, this.circleCount = 8, this.colors});

  @override
  State<FadingCirclesTransition> createState() => _FadingCirclesTransitionState();
}

class _FadingCirclesTransitionState extends TransitionAnimationState<FadingCirclesTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  final _random = Random();
  List<Offset> _positions = [];
  List<Animation<double>> _scaleAnimations = [];
  List<Animation<Color?>> _colorAnimations = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
      ..value = 1.0;

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

  void _setup(Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 3;

    _positions = List.generate(widget.circleCount, (i) {
      final angle = 2 * pi * i / widget.circleCount;
      return center + Offset(cos(angle), sin(angle)) * radius;
    });

    final durations = List.generate(widget.circleCount, (_) => 600 + _random.nextInt(400));
    final totalDuration = durations.reduce(max);
    _controller.duration = Duration(milliseconds: totalDuration);

    _scaleAnimations = List.generate(widget.circleCount, (i) {
      final start = 0.0;
      final end = durations[i] / totalDuration;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });

    final colorList = widget.colors ?? [Colors.blue, Colors.purple];
    final tweenItems = <TweenSequenceItem<Color?>>[];
    for (var i = 0; i < colorList.length - 1; i++) {
      tweenItems.add(TweenSequenceItem(
        tween: ColorTween(begin: colorList[i], end: colorList[i + 1]),
        weight: 1,
      ));
    }

    _colorAnimations = List.generate(widget.circleCount, (i) {
      final start = 0.0;
      final end = durations[i] / totalDuration;
      return TweenSequence<Color?>(tweenItems).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeIn),
        ),
      );
    });
  }

  void _play() {
    _controller.reset();
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
          if (_positions.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _setup(Size(constraints.maxWidth, constraints.maxHeight));
                _play();
                setState(() {});
              }
            });
            return const SizedBox();
          }

          return CustomPaint(
            painter: _CirclePainter(
              positions: _positions,
              scales: _scaleAnimations,
              colors: _colorAnimations,
              animation: _controller,
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          );
        },
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final List<Offset> positions;
  final List<Animation<double>> scales;
  final List<Animation<Color?>> colors;
  final Animation<double> animation;

  _CirclePainter({
    required this.positions,
    required this.scales,
    required this.colors,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < positions.length; i++) {
      final paint = Paint()..color = colors[i].value ?? Colors.black;
      final radius = 20.0 * scales[i].value;
      canvas.drawCircle(positions[i], radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
