# flutter_morphing_icons

A Flutter package that provides smooth icon morphing animations between different states with customizable transitions and easing curves.

[![pub package](https://img.shields.io/pub/v/flutter_morphing_icons.svg)](https://pub.dev/packages/flutter_morphing_icons)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.32+-blue.svg)](https://flutter.dev)

## Features

- 🎨 **Smooth Animations**: Beautiful morphing transitions between icon states
- 🔧 **Customizable**: Multiple animation types and configurable parameters
- 🎯 **Easy to Use**: Simple API with intuitive controls
- 📱 **Responsive**: Works seamlessly across different screen sizes
- ⚡ **Performance**: Optimized animations with minimal overhead
- 🎭 **Flexible**: Support for icons, custom widgets, and any visual elements

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_morphing_icons: ^0.1.0
```

### Basic Usage

```dart
import 'package:flutter_morphing_icons/flutter_morphing_icons.dart';

// Simple morphing between icons
MorphingIcon.icons(
  icons: [Icons.favorite_border, Icons.favorite],
  size: 32,
  color: Colors.red,
  onStateChanged: (state) {
    print('Current state: $state');
  },
)
```

### Advanced Usage

```dart
// Custom animation configuration
MorphingIcon(
  states: [
    Icon(Icons.play_arrow, size: 32, color: Colors.green),
    Icon(Icons.pause, size: 32, color: Colors.orange),
    Icon(Icons.stop, size: 32, color: Colors.red),
  ],
  config: MorphingAnimationConfig.scale(
    duration: Duration(milliseconds: 500),
    curve: Curves.elasticOut,
    scaleFactor: 1.5,
  ),
  onAnimationComplete: () {
    print('Animation completed!');
  },
)
```

## Animation Types

### 1. Cross Fade (Default)
Smooth fade transition between states.

```dart
MorphingAnimationConfig.crossFade(
  duration: Duration(milliseconds: 300),
  curve: Curves.easeInOut,
)
```

### 2. Scale
Scale and fade animation with customizable scale factor.

```dart
MorphingAnimationConfig.scale(
  duration: Duration(milliseconds: 400),
  curve: Curves.bounceOut,
  scaleFactor: 1.3,
)
```

### 3. Slide
Slide transition with customizable offset.

```dart
MorphingAnimationConfig.slide(
  duration: Duration(milliseconds: 350),
  curve: Curves.easeInOut,
  slideOffset: Offset(0, -30),
)
```

### 4. Rotate
Rotation animation with customizable angle.

```dart
MorphingAnimationConfig.rotate(
  duration: Duration(milliseconds: 600),
  curve: Curves.elasticOut,
  rotationAngle: 0.8,
)
```

### 5. Custom
Define your own animation logic.

```dart
MorphingAnimationConfig.custom(
  duration: const Duration(milliseconds: 800),
  curve: Curves.easeInOut,
  parameters: {
    'fade': true,
    'fadeBegin': 0.2,
    'fadeEnd': 1.0,
    'scale': true,
    'scaleBegin': 0.5,
    'scaleEnd': 1.2,
    'slide': true,
    'slideBegin': const Offset(0, 0.2),
    'slideEnd': Offset.zero,
    'rotate': true,
    'rotationBegin': 0.0,
    'rotationEnd': 2 * math.pi,
  },
)
```

### Full Custom Animation Widget

```dart
import 'dart:math' as math;

class PulsingStar extends StatelessWidget {
  const PulsingStar({super.key});

  @override
  Widget build(BuildContext context) {
    return MorphingIcon(
      states: const [
        Icon(Icons.star_border, size: 80, color: Colors.amber),
        Icon(Icons.star, size: 80, color: Colors.amber),
      ],
      config: MorphingAnimationConfig.custom(
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
        parameters: {
          'fade': true,
          'fadeBegin': 0.0,
          'fadeEnd': 1.0,
          'scale': true,
          'scaleBegin': 0.5,
          'scaleEnd': 1.3,
          'rotate': true,
          'rotationBegin': 0.0,
          'rotationEnd': math.pi,
          'slide': true,
          'slideBegin': const Offset(0, 0.3),
          'slideEnd': Offset.zero,
        },
      ),
    );
  }
}
```

## API Reference

### MorphingIcon

The main widget for creating morphing icon animations.

#### Constructor

```dart
MorphingIcon({
  Key? key,
  required List<Widget> states,
  MorphingAnimationConfig? config,
  int initialState = 0,
  double? size,
  Color? color,
  bool autoAnimate = true,
  void Function(int state)? onStateChanged,
  VoidCallback? onAnimationComplete,
})
```

#### Named Constructor

```dart
MorphingIcon.icons({
  Key? key,
  required List<IconData> icons,
  MorphingAnimationConfig? config,
  int initialState = 0,
  double? size,
  Color? color,
  bool autoAnimate = true,
  void Function(int state)? onStateChanged,
  VoidCallback? onAnimationComplete,
})
```

### MorphingIconController

Controller for programmatically managing icon state transitions.

```dart
final controller = MorphingIconController(
  states: [icon1, icon2, icon3],
  vsync: this,
  config: MorphingAnimationConfig.crossFade(),
);

// Control methods
controller.next();           // Go to next state
controller.previous();       // Go to previous state
controller.goTo(2);         // Go to specific state
controller.toggle();        // Toggle between two states
controller.goToFirst();     // Go to first state
controller.goToLast();      // Go to last state
```

## Examples

### Play/Pause Button

```dart
class PlayPauseButton extends StatefulWidget {
  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isPlaying = !isPlaying;
        });
      },
      child: MorphingIcon.icons(
        icons: [Icons.play_arrow, Icons.pause],
        initialState: isPlaying ? 1 : 0,
        size: 48,
        color: Colors.blue,
        config: MorphingAnimationConfig.scale(
          scaleFactor: 1.2,
          curve: Curves.elasticOut,
        ),
      ),
    );
  }
}
```

### Loading States

```dart
MorphingIcon.icons(
  icons: [
    Icons.hourglass_empty,
    Icons.hourglass_bottom,
    Icons.hourglass_full,
  ],
  config: MorphingAnimationConfig.rotate(
    duration: Duration(milliseconds: 1000),
    curve: Curves.linear,
  ),
  onAnimationComplete: () {
    // Cycle through states continuously
    // Implementation depends on your use case
  },
)
```

### Custom Widget States

```dart
MorphingIcon(
  states: [
    Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.check, color: Colors.white, size: 20),
    ),
    Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.close, color: Colors.white, size: 20),
    ),
  ],
  config: MorphingAnimationConfig.slide(
    slideOffset: Offset(20, 0),
  ),
)
```

## Platform Support

This package is implemented entirely in Dart and is compatible with the following Flutter targets out of the box:

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ WASM-enabled Flutter builds

No platform-specific code is required; the animations run anywhere Flutter runs.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please:

1. Check the [documentation](https://pub.dev/documentation/flutter_morphing_icons)
2. Search [existing issues](https://github.com/Dhia-Bechattaoui/flutter_morphing_icons/issues)
3. Create a new issue if your problem isn't already addressed

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.
