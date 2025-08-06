// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'transition_controller.dart';
import 'enums.dart';

abstract class Transition extends StatefulWidget {
  final Duration duration;
  final TransitionExitMode exitMode;
  TransitionController? controller;

  Transition({
    super.key,
    required this.duration,
    this.exitMode = TransitionExitMode.sameDirection,
  });

  @override
  State<Transition> createState();

  void onAnimationComplete() {
    controller?.onAnimationComplete.call();
  }

  void onTransitionEnd() {
    controller?.onTransitionEnd.call();
  }
}

abstract class TransitionState<T extends Transition> extends State<T> {}
