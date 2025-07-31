// ignore_for_file: must_be_immutable

import 'dart:math';
import 'pixelated_transition_base.dart';

class RandomPixelatedTransition extends PixelatedTransitionBase {
  RandomPixelatedTransition({
    super.key,
    super.color,
    super.colors,
    super.pixelDensity,
    super.duration,
  });

  final _random = Random();

  @override
  List<List<double>> createPixelDelays(
      int verticalPixels, int horizontalPixels) {
    return List.generate(
      verticalPixels,
      (_) => List.generate(
        horizontalPixels,
        (_) => _random.nextDouble(),
      ),
    );
  }
}
