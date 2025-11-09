import 'package:flutter/material.dart';

/// Defines the different types of morphing animations available.
enum MorphingAnimationType {
  /// Smooth cross-fade between icons
  crossFade,

  /// Scale and fade animation
  scale,

  /// Slide transition animation
  slide,

  /// Rotate and fade animation
  rotate,

  /// Custom animation defined by user
  custom,
}

/// Configuration for morphing animations
class MorphingAnimationConfig {
  /// The type of animation to use
  final MorphingAnimationType type;

  /// Duration of the animation
  final Duration duration;

  /// Curve for the animation
  final Curve curve;

  /// Custom animation builder (used when type is custom)
  final Widget Function(Widget child, Animation<double> animation)?
  customBuilder;

  /// Additional parameters for specific animation types
  final Map<String, dynamic> parameters;

  /// Creates a new [MorphingAnimationConfig] with the specified parameters.
  ///
  /// [type] - The type of animation to use (defaults to crossFade)
  /// [duration] - The duration of the animation (defaults to 300ms)
  /// [curve] - The curve for the animation (defaults to Curves.easeInOut)
  /// [customBuilder] - Custom animation builder for custom animations
  /// [parameters] - Additional parameters for specific animation types
  const MorphingAnimationConfig({
    this.type = MorphingAnimationType.crossFade,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.customBuilder,
    this.parameters = const {},
  });

  /// Creates a cross-fade animation configuration
  const MorphingAnimationConfig.crossFade({
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) : this(
         type: MorphingAnimationType.crossFade,
         duration: duration,
         curve: curve,
       );

  /// Creates a scale animation configuration
  MorphingAnimationConfig.scale({
    required this.duration,
    required this.curve,
    double scaleFactor = 1.2,
  }) : type = MorphingAnimationType.scale,
       customBuilder = null,
       parameters = {'scaleFactor': scaleFactor};

  /// Creates a slide animation configuration
  MorphingAnimationConfig.slide({
    required this.duration,
    required this.curve,
    Offset slideOffset = const Offset(0, -0.25),
  }) : type = MorphingAnimationType.slide,
       customBuilder = null,
       parameters = {'slideOffset': slideOffset};

  /// Creates a rotate animation configuration
  MorphingAnimationConfig.rotate({
    required this.duration,
    required this.curve,
    double rotationAngle = 0.5,
  }) : type = MorphingAnimationType.rotate,
       customBuilder = null,
       parameters = {'rotationAngle': rotationAngle};

  /// Creates a custom animation configuration
  MorphingAnimationConfig.custom({
    Widget Function(Widget child, Animation<double> animation)? builder,
    required this.duration,
    required this.curve,
    this.parameters = const {},
  }) : type = MorphingAnimationType.custom,
       customBuilder = builder;
}
