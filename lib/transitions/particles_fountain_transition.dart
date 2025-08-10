// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/transition.dart';
import 'package:animated_transitions/enums.dart';

class ParticlesFountainTransition extends Transition {
  final Color? color;
  final List<Color>? colors;
  final int? particleCount;
  final double gravityFactor; // relative to screen height (px/s^2)
  final double spreadRadians; // around upward direction
  final double minRadius;
  final double maxRadius;
  final double minSpeed; // px/s
  final double maxSpeed; // px/s
  final Offset
      emitterNormalized; // 0..1 in width/height (y can be >1 to start below screen)

  ParticlesFountainTransition({
    super.key,
    this.color = Colors.deepPurple,
    this.colors,
    this.particleCount,
    this.gravityFactor = 1.2,
    this.spreadRadians = 0.9,
    this.minRadius = 3.0,
    this.maxRadius = 8.0,
    this.minSpeed = 800.0,
    this.maxSpeed = 1600.0,
    this.emitterNormalized = const Offset(0.5, 1.05),
    super.duration = const Duration(milliseconds: 1300),
    super.exitMode = TransitionExitMode.sameDirection,
  });

  @override
  State<ParticlesFountainTransition> createState() =>
      _ParticlesFountainTransitionState();
}

class ParticlesFountainTransitionStateDefaults {
  static const double exitCoverageUnboostPortion = 0.2;
}

class _ParticlesFountainTransitionState
    extends TransitionState<ParticlesFountainTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  final Random _random = Random();
  Size? _lastSize;
  bool _isExiting = false;
  bool _animationCompleteDispatched = false;
  double _entranceElapsedAtExit = _entranceSimTime; // seconds at exit start
  double _coverageScaleAtExit = 1.0; // coverage multiplier at exit start
  double _latestLeaveTimeAbs =
      _entranceSimTime; // absolute seconds when last particle leaves

  // Simulation parameters
  static const double _entranceSimTime = 1.0; // seconds
  // Exit sim time is computed from particle trajectories to let them naturally
  // leave the screen. We cap it to avoid overly long waits.
  static const double _minExitSimTime = 0.6; // seconds
  static const double _maxExitSimTime = 2.4; // seconds
  double _exitSimTime = 0.9; // seconds (computed in _setup)
  static const double _coverageProgress =
      0.5; // when we guarantee full-screen coverage
  static const double _coverageWindow =
      0.16; // width of the coverage boost window
  static const double _coverageBoost =
      3.2; // radius multiplier at peak coverage
  static const double _spawnWindow =
      0.5; // fraction of entrance time in which particles spawn
  static const double _exitShrinkPortion =
      0.4; // portion of exit used to shrink radii

  final List<_Particle> _particles = [];
  late Offset _emitterPositionPx;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.exitMode == TransitionExitMode.fade
          ? const Duration(milliseconds: 400)
          : widget.duration,
    )..value = 1.0;

    _controller.addListener(() {
      if (!_isExiting &&
          !_animationCompleteDispatched &&
          _controller.value >= _coverageProgress) {
        _animationCompleteDispatched = true;
        widget.onAnimationComplete();
      }

      // For sameDirection, start exit shortly after coverage window ends to keep particles visible
      if (!_isExiting && widget.exitMode == TransitionExitMode.sameDirection) {
        final double endOfCoverage =
            (_coverageProgress + _coverageWindow * 0.5).clamp(0.0, 1.0);
        if (_controller.value >= endOfCoverage) {
          _startSameDirectionExit();
        }
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isExiting) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          _isExiting = true;
          if (widget.exitMode == TransitionExitMode.fade) {
            // Capture anchors at exit start
            _entranceElapsedAtExit = _controller.value * _entranceSimTime;
            _coverageScaleAtExit = _coverageScaleForT(_controller.value);
            _fadeController.reverse();
          } else if (widget.exitMode == TransitionExitMode.reverse) {
            // Capture anchors at exit start
            _entranceElapsedAtExit = _controller.value * _entranceSimTime;
            _coverageScaleAtExit = _coverageScaleForT(_controller.value);
            _controller.reverse();
          } else {
            _startSameDirectionExit();
          }
        });
      } else if ((_isExiting && status == AnimationStatus.completed) ||
          (_isExiting && status == AnimationStatus.dismissed)) {
        widget.onTransitionEnd();
      }
    });

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed &&
          widget.exitMode == TransitionExitMode.fade) {
        widget.onTransitionEnd();
      }
    });
    // Start will be triggered after first layout via _play()
  }

  void _startSameDirectionExit() {
    if (_isExiting) return;
    _isExiting = true;
    _entranceElapsedAtExit = _controller.value * _entranceSimTime;
    _coverageScaleAtExit = _coverageScaleForT(_controller.value);
    // Adjust exit duration based on actual exit start time so particles can leave naturally
    final double rawExit = (_latestLeaveTimeAbs - _entranceElapsedAtExit)
        .clamp(0.0, _maxExitSimTime);
    _exitSimTime = rawExit < _minExitSimTime ? _minExitSimTime : rawExit;
    _controller
      ..reset()
      ..forward();
  }

  double _coverageScaleForT(double t) {
    final double halfWindow = _coverageWindow * 0.5;
    final double start = (_coverageProgress - halfWindow).clamp(0.0, 1.0);
    final double end = (_coverageProgress + halfWindow).clamp(0.0, 1.0);
    if (t <= start) return 1.0;
    if (t >= end) return 1.0 + (_coverageBoost - 1.0) * _easeOutCubic(1.0);
    final double local = (t - start) / (end - start);
    return 1.0 + (_coverageBoost - 1.0) * _easeOutCubic(local);
  }

  double _easeOutCubic(double x) => 1 - pow(1 - x, 3).toDouble();

  void _setup(Size size) {
    _particles.clear();
    _lastSize = size;

    _emitterPositionPx = Offset(
      widget.emitterNormalized.dx.clamp(0.0, 1.0) * size.width,
      widget.emitterNormalized.dy * size.height,
    );

    final int count = widget.particleCount ?? _estimateParticleCount(size);
    final List<Color> palette = _resolvePalette();
    final double gravity = widget.gravityFactor * size.height; // px/s^2

    for (int i = 0; i < count; i++) {
      final double angle =
          (-pi / 2) + (_random.nextDouble() - 0.5) * widget.spreadRadians;
      final double speed =
          _lerp(widget.minSpeed, widget.maxSpeed, _random.nextDouble());
      final double vx = cos(angle) * speed;
      final double vy = sin(angle) * speed; // upward is negative
      final double baseRadius =
          _lerp(widget.minRadius, widget.maxRadius, _random.nextDouble());
      final double spawnT =
          _random.nextDouble() * _spawnWindow * _entranceSimTime; // seconds
      final Color color = palette[i % palette.length];

      // Slight emitter jitter for width variance
      final double jitterX = (size.width * 0.02) * (_random.nextDouble() - 0.5);
      final Offset origin = _emitterPositionPx.translate(jitterX, 0);

      _particles.add(_Particle(
        origin: origin,
        vx: vx,
        vy: vy,
        baseRadius: baseRadius,
        color: color,
        spawnTime: spawnT,
        gravity: gravity,
      ));
    }

    // Compute exit duration so that the slowest particle leaves the screen
    double latestLeaveTime = _entranceSimTime; // absolute seconds from start
    for (final p in _particles) {
      // y(t) = y0 + vy*t + 0.5*g*t^2
      // Find t where y(t) = size.height + r
      final double a = 0.5 * p.gravity;
      final double b = p.vy;
      final double threshold = size.height + p.baseRadius;
      final double c = p.origin.dy - threshold;
      final double discriminant = b * b - 4 * a * c;
      if (discriminant <= 0) {
        continue; // should not happen with positive gravity, but guard
      }
      final double sqrtD = sqrt(discriminant);
      final double t1 = (-b - sqrtD) / (2 * a);
      final double t2 = (-b + sqrtD) / (2 * a);
      final double leaveT = max(t1, t2); // larger root
      if (leaveT > latestLeaveTime) {
        latestLeaveTime = leaveT;
      }
    }
    _latestLeaveTimeAbs = latestLeaveTime;
    final double rawExit =
        (latestLeaveTime - _entranceSimTime).clamp(0.0, _maxExitSimTime);
    _exitSimTime = rawExit < _minExitSimTime ? _minExitSimTime : rawExit;
  }

  int _estimateParticleCount(Size size) {
    final double area = size.width * size.height;
    final int estimated = (area * 0.00022).round(); // ~475 on 1080x1920
    return estimated.clamp(280, 1100);
  }

  List<Color> _resolvePalette() {
    final colorsProp = widget.colors;
    if (colorsProp == null || colorsProp.isEmpty) {
      final single = widget.color ?? Colors.deepPurple;
      return [single, single];
    }
    if (colorsProp.length == 1) return [colorsProp[0], colorsProp[0]];
    return colorsProp;
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
          if (_lastSize != size && !_isExiting) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _setup(size);
              _controller
                ..reset()
                ..forward();
            });
          }
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ParticlesPainter(
                  particles: _particles,
                  progress: _controller.value,
                  size: size,
                  isExiting: _isExiting,
                  exitMode: widget.exitMode,
                  entranceSimTime: _entranceSimTime,
                  exitSimTime: _exitSimTime,
                  coverageProgress: _coverageProgress,
                  coverageWindow: _coverageWindow,
                  coverageBoost: _coverageBoost,
                  exitShrinkPortion: _exitShrinkPortion,
                  entranceElapsedAtExit: _entranceElapsedAtExit,
                  coverageScaleAtExit: _coverageScaleAtExit,
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

class _Particle {
  final Offset origin;
  final double vx;
  final double vy;
  final double baseRadius;
  final Color color;
  final double spawnTime; // seconds
  final double gravity; // px/s^2

  const _Particle({
    required this.origin,
    required this.vx,
    required this.vy,
    required this.baseRadius,
    required this.color,
    required this.spawnTime,
    required this.gravity,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Size size;
  final bool isExiting;
  final TransitionExitMode exitMode;

  final double entranceSimTime;
  final double exitSimTime;
  final double coverageProgress;
  final double coverageWindow;
  final double coverageBoost;
  final double exitShrinkPortion;
  final double entranceElapsedAtExit;
  final double coverageScaleAtExit;

  _ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.size,
    required this.isExiting,
    required this.exitMode,
    required this.entranceSimTime,
    required this.exitSimTime,
    required this.coverageProgress,
    required this.coverageWindow,
    required this.coverageBoost,
    required this.exitShrinkPortion,
    required this.entranceElapsedAtExit,
    required this.coverageScaleAtExit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty) return;

    final double u = _computeSimTime();
    final double coverageMultiplier = _computeCoverageMultiplier();
    final double exitShrink = _computeExitShrinkMultiplier();

    for (int i = 0; i < particles.length; i++) {
      final _Particle p = particles[i];
      final double localTime = u - p.spawnTime;
      if (localTime < 0) continue;

      // Freeze positions for fade; otherwise use computed time
      final double effectiveT =
          (isExiting && exitMode == TransitionExitMode.fade)
              ? (entranceElapsedAtExit - p.spawnTime)
              : localTime;

      final double x = p.origin.dx + p.vx * effectiveT;
      final double y = p.origin.dy +
          p.vy * effectiveT +
          0.5 * p.gravity * effectiveT * effectiveT;

      if (y < -p.baseRadius * 2 ||
          x < -p.baseRadius * 2 ||
          x > size.width + p.baseRadius * 2) {
        continue;
      }

      final double radius = p.baseRadius * coverageMultiplier * exitShrink;
      final Paint paint = Paint()..color = p.color;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  double _computeSimTime() {
    if (!isExiting) {
      return progress * entranceSimTime;
    }

    switch (exitMode) {
      case TransitionExitMode.fade:
        return entranceSimTime; // freeze
      case TransitionExitMode.reverse:
        // progress goes 1->0 during reverse; this maps to time 1->0
        return progress * entranceSimTime;
      case TransitionExitMode.sameDirection:
        return entranceSimTime + progress * exitSimTime;
    }
  }

  double _computeCoverageMultiplier() {
    if (isExiting) {
      if (exitMode == TransitionExitMode.fade) {
        // Keep coverage multiplier at the value captured at exit start
        return coverageScaleAtExit;
      }
      // For moving exits, gradually remove coverage boost over an early portion
      final double t = progress.clamp(0.0, 1.0);
      final double ramp = (t /
              ParticlesFountainTransitionStateDefaults
                  .exitCoverageUnboostPortion)
          .clamp(0.0, 1.0);
      final double eased = 1.0 - _easeOutCubic(ramp);
      return 1.0 + (coverageScaleAtExit - 1.0) * eased;
    }

    final double t = progress;
    final double halfWindow = coverageWindow * 0.5;
    final double start = (coverageProgress - halfWindow).clamp(0.0, 1.0);
    final double end = (coverageProgress + halfWindow).clamp(0.0, 1.0);
    if (t <= start) return 1.0;
    if (t >= end) return 1.0 + (coverageBoost - 1.0) * _easeOutCubic(1.0);

    final double local = (t - start) / (end - start);
    return 1.0 + (coverageBoost - 1.0) * _easeOutCubic(local);
  }

  double _computeExitShrinkMultiplier() {
    if (!isExiting) return 1.0;
    if (exitMode == TransitionExitMode.fade) return 1.0;

    // During exit, shrink radii smoothly for a portion of the exit duration.
    final double t = progress.clamp(0.0, 1.0);
    final double portion = exitShrinkPortion.clamp(0.0, 1.0);
    final double start = 1.0 - portion;
    if (t <= start) return 1.0;
    final double local = (t - start) / portion; // 0..1
    final double eased = 1.0 - _easeOutCubic(local);
    return eased.clamp(0.0, 1.0);
  }

  double _easeOutCubic(double x) => 1 - pow(1 - x, 3).toDouble();

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        isExiting != oldDelegate.isExiting ||
        particles != oldDelegate.particles ||
        exitMode != oldDelegate.exitMode ||
        size != oldDelegate.size ||
        entranceElapsedAtExit != oldDelegate.entranceElapsedAtExit ||
        coverageScaleAtExit != oldDelegate.coverageScaleAtExit;
  }
}

double _lerp(double a, double b, double t) => a + (b - a) * t;
