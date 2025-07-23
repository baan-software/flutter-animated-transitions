// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:animated_transitions/transition_page_route.dart';

import 'screen_b.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Transition Animations'),
      ),
      body: ListView(
        children: [
          _TransitionButton(
            title: 'Growing Bars (LTR)',
            onPressed: () {
              Navigator.of(context).push(
                TransitionPageRoute(
                  page: const ScreenB(),
                  transition: TransitionType.growingBars,
                ),
              );
            },
          ),
          _TransitionButton(
            title: 'Growing Bars (RTL)',
            onPressed: () {
              Navigator.of(context).push(
                TransitionPageRoute(
                  page: const ScreenB(),
                  transition: TransitionType.growingBars,
                ),
              );
            },
          ),
          _TransitionButton(
            title: 'Wave Bars (LTR)',
            onPressed: () {
              Navigator.of(context).push(
                TransitionPageRoute(
                  page: const ScreenB(),
                  transition: TransitionType.waveBars,
                ),
              );
            },
          ),
          _TransitionButton(
            title: 'Wave Bars (RTL)',
            onPressed: () {
              Navigator.of(context).push(
                TransitionPageRoute(
                  page: const ScreenB(),
                  transition: TransitionType.waveBars,
                ),
              );
            },
          ),
          _TransitionButton(
            title: 'Random Finish Bars (LTR)',
            onPressed: () {
              Navigator.of(context).push(
                TransitionPageRoute(
                  page: const ScreenB(),
                  transition: TransitionType.randomFinishBars,
                ),
              );
            },
          ),
          _TransitionButton(
            title: 'Random Finish Bars (RTL)',
            onPressed: () {
              Navigator.of(context).push(
                TransitionPageRoute(
                  page: const ScreenB(),
                  transition: TransitionType.randomFinishBars,
                ),
              );
            },
          ),
          _TransitionButton(
            title: 'Fading Circles',
            onPressed: () {
              Navigator.of(context).push(
                TransitionPageRoute(
                  page: const ScreenB(),
                  transition: TransitionType.fadingCircles,
                ),
              );
            },
          ),
          _TransitionButton(
            title: 'Expanding Circles',
            onPressed: () {
              Navigator.of(context).push(
                TransitionPageRoute(
                  page: const ScreenB(),
                  transition: TransitionType.expandingCircles,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TransitionButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const _TransitionButton({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: onPressed,
    );
  }
}
