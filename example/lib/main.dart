import 'package:animated_transitions/animated_transitions.dart';
import 'package:animated_transitions_example/next_screen.dart';
import 'package:animated_transitions_example/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transition Animations',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Animations Showcase')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Growing Bars Top'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: GrowingBarsTransition(
                  direction: TransitionDirection.top,
                  colors: const [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.yellow,
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Growing Bars Left'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: GrowingBarsTransition(
                  duration: const Duration(milliseconds: 300),
                  direction: TransitionDirection.left,
                  colors: const [Colors.blue, Colors.blueGrey],
                  exitMode: TransitionExitMode.reverse,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Wave Bars Bottom'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: WaveBarsTransition(
                  colors: const [Colors.yellow, Colors.red],
                  exitMode: TransitionExitMode.reverse,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Wave Bars Right'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: WaveBarsTransition(
                  direction: TransitionDirection.right,
                  colors: const [Colors.greenAccent],
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Random Finish Bars Top'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: RandomFinishBarsTransition(
                  direction: TransitionDirection.top,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Random Finish Bars Left'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: RandomFinishBarsTransition(
                  direction: TransitionDirection.left,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Expanding Circles'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: ExpandingCirclesTransition(
                  numberOfCircles: 5,
                  colors: const [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.yellow,
                  ],
                  duration: const Duration(milliseconds: 1000),
                  exitMode: TransitionExitMode.reverse,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Random Pixelated'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: RandomPixelatedTransition(
                  pixelDensity: 100,
                  colors: const [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.yellow,
                  ],
                  exitMode: TransitionExitMode.reverse,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Pixelated (Bottom to Top)'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: DirectionalPixelatedTransition(
                  pixelDensity: 40,
                  direction: TransitionDirection.bottom,
                  colors: [Colors.white, Colors.lightBlue.shade300],
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Pixelated (Left to Right)'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: DirectionalPixelatedTransition(
                  pixelDensity: 40,
                  direction: TransitionDirection.left,
                  colors: const [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.yellow,
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Clock Sweep'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: ClockSweepTransition(
                  colors: const [Colors.lightBlue, Colors.lime, Colors.yellow],
                  clockwise: true,
                  duration: const Duration(milliseconds: 1200),
                  exitMode: TransitionExitMode.reverse,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Brush Stroke Top'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: BrushStrokeTransition(
                  direction: TransitionDirection.top,
                  duration: const Duration(milliseconds: 1000),
                  colors: const [Colors.black87, Colors.grey, Colors.blueGrey],
                  curviness: 0.4,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Brush Stroke Left'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: BrushStrokeTransition(
                  direction: TransitionDirection.left,
                  duration: const Duration(milliseconds: 1000),
                  colors: const [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                    Colors.indigo,
                    Colors.deepPurple,
                  ],
                  strokeWidth: 50.0,
                  curviness: 0.2,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Crossing Bars'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: CrossingBarsTransition(
                  direction: TransitionDirection.left,
                  colors: const [Colors.black, Colors.white],
                  barCount: 50,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('CRT / TV Shutoff'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: CrtShutoffTransition(
                  color: Colors.black,
                  lineColor: Colors.white,
                  duration: const Duration(milliseconds: 900),
                  exitMode: TransitionExitMode.sameDirection,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('White Noise'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: WhiteNoiseTransition(
                  duration: const Duration(milliseconds: 1000),
                  pixelSize: 6,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Spiral Transition'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: SpiralTransition(
                  duration: const Duration(milliseconds: 1000),
                  colors: const [
                    Colors.deepPurple,
                    Colors.purple,
                    Colors.pinkAccent,
                    Colors.pink,
                  ],
                  spiralTurns: 3,
                  clockwise: false,
                  exitMode: TransitionExitMode.reverse,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Hexagon Grid Top (Flip)'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: HexagonGridTransition(
                  direction: TransitionDirection.bottom,
                  colors: const [
                    Colors.teal,
                    Colors.cyan,
                    Colors.lightBlue,
                    Colors.blue,
                  ],
                  hexagonSize: 20.0,
                  useFlipAnimation: true,
                  exitMode: TransitionExitMode.sameDirection,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Hexagon Grid Left (Slide)'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: HexagonGridTransition(
                  direction: TransitionDirection.left,
                  colors: const [
                    Colors.orange,
                    Colors.deepOrange,
                    Colors.red,
                    Colors.redAccent,
                  ],
                  hexagonSize: 30.0,
                  useFlipAnimation: false,
                  exitMode: TransitionExitMode.sameDirection,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Random Hexagon Grid'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: RandomHexagonGridTransition(
                  colors: const [
                    Colors.orange,
                    Colors.deepOrange,
                    Colors.red,
                    Colors.redAccent,
                  ],
                  hexagonSize: 20.0,
                  useFlipAnimation: true,
                  exitMode: TransitionExitMode.reverse,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Sunburst Transition'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: SunburstTransition(
                  colors: const [
                    Colors.yellow,
                    Colors.red,
                    Colors.yellow,
                    Colors.white,
                  ],
                  duration: const Duration(milliseconds: 800),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
