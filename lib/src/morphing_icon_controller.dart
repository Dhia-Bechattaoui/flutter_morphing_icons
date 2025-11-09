import 'package:flutter/material.dart';
import 'morphing_animation_types.dart';

/// Controller for managing morphing icon state transitions
class MorphingIconController extends ChangeNotifier {
  /// Current state of the icon
  int _currentState;
  int _previousState;

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
    int initialState = 0,
    MorphingAnimationConfig? config,
  }) : assert(states.isNotEmpty, 'States cannot be empty'),
       assert(
         initialState >= 0 && initialState < states.length,
         'Initial state must be within bounds',
       ),
       _states = states,
       _currentState = initialState,
       _previousState = initialState,
       _config = config ?? const MorphingAnimationConfig() {
    _animationController = AnimationController(
      duration: _config.duration,
      vsync: vsync,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: _config.curve),
    );
    _animationController.value = 1.0;
  }

  /// Current state index
  int get currentState => _currentState;
  int get previousState => _previousState;

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

  void _setState(int newState) {
    if (newState == _currentState) return;
    _previousState = _currentState;
    _currentState = newState;
    _animate();
  }

  /// Moves to the next state with animation
  void next() {
    if (_currentState < _states.length - 1) {
      _setState(_currentState + 1);
    }
  }

  /// Moves to the previous state with animation
  void previous() {
    if (_currentState > 0) {
      _setState(_currentState - 1);
    }
  }

  /// Moves to a specific state with animation
  void goTo(int stateIndex) {
    if (stateIndex >= 0 && stateIndex < _states.length) {
      _setState(stateIndex);
    }
  }

  /// Jumps to a specific state without animation
  void jumpTo(int stateIndex) {
    if (stateIndex >= 0 && stateIndex < _states.length) {
      _previousState = _currentState;
      _currentState = stateIndex;
      _animationController.value = 1.0;
      notifyListeners();
    }
  }

  /// Replays the current state's animation
  void replay() {
    _previousState = _currentState;
    _animate();
  }

  /// Moves to the first state with animation
  void goToFirst() {
    _setState(0);
  }

  /// Moves to the last state with animation
  void goToLast() {
    _setState(_states.length - 1);
  }

  /// Toggles between two states (useful for boolean states)
  void toggle() {
    if (_states.length == 2) {
      _setState(_currentState == 0 ? 1 : 0);
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
