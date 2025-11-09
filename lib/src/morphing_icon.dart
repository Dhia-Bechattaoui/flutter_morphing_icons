import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'morphing_icon_controller.dart';
import 'morphing_animation_types.dart';

/// A widget that provides smooth morphing animations between different icon states.
///
/// This widget can animate between different icons, widgets, or any other visual
/// elements with customizable transition effects.
class MorphingIcon extends StatefulWidget {
  /// List of states to morph between
  final List<Widget> states;

  /// Animation configuration
  final MorphingAnimationConfig? config;

  /// Initial state index
  final int initialState;

  /// Size of the icon
  final double? size;

  /// Color of the icon
  final Color? color;

  /// Whether to auto-animate on state changes
  final bool autoAnimate;

  /// Callback when state changes
  final void Function(int state)? onStateChanged;

  /// Callback when animation completes
  final VoidCallback? onAnimationComplete;

  /// Creates a MorphingIcon widget
  MorphingIcon({
    super.key,
    required this.states,
    this.config,
    this.initialState = 0,
    this.size,
    this.color,
    this.autoAnimate = true,
    this.onStateChanged,
    this.onAnimationComplete,
  }) : assert(states.isNotEmpty, 'States list cannot be empty'),
       assert(
         initialState >= 0 && initialState < states.length,
         'Initial state must be within bounds',
       );

  /// Creates a MorphingIcon with IconData states
  MorphingIcon.icons({
    super.key,
    required List<IconData> icons,
    this.config,
    this.initialState = 0,
    this.size,
    this.color,
    this.autoAnimate = true,
    this.onStateChanged,
    this.onAnimationComplete,
  }) : states = icons
           .map((icon) => Icon(icon, size: size, color: color))
           .toList(),
       assert(icons.isNotEmpty, 'Icons list cannot be empty'),
       assert(
         initialState >= 0 && initialState < icons.length,
         'Initial state must be within bounds',
       );

  /// Returns the internal [MorphingIconController] for the nearest
  /// [MorphingIcon] ancestor in the widget tree, or `null` if none exists.
  static MorphingIconController? controllerOf(BuildContext context) {
    final state = context.findAncestorStateOfType<_MorphingIconState>();
    return state?._controller;
  }

  @override
  State<MorphingIcon> createState() => _MorphingIconState();
}

class _MorphingIconState extends State<MorphingIcon>
    with TickerProviderStateMixin {
  late MorphingIconController _controller;
  late int _currentState;
  int _transitionSeed = 0;

  void _initializeController({required int initialState}) {
    final dynamicStates = widget.states.cast<dynamic>();
    final clampedState = initialState
        .clamp(0, dynamicStates.length - 1)
        .toInt();
    _controller = MorphingIconController(
      states: dynamicStates,
      vsync: this,
      config: widget.config,
      initialState: clampedState,
    );

    _controller.addListener(_onControllerChanged);
  }

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;

    _initializeController(initialState: _currentState);
  }

  @override
  void didUpdateWidget(MorphingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    final didStatesChange = oldWidget.states != widget.states;
    final didConfigChange = oldWidget.config != widget.config;

    if (didStatesChange || didConfigChange) {
      _controller.removeListener(_onControllerChanged);
      _controller.dispose();
      final clampedState = _currentState
          .clamp(0, widget.states.length - 1)
          .toInt();
      _currentState = clampedState;
      _transitionSeed++;
      _initializeController(initialState: _currentState);
    }
  }

  void _onControllerChanged() {
    if (!mounted) return;

    final nextState = _controller.currentState;
    if (nextState != _currentState) {
      setState(() {
        _currentState = nextState;
        _transitionSeed++;
      });
      widget.onStateChanged?.call(_currentState);
    }
  }

  Widget _buildCustomAnimation() {
    final config = _controller.config;
    final params = config.parameters;

    final bool fadeEnabled = params['fade'] as bool? ?? true;
    final double fadeBegin = (params['fadeBegin'] as num?)?.toDouble() ?? 0.0;
    final double fadeEnd = (params['fadeEnd'] as num?)?.toDouble() ?? 1.0;

    final bool scaleEnabled = params['scale'] as bool? ?? false;
    final double scaleBegin = (params['scaleBegin'] as num?)?.toDouble() ?? 1.0;
    final double scaleEnd =
        (params['scaleEnd'] as num?)?.toDouble() ??
        (params['scaleFactor'] as num?)?.toDouble() ??
        1.0;

    final bool slideEnabled = params['slide'] as bool? ?? false;
    final Offset slideBegin =
        params['slideBegin'] as Offset? ??
        params['slideOffset'] as Offset? ??
        const Offset(0, 0);
    final Offset slideEnd = params['slideEnd'] as Offset? ?? Offset.zero;

    final bool rotateEnabled = params['rotate'] as bool? ?? false;
    final double rotationBegin =
        (params['rotationBegin'] as num?)?.toDouble() ?? 0.0;
    final double rotationEnd =
        (params['rotationEnd'] as num?)?.toDouble() ??
        (params['rotationAngle'] as num?)?.toDouble() ??
        0.0;

    final customBuilder = config.customBuilder;

    final previousIndex = _controller.previousState;
    final currentIndex = _controller.currentState;

    return AnimatedBuilder(
      animation: _controller.animation,
      builder: (context, _) {
        final t = _controller.animation.value.clamp(0.0, 1.0);
        final incomingProgress = t;
        final outgoingProgress = t;

        Widget buildTransformed(Widget child, double progress, bool entering) {
          Widget result = child;

          if (scaleEnabled) {
            final double start = entering ? scaleBegin : scaleEnd;
            final double end = entering ? scaleEnd : scaleBegin;
            final double scaleValue = _lerpDoubleNonNull(start, end, progress);
            result = Transform.scale(scale: scaleValue, child: result);
          }

          if (rotateEnabled) {
            final double start = entering ? rotationBegin : rotationEnd;
            final double end = entering ? rotationEnd : rotationBegin;
            final double angleValue = _lerpDoubleNonNull(start, end, progress);
            result = Transform.rotate(angle: angleValue, child: result);
          }

          if (slideEnabled) {
            final Offset start = entering ? slideBegin : slideEnd;
            final Offset end = entering ? slideEnd : slideBegin;
            final Offset offsetValue = Offset.lerp(start, end, progress) ?? end;
            result = Transform.translate(offset: offsetValue, child: result);
          }

          if (customBuilder != null) {
            result = customBuilder(
              result,
              AlwaysStoppedAnimation<double>(progress),
            );
          }

          if (fadeEnabled) {
            final double start = entering ? fadeBegin : fadeEnd;
            final double end = entering ? fadeEnd : fadeBegin;
            final double opacity = _lerpDoubleNonNull(
              start,
              end,
              progress,
            ).clamp(0.0, 1.0);
            result = Opacity(opacity: opacity, child: result);
          }

          return result;
        }

        final Widget incoming = buildTransformed(
          widget.states[currentIndex],
          incomingProgress,
          true,
        );

        if (previousIndex == currentIndex) {
          return incoming;
        }

        final Widget outgoing = buildTransformed(
          widget.states[previousIndex],
          outgoingProgress,
          false,
        );

        return Stack(
          alignment: Alignment.center,
          children: [outgoing, incoming],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config ?? const MorphingAnimationConfig();

    switch (config.type) {
      case MorphingAnimationType.crossFade:
        return _buildCrossFadeAnimation();
      case MorphingAnimationType.scale:
        return _buildScaleAnimation();
      case MorphingAnimationType.slide:
        return _buildSlideAnimation();
      case MorphingAnimationType.rotate:
        return _buildRotateAnimation();
      case MorphingAnimationType.custom:
        return _buildCustomAnimation();
    }
  }

  Widget _buildCrossFadeAnimation() {
    return AnimatedSwitcher(
      duration: _controller.config.duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final curved = animation.drive(
          CurveTween(curve: _controller.config.curve),
        );
        return FadeTransition(opacity: curved, child: child);
      },
      child: KeyedSubtree(
        key: ValueKey('${_currentState}_$_transitionSeed'),
        child: widget.states[_currentState],
      ),
    );
  }

  Widget _buildScaleAnimation() {
    final scaleFactor = _controller.config.parameters['scaleFactor'] ?? 1.2;
    return AnimatedSwitcher(
      duration: _controller.config.duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final curved = animation.drive(
          CurveTween(curve: _controller.config.curve),
        );
        final scale = curved.drive(Tween<double>(begin: 1.0, end: scaleFactor));
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: scale, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey('${_currentState}_$_transitionSeed'),
        child: widget.states[_currentState],
      ),
    );
  }

  Widget _buildSlideAnimation() {
    final slideOffset =
        _controller.config.parameters['slideOffset'] ?? const Offset(0, -20);
    return AnimatedSwitcher(
      duration: _controller.config.duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final curved = animation.drive(
          CurveTween(curve: _controller.config.curve),
        );
        final slide = curved.drive(
          Tween<Offset>(begin: slideOffset, end: Offset.zero),
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey('${_currentState}_$_transitionSeed'),
        child: widget.states[_currentState],
      ),
    );
  }

  Widget _buildRotateAnimation() {
    final rotationAngle = _controller.config.parameters['rotationAngle'] ?? 0.5;
    return AnimatedSwitcher(
      duration: _controller.config.duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final curved = animation.drive(
          CurveTween(curve: _controller.config.curve),
        );
        final rotation = curved.drive(
          Tween<double>(begin: 0.0, end: rotationAngle),
        );

        return FadeTransition(
          opacity: curved,
          child: RotationTransition(turns: rotation, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey('${_currentState}_$_transitionSeed'),
        child: widget.states[_currentState],
      ),
    );
  }

  /// Moves to the next state
  void next() {
    _controller.next();
  }

  /// Moves to the previous state
  void previous() {
    _controller.previous();
  }

  /// Moves to a specific state
  void goTo(int stateIndex) {
    _controller.goTo(stateIndex);
  }

  /// Toggles between two states
  void toggle() {
    _controller.toggle();
  }

  /// Replays the current state's animation
  void replay() {
    setState(() {
      _transitionSeed++;
    });
    _controller.replay();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }
}

double _lerpDoubleNonNull(double a, double b, double t) {
  return lerpDouble(a, b, t) ?? (a + (b - a) * t);
}
