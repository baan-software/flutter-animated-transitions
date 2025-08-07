// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animated_transitions/enums.dart';
import 'package:animated_transitions/transition.dart';

class TetrisTransition extends Transition {
  final TransitionDirection direction;
  final List<Color>? colors;
  final int squaresPerRow;

  TetrisTransition({
    super.key,
    this.direction = TransitionDirection.bottom,
    this.colors,
    this.squaresPerRow = 10,
    super.duration = const Duration(milliseconds: 1200),
    super.exitMode = TransitionExitMode.sameDirection,
  });

  @override
  State<TetrisTransition> createState() => TetrisTransitionState();
}

class TetrisTransitionState extends TransitionState<TetrisTransition>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _fadeController;
  List<List<Animation<double>>> _positionAnimations = [];
  List<List<Animation<Color?>>> _colorAnimations = [];
  final _random = Random();
  Size? _lastSize;
  bool _isExiting = false;

  bool get _isHorizontal =>
      widget.direction == TransitionDirection.left ||
      widget.direction == TransitionDirection.right;

  // Get the effective direction for the current animation phase
  TransitionDirection get _effectiveDirection {
    final effectiveDir =
        (!_isExiting || widget.exitMode == TransitionExitMode.reverse)
            ? widget.direction
            : _getOppositeDirection(widget.direction);

    return effectiveDir;
  }

  TransitionDirection _getOppositeDirection(TransitionDirection direction) {
    switch (direction) {
      case TransitionDirection.left:
        return TransitionDirection.right;
      case TransitionDirection.right:
        return TransitionDirection.left;
      case TransitionDirection.top:
        return TransitionDirection.bottom;
      case TransitionDirection.bottom:
        return TransitionDirection.top;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: widget.exitMode == TransitionExitMode.fade
          ? const Duration(milliseconds: 400)
          : widget.duration,
    );
    _fadeController.value = 1.0; // Start fully opaque

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete();
        Future.delayed(const Duration(milliseconds: 50), () {
          if (!mounted) return;
          _isExiting = true;
          if (widget.exitMode == TransitionExitMode.fade) {
            _fadeController.reverse();
          } else {
            _setupAnimations(_lastSize!.width, _lastSize!.height);
            _controller.reset();
            _controller.forward();
          }
        });
      }
    });

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed &&
          widget.exitMode == TransitionExitMode.fade) {
        widget.onTransitionEnd();
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isExiting) {
        widget.onTransitionEnd();
      }
    });
  }

  void _setupAnimations(double maxWidth, double maxHeight) {
    final squaresPerRow = widget.squaresPerRow;
    final squareSize = _isHorizontal 
        ? maxHeight / squaresPerRow 
        : maxWidth / squaresPerRow;
    
    // Calculate number of rows needed to fill the screen
    final numberOfRows = _isHorizontal 
        ? (maxWidth / squareSize).ceil()
        : (maxHeight / squareSize).ceil();

    _controller.duration = widget.duration;

    if (_isHorizontal) {
      // For horizontal movement, use a flat structure
      final totalSquares = numberOfRows * squaresPerRow;
      
      // Calculate initial delays for entrance
      final initialDelays = List.generate(
        totalSquares,
        (index) {
          final numberOfColumns = (maxWidth / squareSize).ceil();
          final columnIndex = index % numberOfColumns;
          final stepSize = 1.0 / numberOfColumns;
          final columnDelay = columnIndex * stepSize;
          final randomDelay = _random.nextDouble() * 0.05;
          return columnDelay + randomDelay;
        },
      );

      // Apply exit mode logic to delays
      List<double> finalDelays;
      if (_isExiting) {
        switch (widget.exitMode) {
          case TransitionExitMode.fade:
            finalDelays = initialDelays; // Keep same delays for fade
            break;
          case TransitionExitMode.reverse:
            // Reverse the delays (last becomes first, etc.)
            finalDelays = initialDelays.map((delay) => 1.0 - delay).toList();
            break;
          case TransitionExitMode.sameDirection:
            finalDelays = initialDelays; // Keep same delays
            break;
        }
      } else {
        finalDelays = initialDelays;
      }
      
      _positionAnimations = [
        List.generate(
          totalSquares,
          (index) {
            final delay = finalDelays[index];
            final start = delay.clamp(0.0, 0.95);
            final end = (start + 0.05).clamp(0.0, 1.0);

            // For exit animations, reverse the animation
            final begin = _isExiting ? 1.0 : 0.0;
            final endValue = _isExiting ? 0.0 : 1.0;

            return Tween<double>(
              begin: begin,
              end: endValue,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(start, end, curve: Curves.easeIn),
              ),
            );
          },
        )
      ];

      // Color animations for horizontal movement
      final List<Color> animationColors;
      final colors = widget.colors;
      if (colors == null) {
        animationColors = [Colors.white, Colors.white];
      } else if (colors.length == 1) {
        animationColors = [colors[0], colors[0]];
      } else {
        animationColors = colors;
      }

      final tweenItems = <TweenSequenceItem<Color?>>[];

      if (_isExiting && widget.exitMode != TransitionExitMode.fade) {
        // Reverse the color sequence for exit animations
        for (var i = animationColors.length - 1; i > 0; i--) {
          tweenItems.add(
            TweenSequenceItem(
              tween: ColorTween(
                begin: animationColors[i],
                end: animationColors[i - 1],
              ),
              weight: 1,
            ),
          );
        }
      } else {
        for (var i = 0; i < animationColors.length - 1; i++) {
          tweenItems.add(
            TweenSequenceItem(
              tween: ColorTween(
                begin: animationColors[i],
                end: animationColors[i + 1],
              ),
              weight: 1,
            ),
          );
        }
      }

      _colorAnimations = [
        List.generate(
          totalSquares,
          (index) {
            return TweenSequence<Color?>(tweenItems).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Curves.easeIn,
              ),
            );
          },
        )
      ];
    } else {
      // For vertical movement, use the original row-based structure
      
      // Calculate initial delays for entrance
      final initialDelays = List.generate(
        numberOfRows,
        (rowIndex) {
          return List.generate(
            squaresPerRow,
            (index) {
              final stepSize = 1.0 / numberOfRows;
              final rowDelay = rowIndex * stepSize;
              final randomDelay = _random.nextDouble() * 0.05;
              return rowDelay + randomDelay;
            },
          );
        },
      );

      // Apply exit mode logic to delays
      List<List<double>> finalDelays;
      if (_isExiting) {
        switch (widget.exitMode) {
          case TransitionExitMode.fade:
            finalDelays = initialDelays; // Keep same delays for fade
            break;
          case TransitionExitMode.reverse:
            // Reverse the delays (last row becomes first, etc.)
            finalDelays = List.generate(
              numberOfRows,
              (rowIndex) => List.generate(
                squaresPerRow,
                (index) => 1.0 - initialDelays[numberOfRows - 1 - rowIndex][index],
              ),
            );
            break;
          case TransitionExitMode.sameDirection:
            finalDelays = initialDelays; // Keep same delays
            break;
        }
      } else {
        finalDelays = initialDelays;
      }

      // Create position animations for each square in each row
      _positionAnimations = List.generate(
        numberOfRows,
        (rowIndex) {
          return List.generate(
            squaresPerRow,
            (index) {
              final delay = finalDelays[rowIndex][index];
              final start = delay.clamp(0.0, 0.95);
              final end = (start + 0.05).clamp(0.0, 1.0);

              // For exit animations, reverse the animation
              final begin = _isExiting ? 1.0 : 0.0;
              final endValue = _isExiting ? 0.0 : 1.0;

              return Tween<double>(
                begin: begin,
                end: endValue,
              ).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(start, end, curve: Curves.easeIn),
                ),
              );
            },
          );
        },
      );

      // Color animations for vertical movement
      final List<Color> animationColors;
      final colors = widget.colors;
      if (colors == null) {
        animationColors = [Colors.white, Colors.white];
      } else if (colors.length == 1) {
        animationColors = [colors[0], colors[0]];
      } else {
        animationColors = colors;
      }

      final tweenItems = <TweenSequenceItem<Color?>>[];

      if (_isExiting && widget.exitMode != TransitionExitMode.fade) {
        // Reverse the color sequence for exit animations
        for (var i = animationColors.length - 1; i > 0; i--) {
          tweenItems.add(
            TweenSequenceItem(
              tween: ColorTween(
                begin: animationColors[i],
                end: animationColors[i - 1],
              ),
              weight: 1,
            ),
          );
        }
      } else {
        for (var i = 0; i < animationColors.length - 1; i++) {
          tweenItems.add(
            TweenSequenceItem(
              tween: ColorTween(
                begin: animationColors[i],
                end: animationColors[i + 1],
              ),
              weight: 1,
            ),
          );
        }
      }

      _colorAnimations = List.generate(
        numberOfRows,
        (rowIndex) {
          return List.generate(
            squaresPerRow,
            (index) {
              return TweenSequence<Color?>(tweenItems).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeIn,
                ),
              );
            },
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _playAnimation() {
    _controller.reset();
    _controller.forward();
  }

  void exit() {
    if (_isExiting) return;
    _isExiting = true;

    switch (widget.exitMode) {
      case TransitionExitMode.fade:
        // Fade out the entire transition
        _fadeController.reverse();
        break;
      case TransitionExitMode.reverse:
        // Reverse the animation (squares disappear in reverse order)
        _setupAnimations(_lastSize!.width, _lastSize!.height);
        _controller.reset();
        _controller.forward();
        break;
      case TransitionExitMode.sameDirection:
        // Continue in same direction (squares disappear in same order)
        _setupAnimations(_lastSize!.width, _lastSize!.height);
        _controller.reset();
        _controller.forward();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final newSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (newSize != _lastSize && !_isExiting) {
            _lastSize = newSize;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _setupAnimations(constraints.maxWidth, constraints.maxHeight);
                _playAnimation();
                setState(() {});
              }
            });
          }

          if (_positionAnimations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final squaresPerRow = widget.squaresPerRow;
          final squareSize = _isHorizontal 
              ? constraints.maxHeight / squaresPerRow 
              : constraints.maxWidth / squaresPerRow;
          
          // Calculate number of rows needed to fill the screen
          final numberOfRows = _isHorizontal 
              ? (constraints.maxWidth / squareSize).ceil()
              : (constraints.maxHeight / squareSize).ceil();

          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: _isHorizontal 
                ? List.generate(_positionAnimations[0].length, (index) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final position = _positionAnimations[0][index].value;
                        
                        // Calculate position for horizontal movement
                        final numberOfColumns = (constraints.maxWidth / squareSize).ceil();
                        final columnIndex = index % numberOfColumns;
                        final rowInColumn = index ~/ numberOfColumns;
                        
                        final top = rowInColumn * squareSize;
                        double left = 0;
                        
                        if (_effectiveDirection == TransitionDirection.left) {
                          // Move from right to left
                          final finalPosition = columnIndex * squareSize;
                          final startPosition = constraints.maxWidth; // Start from right
                          final currentPosition = startPosition - position * (startPosition - finalPosition);
                          left = currentPosition;
                        } else {
                          // Move from left to right
                          final finalPosition = (numberOfColumns - 1 - columnIndex) * squareSize;
                          final startPosition = -squareSize; // Start from left (off-screen)
                          final currentPosition = startPosition + position * (finalPosition - startPosition);
                          left = currentPosition;
                        }

                        final color = _colorAnimations[0][index].value;

                        return Positioned(
                          left: left,
                          top: top,
                          child: Opacity(
                            opacity: position > 0.0 ? 1.0 : 0.0,
                            child: Container(
                              width: squareSize,
                              height: squareSize,
                              color: color,
                            ),
                          ),
                        );
                      },
                    );
                  })
                : List.generate(numberOfRows, (rowIndex) {
                    return Stack(
                      children: List.generate(squaresPerRow, (index) {
                        return AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            final position = _positionAnimations[rowIndex][index].value;
                            
                            // Calculate position for vertical movement
                            double left = index * squareSize;
                            double top = 0;
                            
                            if (_effectiveDirection == TransitionDirection.top) {
                              // Move from bottom to top
                              final finalPosition = rowIndex * squareSize;
                              final startPosition = constraints.maxHeight; // Start from bottom
                              final currentPosition = startPosition - position * (startPosition - finalPosition);
                              top = currentPosition;
                            } else {
                              // Move from top to bottom (default)
                              final finalPosition = (numberOfRows - 1 - rowIndex) * squareSize;
                              final startPosition = 0; // Start from top
                              final currentPosition = startPosition + position * (finalPosition - startPosition);
                              top = currentPosition;
                            }

                            final color = _colorAnimations[rowIndex][index].value;

                            return Positioned(
                              left: left,
                              top: top,
                              child: Opacity(
                                opacity: position > 0.0 ? 1.0 : 0.0,
                                child: Container(
                                  width: squareSize,
                                  height: squareSize,
                                  color: color,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    );
                  }),
            ),
          );
        },
      ),
    );
  }
} 