// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_animations/enums.dart';
import 'package:flutter_animations/screens/screen_b.dart';
import 'package:flutter_animations/transition_page_route.dart';
import 'package:flutter_animations/transitions/fading_circles_transition.dart';
import 'package:flutter_animations/transitions/expanding_circles_transition.dart';
import 'package:flutter_animations/transitions/random_finish_bars_transition.dart';
import 'package:flutter_animations/transitions/growing_bars_transition.dart';
import 'package:flutter_animations/transitions/wave_bars_transition.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Animations Showcase'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Growing Bars Top'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const ScreenB(),
                transitionAnimation: GrowingBarsTransition(
                  direction: TransitionDirection.top,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Growing Bars Left'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const ScreenB(),
                transitionAnimation: GrowingBarsTransition(
                  direction: TransitionDirection.left,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Wave Bars Bottom'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const ScreenB(),
                transitionAnimation: WaveBarsTransition(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Wave Bars Right'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const ScreenB(),
                transitionAnimation: WaveBarsTransition(
                  direction: TransitionDirection.right,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Random Finish Bars Top'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const ScreenB(),
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
                builder: (context) => const ScreenB(),
                transitionAnimation: RandomFinishBarsTransition(
                  direction: TransitionDirection.left,
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Fading Circles'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const ScreenB(),
                transitionAnimation: FadingCirclesTransition(),
              ),
            ),
          ),
          ListTile(
            title: const Text('Expanding Circles'),
            onTap: () => Navigator.push(
              context,
              TransitionPageRoute(
                builder: (context) => const ScreenB(),
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