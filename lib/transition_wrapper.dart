import 'package:flutter/material.dart';
import 'package:animated_transitions/transition.dart';
import 'package:animated_transitions/transition_controller.dart';

class TransitionWrapper extends StatefulWidget {
  final Widget child;
  final Transition transition;

  const TransitionWrapper(
      {super.key, required this.child, required this.transition});

  @override
  State<TransitionWrapper> createState() => _TransitionWrapperState();
}

class _TransitionWrapperState extends State<TransitionWrapper> {
  bool _showChild = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    widget.transition.controller = TransitionController(
      onAnimationComplete: () {
        setState(() => _showChild = true);
      },
      onTransitionEnd: () {
        setState(() => _done = true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return widget.child;
    }

    return Stack(
      children: [
        if (_showChild) widget.child,
        widget.transition,
      ],
    );
  }
}
