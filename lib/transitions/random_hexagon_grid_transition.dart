// ignore_for_file: must_be_immutable

import 'dart:math';
import 'hexagon_grid_transition_base.dart';

class RandomHexagonGridTransition extends HexagonGridTransitionBase {
  final _random = Random();

  RandomHexagonGridTransition({
    super.key,
    super.color,
    super.colors,
    super.hexagonSize,
    super.useFlipAnimation,
    super.duration,
    super.exitMode,
  });

  @override
  double computeDelay(int col, int row, int cols, int rows) {
    return _random.nextDouble();
  }
}
