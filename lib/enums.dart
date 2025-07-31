/// The direction of the transition.
enum TransitionDirection {
  /// From left to right.
  left,

  /// From right to left.
  right,

  /// From top to bottom.
  top,

  /// From bottom to top.
  bottom,
}

/// How the transition should exit/cleanup.
enum TransitionExitMode {
  /// Simple fade out (default).
  fade,

  /// Reverse the entrance animation (e.g., if entrance was top→bottom, exit will be bottom→top).
  reverse,

  /// Continue in same direction as entrance (e.g., if entrance was top→bottom, exit also top→bottom).
  sameDirection,
}
