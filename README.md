# Animated Transitions

A Flutter package providing a collection of beautiful and smooth transitions for page navigation

## Features

- A set of high-quality page transitions.
- Simple, controller-based animation management.
- Customizable transition duration and behavior.
- Works with the standard Flutter Navigator.

## Showcase
<p>
<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/growing_bars_left.gif" alt="Horizontal Growing Bars" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/growing_bars_top.gif" alt="Vertical Growing Bars" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/randrom_finish_top.gif" alt="Horizontal Random Finish" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/random_finish_left.gif" alt="Vertical Random Finish" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/pixels_random_in_out.gif" alt="Random Pixelated" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/pixels_top.gif" alt="Vertical Pixels" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/pixels_bottom.gif" alt="Horizontal Pixels" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/wave_bottom.gif" alt="Vertical Wave" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/cross_top.gif" alt="Cross Top" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/cross_left.gif" alt="Cross Left" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/expanding_circles.gif" alt="Expanding Circles" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/brush_top.gif" alt="Brush Top" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/brush_left.gif" alt="Brush Left" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/clock.gif" alt="Clock Sweep" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/white_noise.gif" alt="White Noise" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/sun.gif" alt="Sunburst" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/tv.gif" alt="CRT Shutoff" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/hex_left.gif" alt="Hexagon Left" width="222" height="480" loop=infinite>

<img src="https://raw.githubusercontent.com/giora-baan/flutter-animated-transitions/main/example/demo_gifs/hex_random.gif" alt="Hexagon Random" width="222" height="480" loop=infinite>
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
- **WaveBarsTransition** - Wave-like animation with bars moving in a wave pattern
- **RandomFinishBarsTransition** - Bars that finish in random positions
- **ExpandingCirclesTransition** - Circles that expand from the center
- **DirectionalPixelatedTransition** - Pixelated effect that moves in a specific direction
- **RandomPixelatedTransition** - Random pixelated transition effect
- **BrushStrokeTransition** - Brush stroke animation effect
- **ClockSweepTransition** - Clock-like sweeping animation
- **WhiteNoiseTransition** - White noise/static effect transition
- **SunburstTransition** - Radial rays expanding from the center like a sunburst
- **CrtShutoffTransition** - Old CRT monitor shutoff effect
- **HexagonGridTransition** - Hexagonal grid pattern transition
- **SpiralTransition** - Spiral animation effect
- **DirectionalHexagonGridTransition** - Hexagonal grid moving in a specific direction
- **RandomHexagonGridTransition** - Random hexagonal grid pattern

## Create your own

Create your own transition by subclassing `Transition` widget