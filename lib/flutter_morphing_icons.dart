/// A Flutter package that provides smooth icon morphing animations between different states.
///
/// This package offers a comprehensive solution for creating beautiful, customizable
/// transitions between different icon states in Flutter applications. It supports
/// multiple animation types including cross-fade, scale, slide, rotate, and custom
/// animations.
///
/// ## Features
///
/// - **Multiple Animation Types**: Cross-fade, scale, slide, rotate, and custom animations
/// - **Customizable Parameters**: Duration, curves, and animation-specific parameters
/// - **Easy to Use**: Simple API with intuitive controls
/// - **Flexible**: Support for icons, custom widgets, and any visual elements
/// - **Performance Optimized**: Efficient animations with minimal overhead
///
/// ## Getting Started
///
/// ```dart
/// import 'package:flutter_morphing_icons/flutter_morphing_icons.dart';
///
/// MorphingIcon.icons(
///   icons: [Icons.favorite_border, Icons.favorite],
///   size: 32,
///   color: Colors.red,
/// )
/// ```
///
/// For more information, see the [README](https://github.com/Dhia-Bechattaoui/flutter_morphing_icons).
library flutter_morphing_icons;

export 'src/morphing_icon.dart';
export 'src/morphing_icon_controller.dart';
export 'src/morphing_animation_types.dart';
