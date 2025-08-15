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
  })  : assert(states.isNotEmpty, 'States list cannot be empty'),
        assert(initialState >= 0 && initialState < states.length,
            'Initial state must be within bounds');

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
  })  : states =
            icons.map((icon) => Icon(icon, size: size, color: color)).toList(),
        assert(icons.isNotEmpty, 'Icons list cannot be empty'),
        assert(initialState >= 0 && initialState < icons.length,
            'Initial state must be within bounds');

  @override
  State<MorphingIcon> createState() => _MorphingIconState();
}

class _MorphingIconState extends State<MorphingIcon>
    with TickerProviderStateMixin {
  late MorphingIconController _controller;
  late int _currentState;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;

    // Convert states to dynamic list for controller
    final dynamicStates = widget.states.cast<dynamic>();

    _controller = MorphingIconController(
      states: dynamicStates,
      vsync: this,
      config: widget.config,
    );

    _controller.addListener(_onControllerChanged);

    // Set initial state
    if (widget.initialState > 0) {
      _controller.goTo(widget.initialState);
    }
  }

  @override
  void didUpdateWidget(MorphingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.states != widget.states) {
      // Recreate controller if states changed
      _controller.dispose();
      final dynamicStates = widget.states.cast<dynamic>();
      _controller = MorphingIconController(
        states: dynamicStates,
        vsync: this,
        config: widget.config,
      );
      _controller.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {
        _currentState = _controller.currentState;
      });

      widget.onStateChanged?.call(_currentState);

      if (_controller.animationController.status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller.animation,
      builder: (context, child) {
        return _buildAnimatedIcon();
      },
    );
  }

  Widget _buildAnimatedIcon() {
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
      key: ValueKey(_currentState),
      duration: _controller.config.duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: widget.states[_currentState],
    );
  }

  Widget _buildScaleAnimation() {
    final scaleFactor = _controller.config.parameters['scaleFactor'] ?? 1.2;
    final scale = Tween<double>(
      begin: 1.0,
      end: scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller.animation,
      curve: Curves.easeInOut,
    ));

    return AnimatedBuilder(
      animation: scale,
      builder: (context, child) {
        return Transform.scale(
          scale: scale.value,
          child: Opacity(
            opacity: _controller.animation.value,
            child: widget.states[_currentState],
          ),
        );
      },
    );
  }

  Widget _buildSlideAnimation() {
    final slideOffset =
        _controller.config.parameters['slideOffset'] ?? const Offset(0, -20);
    final slide = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller.animation,
      curve: Curves.easeInOut,
    ));

    return AnimatedBuilder(
      animation: slide,
      builder: (context, child) {
        return Transform.translate(
          offset: slide.value,
          child: Opacity(
            opacity: _controller.animation.value,
            child: widget.states[_currentState],
          ),
        );
      },
    );
  }

  Widget _buildRotateAnimation() {
    final rotationAngle = _controller.config.parameters['rotationAngle'] ?? 0.5;
    final rotation = Tween<double>(
      begin: 0.0,
      end: rotationAngle,
    ).animate(CurvedAnimation(
      parent: _controller.animation,
      curve: Curves.easeInOut,
    ));

    return AnimatedBuilder(
      animation: rotation,
      builder: (context, child) {
        return Transform.rotate(
          angle: rotation.value,
          child: Opacity(
            opacity: _controller.animation.value,
            child: widget.states[_currentState],
          ),
        );
      },
    );
  }

  Widget _buildCustomAnimation() {
    final customBuilder = _controller.config.customBuilder;
    if (customBuilder != null) {
      return customBuilder(
        widget.states[_currentState],
        _controller.animation,
      );
    }
    return widget.states[_currentState];
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

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }
}
