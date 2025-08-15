import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_morphing_icons/flutter_morphing_icons.dart';

void main() {
  group('MorphingIcon Widget Tests', () {
    testWidgets('should render with basic configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MorphingIcon.icons(
              icons: [Icons.favorite_border, Icons.favorite],
              size: 32,
              color: Colors.red,
            ),
          ),
        ),
      );

      expect(find.byType(MorphingIcon), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should handle state changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MorphingIcon.icons(
              icons: [Icons.play_arrow, Icons.pause, Icons.stop],
              initialState: 0,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should work with custom animation config',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MorphingIcon(
              states: [
                const Icon(Icons.star_border),
                const Icon(Icons.star),
              ],
              config: MorphingAnimationConfig.scale(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                scaleFactor: 1.5,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(MorphingIcon), findsOneWidget);
    });

    testWidgets('should handle empty states list', (WidgetTester tester) async {
      expect(
        () => MorphingIcon(states: []),
        throwsAssertionError,
      );
    });

    testWidgets('should handle invalid initial state',
        (WidgetTester tester) async {
      expect(
        () => MorphingIcon.icons(
          icons: [Icons.favorite],
          initialState: 5,
        ),
        throwsAssertionError,
      );
    });
  });

  group('MorphingAnimationConfig Tests', () {
    test('should create crossFade config correctly', () {
      const config = MorphingAnimationConfig.crossFade(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      expect(config.type, equals(MorphingAnimationType.crossFade));
      expect(config.duration, equals(const Duration(milliseconds: 300)));
      expect(config.curve, equals(Curves.easeInOut));
    });

    test('should create scale config correctly', () {
      final config = MorphingAnimationConfig.scale(
        duration: const Duration(milliseconds: 400),
        curve: Curves.bounceOut,
        scaleFactor: 1.3,
      );

      expect(config.type, equals(MorphingAnimationType.scale));
      expect(config.duration, equals(const Duration(milliseconds: 400)));
      expect(config.curve, equals(Curves.bounceOut));
      expect(config.parameters['scaleFactor'], equals(1.3));
    });

    test('should create slide config correctly', () {
      const slideOffset = Offset(0, -30);
      final config = MorphingAnimationConfig.slide(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        slideOffset: slideOffset,
      );

      expect(config.type, equals(MorphingAnimationType.slide));
      expect(config.parameters['slideOffset'], equals(slideOffset));
    });

    test('should create rotate config correctly', () {
      final config = MorphingAnimationConfig.rotate(
        duration: const Duration(milliseconds: 600),
        curve: Curves.elasticOut,
        rotationAngle: 0.8,
      );

      expect(config.type, equals(MorphingAnimationType.rotate));
      expect(config.parameters['rotationAngle'], equals(0.8));
    });

    test('should create custom config correctly', () {
      Widget customBuilder(Widget child, Animation<double> animation) =>
          Opacity(opacity: animation.value, child: child);

      final config = MorphingAnimationConfig.custom(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: customBuilder,
      );

      expect(config.type, equals(MorphingAnimationType.custom));
      expect(config.customBuilder, equals(customBuilder));
    });
  });

  group('MorphingAnimationType Tests', () {
    test('should have correct enum values', () {
      expect(MorphingAnimationType.values.length, equals(5));
      expect(MorphingAnimationType.crossFade, isA<MorphingAnimationType>());
      expect(MorphingAnimationType.scale, isA<MorphingAnimationType>());
      expect(MorphingAnimationType.slide, isA<MorphingAnimationType>());
      expect(MorphingAnimationType.rotate, isA<MorphingAnimationType>());
      expect(MorphingAnimationType.custom, isA<MorphingAnimationType>());
    });
  });
}
