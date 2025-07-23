// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:animated_transitions/animated_transitions.dart';

import 'next_screen.dart';

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
                  colors: const [
                    Colors.blue,
                    Colors.blueGrey,
                  ],
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
                  colors: const [
                    Colors.yellow,
                    Colors.red,
                  ],
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
                  colors: const [
                    Colors.greenAccent
                  ],
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
        ],
      ),
    );
  }
}
