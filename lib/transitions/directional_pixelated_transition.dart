// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:animated_transitions/enums.dart';
import 'pixelated_transition_base.dart';

class DirectionalPixelatedTransition extends PixelatedTransitionBase {
  final TransitionDirection direction;
  final _random = Random();

  DirectionalPixelatedTransition({
    super.key,
    super.color,
    super.colors,
    super.pixelDensity,
    super.duration,
    super.exitMode,
    this.direction = TransitionDirection.bottom,
  });

  @override
  List<List<double>> createPixelDelays(
      int verticalPixels, int horizontalPixels) {
    // Create directional delays based on position
    final delays = List.generate(
      verticalPixels,
      (y) => List.generate(
        horizontalPixels,
        (x) {
          final double delay = switch (direction) {
            TransitionDirection.top => y / verticalPixels,
            TransitionDirection.bottom => 1 - (y / verticalPixels),
            TransitionDirection.left => x / horizontalPixels,
            TransitionDirection.right => 1 - (x / horizontalPixels),
          };
          return delay;
        },
      ),
    );

    // Add some randomness to make it more organic
    for (int y = 0; y < verticalPixels; y++) {
      for (int x = 0; x < horizontalPixels; x++) {
        delays[y][x] += _random.nextDouble() * 0.2 - 0.1; // ±10% randomness
        delays[y][x] = delays[y][x].clamp(0.0, 1.0);
      }
    }

    return delays;
  }
}
