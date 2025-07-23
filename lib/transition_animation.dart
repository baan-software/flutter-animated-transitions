
// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_animations/transition_controller.dart';


abstract class TransitionAnimation extends StatefulWidget {
  
  TransitionController? controller;

  TransitionAnimation({super.key});

  @override
  State<TransitionAnimation> createState();

  void onAnimationComplete() {
    controller?.onAnimationComplete.call();
  }

  void onTransitionEnd() {
    controller?.onTransitionEnd.call();
  }
}

abstract class TransitionAnimationState<T extends TransitionAnimation> extends State<T> {
  
}

