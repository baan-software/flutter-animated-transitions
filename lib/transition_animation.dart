// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

/// An abstract class for creating transition animations.
abstract class TransitionAnimation extends StatefulWidget {
  /// A callback to be called when the transition animation is complete.
  final VoidCallback onAnimationComplete;

  /// A callback to be called when the transition is finished and the new page is fully visible.
  final VoidCallback onTransitionEnd;

  /// Creates a new transition animation.
  const TransitionAnimation({
    super.key,
    required this.onAnimationComplete,
    required this.onTransitionEnd,
  });

  @override
  State<TransitionAnimation> createState();
}

/// The state for a [TransitionAnimation].
class TransitionAnimationState<T extends TransitionAnimation> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
