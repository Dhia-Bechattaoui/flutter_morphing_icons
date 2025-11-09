import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_morphing_icons/flutter_morphing_icons.dart';

void main() {
  group('MorphingIcon Widget Tests', () {
    testWidgets('should render with basic configuration', (
      WidgetTester tester,
    ) async {
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

    testWidgets('should work with custom animation config', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MorphingIcon(
              states: const [Icon(Icons.star_border), Icon(Icons.star)],
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

    testWidgets('combined fade+scale+slide+rotate animates smoothly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MorphingIcon(
              states: const [
                Icon(Icons.favorite_border, size: 48, color: Colors.pink),
                Icon(Icons.favorite, size: 48, color: Colors.pink),
              ],
              config: MorphingAnimationConfig.custom(
                duration: const Duration(milliseconds: 600),
                curve: Curves.linear,
                parameters: {
                  'fade': true,
                  'fadeBegin': 0.0,
                  'fadeEnd': 1.0,
                  'scale': true,
                  'scaleBegin': 0.5,
                  'scaleEnd': 1.2,
                  'slide': true,
                  'slideBegin': const Offset(0, 0.25),
                  'slideEnd': Offset.zero,
                  'rotate': true,
                  'rotationBegin': 0.0,
                  'rotationEnd': math.pi,
                },
              ),
            ),
          ),
        ),
      );

      final element = tester.element(find.byType(MorphingIcon));
      final controller = MorphingIcon.controllerOf(element)!;

      controller.goTo(1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final opacities = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .map((opacity) => opacity.opacity)
          .toList();
      expect(opacities, isNotEmpty);
      expect(opacities.where((value) => value > 0 && value < 1), isNotEmpty);

      final transforms = tester
          .widgetList<Transform>(find.byType(Transform))
          .map((transform) => transform.transform)
          .toList();
      final hasNonIdentity = transforms.any((matrix) => !matrix.isIdentity());
      expect(hasNonIdentity, isTrue);
    });

    testWidgets('controllerOf provides access to internal controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MorphingIcon.icons(
              icons: const [Icons.circle, Icons.square],
              config: const MorphingAnimationConfig.crossFade(
                duration: Duration(milliseconds: 150),
              ),
            ),
          ),
        ),
      );

      final element = tester.element(find.byType(MorphingIcon));
      final controller = MorphingIcon.controllerOf(element);

      expect(controller, isNotNull);
      expect(controller!.currentState, equals(0));

      controller.goTo(1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));

      expect(controller.currentState, equals(1));

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    });

    testWidgets('should handle empty states list', (WidgetTester tester) async {
      expect(() => MorphingIcon(states: []), throwsAssertionError);
    });

    testWidgets('should handle invalid initial state', (
      WidgetTester tester,
    ) async {
      expect(
        () => MorphingIcon.icons(icons: [Icons.favorite], initialState: 5),
        throwsAssertionError,
      );
    });
  });

  group('MorphingIconController Tests', () {
    test('previous state tracking works when switching states', () {
      final controller = MorphingIconController(
        states: [Container(), Container(), Container()],
        vsync: const TestVSync(),
        config: const MorphingAnimationConfig(),
      );

      expect(controller.currentState, 0);
      expect(controller.previousState, 0);

      controller.goTo(1);
      expect(controller.currentState, 1);
      expect(controller.previousState, 0);

      controller.next();
      expect(controller.currentState, 2);
      expect(controller.previousState, 1);

      controller.dispose();
    });

    test('jumpTo updates state without animation reset', () {
      final controller = MorphingIconController(
        states: [Container(), Container(), Container()],
        vsync: const TestVSync(),
        config: const MorphingAnimationConfig(),
      );

      controller.jumpTo(2);
      expect(controller.currentState, 2);
      expect(controller.previousState, 0);

      controller.replay();
      expect(controller.currentState, 2);
      expect(controller.previousState, 2);

      controller.dispose();
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
      final config = MorphingAnimationConfig.custom(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        parameters: const {
          'fade': true,
          'fadeBegin': 0.1,
          'fadeEnd': 0.9,
          'scale': true,
          'scaleBegin': 0.8,
          'scaleEnd': 1.4,
          'slide': true,
          'slideBegin': Offset(0, 0.2),
          'slideEnd': Offset.zero,
          'rotate': true,
          'rotationBegin': 0.0,
          'rotationEnd': math.pi,
        },
      );

      expect(config.type, equals(MorphingAnimationType.custom));
      expect(config.parameters['fade'], isTrue);
      expect(config.parameters['fadeBegin'], equals(0.1));
      expect(config.parameters['scaleEnd'], equals(1.4));
      expect(config.parameters['rotationEnd'], equals(math.pi));
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
