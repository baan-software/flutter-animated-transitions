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
                  direction: TransitionDirection.left,
                  colors: const [Colors.blue, Colors.blueGrey],
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
            title: const Text('Pixelated (Top to Bottom)'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: DirectionalPixelatedTransition(
                  pixelDensity: 40,
                  direction: TransitionDirection.top,
                  colors: const [
                    Colors.purple,
                    Colors.deepPurple,
                    Colors.indigo,
                  ],
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
                  colors: const [Colors.orange, Colors.deepOrange, Colors.red],
                  exitMode: TransitionExitMode.reverse,
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
                  exitMode: TransitionExitMode.reverse,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Pixelated (Right to Left)'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const NextScreen(),
                transitionAnimation: DirectionalPixelatedTransition(
                  pixelDensity: 40,
                  direction: TransitionDirection.right,
                  colors: const [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.yellow,
                  ],
                  exitMode: TransitionExitMode.sameDirection,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
