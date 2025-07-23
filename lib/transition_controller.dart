import 'package:flutter/widgets.dart';

class TransitionController {
  VoidCallback onAnimationComplete;
  VoidCallback onTransitionEnd;

  TransitionController({
    required this.onAnimationComplete,
    required this.onTransitionEnd,
  });
}
