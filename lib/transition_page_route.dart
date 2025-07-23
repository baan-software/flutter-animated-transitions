import 'package:flutter/material.dart';
import 'package:page_transition_animations/transitions/expanding_circles_transition.dart';
import 'package:page_transition_animations/transitions/fading_circles_transition.dart';
import 'package:page_transition_animations/transitions/growing_bars_transition.dart';
import 'package:page_transition_animations/transitions/random_finish_bars_transition.dart';
import 'package:page_transition_animations/transitions/wave_bars_transition.dart';

import 'transition_animation.dart';
import 'transition_controller.dart';

/// The type of transition to use.
enum TransitionType {
  /// A transition with fading circles.
  fadingCircles,

  /// A transition with expanding circles.
  expandingCircles,

  /// A transition with growing bars.
  growingBars,

  /// A transition with bars that finish in a random order.
  randomFinishBars,

  /// A transition with wave-like bars.
  waveBars,
}

/// A page route that uses a custom transition animation.
class TransitionPageRoute extends PageRouteBuilder {
  /// The page to display.
  final Widget page;

  /// The type of transition to use.
  final TransitionType transition;

  /// Creates a new [TransitionPageRoute].
  TransitionPageRoute({
    required this.page,
    required this.transition,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return _TransitionAnimator(
              transition: transition,
              child: child,
            );
          },
        );
}

class _TransitionAnimator extends StatefulWidget {
  final Widget child;
  final TransitionType transition;

  const _TransitionAnimator({
    required this.child,
    required this.transition,
  });

  @override
  _TransitionAnimatorState createState() => _TransitionAnimatorState();
}

class _TransitionAnimatorState extends State<_TransitionAnimator> {
  bool _isAnimationComplete = false;
  bool _isTransitionFinished = false;
  late final TransitionAnimation _transitionAnimation;

  @override
  void initState() {
    super.initState();
    final controller = TransitionController(
      onAnimationComplete: () {
        setState(() {
          _isAnimationComplete = true;
        });
      },
      onTransitionEnd: () {
        setState(() {
          _isTransitionFinished = true;
        });
      },
    );

    switch (widget.transition) {
      case TransitionType.fadingCircles:
        _transitionAnimation = FadingCirclesTransition(
          onAnimationComplete: controller.onAnimationComplete,
          onTransitionEnd: controller.onTransitionEnd,
        );
        break;
      case TransitionType.expandingCircles:
        _transitionAnimation = ExpandingCirclesTransition(
          onAnimationComplete: controller.onAnimationComplete,
          onTransitionEnd: controller.onTransitionEnd,
        );
        break;
      case TransitionType.growingBars:
        _transitionAnimation = GrowingBarsTransition(
          onAnimationComplete: controller.onAnimationComplete,
          onTransitionEnd: controller.onTransitionEnd,
        );
        break;
      case TransitionType.randomFinishBars:
        _transitionAnimation = RandomFinishBarsTransition(
          onAnimationComplete: controller.onAnimationComplete,
          onTransitionEnd: controller.onTransitionEnd,
        );
        break;
      case TransitionType.waveBars:
        _transitionAnimation = WaveBarsTransition(
          onAnimationComplete: controller.onAnimationComplete,
          onTransitionEnd: controller.onTransitionEnd,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isTransitionFinished) {
      return widget.child;
    }

    return Stack(
      children: [
        if (_isAnimationComplete) widget.child,
        Builder(
          builder: (context) {
            return RepaintBoundary(child: _transitionAnimation);
          },
        ),
      ],
    );
  }
}
