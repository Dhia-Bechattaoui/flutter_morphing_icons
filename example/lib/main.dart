import 'package:flutter/material.dart';
import 'package:flutter_morphing_icons/flutter_morphing_icons.dart';

void main() {
  runApp(const MorphingIconsApp());
}

class MorphingIconsApp extends StatelessWidget {
  const MorphingIconsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Morphing Icons Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MorphingIconsDemo(),
    );
  }
}

class MorphingIconsDemo extends StatefulWidget {
  const MorphingIconsDemo({super.key});

  @override
  State<MorphingIconsDemo> createState() => _MorphingIconsDemoState();
}

class _MorphingIconsDemoState extends State<MorphingIconsDemo> {
  int _currentAnimationType = 0;
  final List<String> _animationTypes = [
    'Cross Fade',
    'Scale',
    'Slide',
    'Rotate',
    'Custom',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Morphing Icons Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Animation Type: ${_animationTypes[_currentAnimationType]}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Center(
              child: _buildMorphingIcon(),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentAnimationType =
                          (_currentAnimationType + 1) % _animationTypes.length;
                    });
                  },
                  child: const Text('Change Animation'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // This would trigger the morphing animation
                    // In a real app, you'd have a controller to manage this
                  },
                  child: const Text('Trigger Animation'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Examples:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildExampleSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMorphingIcon() {
    final configs = [
      const MorphingAnimationConfig.crossFade(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      MorphingAnimationConfig.scale(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        scaleFactor: 1.3,
      ),
      MorphingAnimationConfig.slide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        slideOffset: const Offset(0, -20),
      ),
      MorphingAnimationConfig.rotate(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        rotationAngle: 0.5,
      ),
      MorphingAnimationConfig.custom(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        builder: (child, animation) {
          return Transform.scale(
            scale: 1.0 + (animation.value * 0.3),
            child: Transform.rotate(
              angle: animation.value * 0.5,
              child: Opacity(opacity: animation.value, child: child),
            ),
          );
        },
      ),
    ];

    return MorphingIcon(
      states: [
        const Icon(Icons.favorite_border, size: 64, color: Colors.red),
        const Icon(Icons.favorite, size: 64, color: Colors.red),
        const Icon(Icons.favorite_border, size: 64, color: Colors.blue),
        const Icon(Icons.favorite, size: 64, color: Colors.blue),
      ],
      config: configs[_currentAnimationType],
      onStateChanged: (state) {
        print('Current state: $state');
      },
      onAnimationComplete: () {
        print('Animation completed!');
      },
    );
  }

  Widget _buildExampleSection() {
    return Column(
      children: [
        _buildExampleCard(
          'Play/Pause Button',
          MorphingIcon.icons(
            icons: [Icons.play_arrow, Icons.pause],
            size: 32,
            color: Colors.green,
            config: MorphingAnimationConfig.scale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              scaleFactor: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildExampleCard(
          'Loading States',
          MorphingIcon.icons(
            icons: [
              Icons.hourglass_empty,
              Icons.hourglass_bottom,
              Icons.hourglass_full,
            ],
            config: MorphingAnimationConfig.rotate(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.linear,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildExampleCard(
          'Custom Widgets',
          MorphingIcon(
            states: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ],
            config: MorphingAnimationConfig.slide(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              slideOffset: const Offset(20, 0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExampleCard(String title, Widget morphingIcon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            morphingIcon,
          ],
        ),
      ),
    );
  }
}
