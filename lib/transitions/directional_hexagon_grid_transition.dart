// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:animated_transitions/enums.dart';
import 'hexagon_grid_transition_base.dart';

class DirectionalHexagonGridTransition extends HexagonGridTransitionBase {
  final TransitionDirection direction;
  final _random = Random();

  DirectionalHexagonGridTransition({
    super.key,
    super.color,
    super.colors,
    super.hexagonSize,
    super.useFlipAnimation,
    super.duration,
    super.exitMode,
    this.direction = TransitionDirection.bottom,
  });

  @override
  double computeDelay(int col, int row, int cols, int rows) {
    double normalizedDelay;
    switch (direction) {
      case TransitionDirection.top:
        normalizedDelay = row / rows;
        break;
      case TransitionDirection.bottom:
        normalizedDelay = (rows - row - 1) / rows;
        break;
      case TransitionDirection.left:
        normalizedDelay = col / cols;
        break;
      case TransitionDirection.right:
        normalizedDelay = (cols - col - 1) / cols;
        break;
    }
    // Light randomness for organic feel
    normalizedDelay += _random.nextDouble() * 0.1;
    return normalizedDelay;
  }
}
