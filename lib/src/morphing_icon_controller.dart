import 'package:flutter/material.dart';
import 'morphing_animation_types.dart';

/// Controller for managing morphing icon state transitions
class MorphingIconController extends ChangeNotifier {
  /// Current state of the icon
  int _currentState = 0;

  /// List of available states
  final List<dynamic> _states;

  /// Animation configuration
  final MorphingAnimationConfig _config;

  /// Animation controller
  late AnimationController _animationController;

  /// Current animation
  late Animation<double> _animation;

  /// Creates a MorphingIconController
  ///
  /// [states] - List of states (icons, widgets, etc.) to morph between
  /// [config] - Animation configuration
  /// [vsync] - Ticker provider for animations
  MorphingIconController({
    required List<dynamic> states,
    required TickerProvider vsync,
    MorphingAnimationConfig? config,
  })  : _states = states,
        _config = config ?? const MorphingAnimationConfig() {
    _animationController = AnimationController(
      duration: _config.duration,
      vsync: vsync,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: _config.curve,
    ));
  }

  /// Current state index
  int get currentState => _currentState;

  /// Total number of states
  int get stateCount => _states.length;

  /// Current state value
  dynamic get currentStateValue => _states[_currentState];

  /// Animation controller
  AnimationController get animationController => _animationController;

  /// Current animation
  Animation<double> get animation => _animation;

  /// Animation configuration
  MorphingAnimationConfig get config => _config;

  /// Moves to the next state with animation
  void next() {
    if (_currentState < _states.length - 1) {
      _currentState++;
      _animate();
    }
  }

  /// Moves to the previous state with animation
  void previous() {
    if (_currentState > 0) {
      _currentState--;
      _animate();
    }
  }

  /// Moves to a specific state with animation
  void goTo(int stateIndex) {
    if (stateIndex >= 0 && stateIndex < _states.length) {
      _currentState = stateIndex;
      _animate();
    }
  }

  /// Moves to the first state with animation
  void goToFirst() {
    _currentState = 0;
    _animate();
  }

  /// Moves to the last state with animation
  void goToLast() {
    _currentState = _states.length - 1;
    _animate();
  }

  /// Toggles between two states (useful for boolean states)
  void toggle() {
    if (_states.length == 2) {
      _currentState = _currentState == 0 ? 1 : 0;
      _animate();
    }
  }

  /// Animates the transition
  void _animate() {
    _animationController.reset();
    _animationController.forward();
    notifyListeners();
  }

  /// Checks if the controller is at the first state
  bool get isFirst => _currentState == 0;

  /// Checks if the controller is at the last state
  bool get isLast => _currentState == _states.length - 1;

  /// Checks if the controller can go to the next state
  bool get canGoNext => _currentState < _states.length - 1;

  /// Checks if the controller can go to the previous state
  bool get canGoPrevious => _currentState > 0;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
