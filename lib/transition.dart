// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'transition_controller.dart';

abstract class Transition extends StatefulWidget {
  TransitionController? controller;

  Transition({super.key});

  @override
  State<Transition> createState();

  void onAnimationComplete() {
    controller?.onAnimationComplete.call();
  }

  void onTransitionEnd() {
    controller?.onTransitionEnd.call();
  }
}

abstract class TransitionState<T extends Transition>
    extends State<T> {}
