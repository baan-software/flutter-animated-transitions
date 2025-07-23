import 'package:animated_transitions/animated_transitions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home_screen.dart';
import 'screens/next_screen.dart';

final GoRouter goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/next',
      pageBuilder: (context, state) => CustomTransitionPage(
        child: TransitionWrapper(
          transition: GrowingBarsTransition(
            direction: TransitionDirection.top,
            colors: const [
              Colors.blue,
              Colors.red,
              Colors.green,
              Colors.yellow,
            ],
          ),
          child: const NextScreen(),
        ),
        transitionsBuilder: (_, __, ___, child) => child,
      ),
    ),
  ],
);