import 'package:flutter/material.dart';
import 'transition.dart';
import 'transition_controller.dart';

class TransitionPageRoute extends PageRouteBuilder {
  final Transition transitionAnimation;

  TransitionPageRoute({
    required WidgetBuilder builder,
    required this.transitionAnimation,
  }) : super(
         transitionDuration: const Duration(milliseconds: 1000),
         opaque: false,
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _TransitionAnimator(
             transitionAnimation: transitionAnimation,
             child: child,
           );
         },
       );
}

class _TransitionAnimator extends StatefulWidget {
  final Widget child;
  final Transition transitionAnimation;

  const _TransitionAnimator({
    required this.child,
    required this.transitionAnimation,
  });

  @override
  _TransitionAnimatorState createState() => _TransitionAnimatorState();
}

class _TransitionAnimatorState extends State<_TransitionAnimator> {
  bool _isAnimationComplete = false;
  bool _isTransitionFinished = false;

  @override
  Widget build(BuildContext context) {
    if (_isTransitionFinished) {
      return widget.child;
    }

    return Stack(
      children: [
        if (_isAnimationComplete) widget.child,
        Builder(
          builder: (context) {
            return RepaintBoundary(child: widget.transitionAnimation);
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.transitionAnimation.controller = TransitionController(
        onAnimationComplete: () {
          setState(() {
            _isAnimationComplete = true;
          });
        },
        onTransitionEnd: () {
          setState(() {
            _isTransitionFinished = true;
          });
        },
      );
    });
  }
}
