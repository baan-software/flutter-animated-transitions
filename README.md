# Animated Transitions

A Flutter package providing a collection of beautiful and smooth transitions for page navigation

## Features

- A set of high-quality page transitions.
- Simple, controller-based animation management.
- Customizable transition duration and behavior.
- Works with the standard Flutter Navigator.

## Showcase
<p>
<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/bars_left.gif" alt="Horizontal Growing Bars" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/bars_top.gif" alt="Vertical Growing Bars" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/random_finish_top.gif" alt="Horizontal Random Finish" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/pixels_random_in_out.gif" alt="Random Pixelated" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/pixels_top.gif" alt="Vertical Pixels" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/wave_bottom.gif" alt="Vertical Wave" width="222" height="480" loop=infinite>
</p>

## Usage

To use the page transitions, you can wrap your page route with the `TransitionPageRoute` and provide a transition type.

```dart
import 'package:flutter/material.dart';
import 'package:animated_transitions/animated_transitions.dart';

// ...

Navigator.of(context).push(
  TransitionPageRoute(
    builder: (context) => const NextScreen(),
    transitionAnimation: GrowingBarsTransition(),
  ),
);
```



## Available Transitions

- **GrowingBarsTransition** - Animated bars that grow from the specified direction
- **CrossingBarsTransition** - Bars that expand from opposite sides, creating a criss-cross effect
- **TetrisTransition** - Squares that enter the screen and build on top of previous rows/columns, like Tetris
- **WaveBarsTransition** - Wave-like animation with bars moving in a wave pattern
- **RandomFinishBarsTransition** - Bars that finish in random positions
- **ExpandingCirclesTransition** - Circles that expand from the center
- **DirectionalPixelatedTransition** - Pixelated effect that moves in a specific direction
- **RandomPixelatedTransition** - Random pixelated transition effect
- **BrushStrokeTransition** - Brush stroke animation effect
- **ClockSweepTransition** - Clock-like sweeping animation
- **WhiteNoiseTransition** - White noise/static effect transition

## Create your own

Create your own transition by subclassing `Transition` widget